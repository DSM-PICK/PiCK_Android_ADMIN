import Foundation
import Observation
import SwiftUI

// MARK: - ViewModel
@Observable
public final class SelfStudyCheckViewModel {
    public var studentItems: [StudentAttendanceItem] = []
    public var initialStudentItems: [StudentAttendanceItem] = []

    public var selectedPeriod: Period = .eighth
    public var selectedGrade: Int = 1
    public var selectedClass: Int = 1

    public var isLoading: Bool = false
    public var isSaving: Bool = false

    public var showAlert: Bool = false
    public var alertMessage: String = ""
    public var alertSuccessType: Bool = true

    public var showGradeClassPicker: Bool = false
    public var showStatusPicker: Bool = false
    public var selectedStudentId: String? = nil

    public var isChanged: Bool {
        return studentItems != initialStudentItems
    }

    public init() {}

    // MARK: - Fetch Students
    @MainActor
    public func fetchStudents() async {
        isLoading = true

        do {
            let response = try await APIClient.shared.request(
                SelfStudyCheckAPI.getStudentAttendance(
                    grade: selectedGrade,
                    classNum: selectedClass,
                    period: selectedPeriod.rawValue
                ),
                responseType: [StudentAttendanceDTO].self
            )

            let items = response.map { dto in
                StudentAttendanceItem(
                    id: dto.id,
                    grade: dto.grade,
                    classNum: dto.classNum,
                    num: dto.num,
                    userName: dto.userName,
                    status: mapStatusToKorean(dto.status),
                    classroomName: dto.classroomName
                )
            }.sorted { a, b in
                if a.grade != b.grade { return a.grade < b.grade }
                if a.classNum != b.classNum { return a.classNum < b.classNum }
                return a.num < b.num
            }

            self.studentItems = items
            self.initialStudentItems = items

        } catch {
            print("Failed to fetch students: \(error)")
            self.studentItems = []
            self.initialStudentItems = []
        }

        isLoading = false
    }

    // MARK: - Update Student Status
    public func updateStudentStatus(id: String, status: String) {
        if let index = studentItems.firstIndex(where: { $0.id == id }) {
            studentItems[index].status = status
        }
    }

    // MARK: - Save Attendance
    @MainActor
    public func saveAttendance() async {
        guard isChanged else { return }

        isSaving = true

        let changedStudents = studentItems.filter { item in
            guard let initial = initialStudentItems.first(where: { $0.id == item.id }) else {
                return false
            }
            return item.status != initial.status
        }

        let requests = changedStudents.compactMap { item -> AttendanceUpdateRequest? in
            guard let status = AttendanceStatus.fromKorean(item.status) else { return nil }
            return AttendanceUpdateRequest(userId: item.id, status: status.rawValue)
        }

        guard !requests.isEmpty else {
            isSaving = false
            return
        }

        do {
            try await APIClient.shared.requestVoid(
                SelfStudyCheckAPI.modifyAttendance(
                    period: selectedPeriod.rawValue,
                    attendances: requests
                )
            )

            initialStudentItems = studentItems
            showSuccessAlert(message: "출결 정보가 저장되었습니다")

        } catch {
            showErrorAlert(message: "저장에 실패했습니다")
        }

        isSaving = false
    }

    // MARK: - Select Period
    @MainActor
    public func selectPeriod(_ period: Period) async {
        selectedPeriod = period
        await fetchStudents()
    }

    // MARK: - Select Grade and Class
    @MainActor
    public func selectGradeAndClass(grade: Int, classNum: Int) async {
        selectedGrade = grade
        selectedClass = classNum
        await fetchStudents()
    }

    // MARK: - Status Mapping
    private func mapStatusToKorean(_ status: String) -> String {
        return AttendanceStatus(rawValue: status)?.korean ?? status
    }

    // MARK: - Alert Helpers
    @MainActor
    private func showSuccessAlert(message: String) {
        alertMessage = message
        alertSuccessType = true
        showAlert = true

        Task {
            try? await Task.sleep(nanoseconds: 2_000_000_000)
            showAlert = false
        }
    }

    @MainActor
    private func showErrorAlert(message: String) {
        alertMessage = message
        alertSuccessType = false
        showAlert = true

        Task {
            try? await Task.sleep(nanoseconds: 2_000_000_000)
            showAlert = false
        }
    }
}

// MARK: - SelfStudyCheck API
public struct SelfStudyCheckAPI {
    public static func getStudentAttendance(grade: Int, classNum: Int, period: Int) -> APIEndpoint {
        return APIEndpoint(
            path: "/attendance/grade",
            queryItems: [
                URLQueryItem(name: "grade", value: String(grade)),
                URLQueryItem(name: "class_num", value: String(classNum)),
                URLQueryItem(name: "period", value: String(period))
            ]
        )
    }

    public static func modifyAttendance(period: Int, attendances: [AttendanceUpdateRequest]) -> APIEndpoint {
        let body = try? JSONEncoder().encode(attendances)
        return APIEndpoint(
            path: "/attendance/modify",
            method: .patch,
            body: body,
            queryItems: [
                URLQueryItem(name: "period", value: String(period))
            ]
        )
    }
}
