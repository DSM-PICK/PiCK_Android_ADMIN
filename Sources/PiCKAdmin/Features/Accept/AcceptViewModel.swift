import Foundation
import Observation
import SwiftUI

// MARK: - Application Type
public enum ApplicationType: String, Equatable, Hashable {
    case outgoing = "외출 수락"
    case classroomMove = "교실 이동"
    case earlyReturn = "조기 귀가"

    var title: String { rawValue }
}

// MARK: - Accept Models
public struct AcceptApplicationStudent: Identifiable, Hashable {
    public let id: String
    public let userName: String
    public let grade: Int
    public let classNum: Int
    public let num: Int
    public let start: String
    public let end: String
    public let reason: String
}

public struct AcceptEarlyReturnStudent: Identifiable, Hashable {
    public let id: String
    public let userName: String
    public let grade: Int
    public let classNum: Int
    public let num: Int
    public let start: String
    public let reason: String
}

public struct AcceptClassroomMoveStudent: Identifiable, Hashable {
    public let id: String
    public let userName: String
    public let grade: Int
    public let classNum: Int
    public let num: Int
    public let start: Int
    public let end: Int
    public let classroomName: String
}

// MARK: - Student Item Enum
public enum AcceptStudentItem: Identifiable, Hashable {
    case application(AcceptApplicationStudent)
    case classroomMove(AcceptClassroomMoveStudent)
    case earlyReturn(AcceptEarlyReturnStudent)

    public var id: String {
        switch self {
        case .application(let student): return student.id
        case .classroomMove(let student): return student.id
        case .earlyReturn(let student): return student.id
        }
    }
}

// MARK: - DTOs for Accept
struct AcceptApplicationDTO: Decodable {
    let id: String
    let userName: String
    let grade: Int
    let classNum: Int
    let num: Int
    let start: String
    let end: String
    let reason: String

    enum CodingKeys: String, CodingKey {
        case id
        case userName = "user_name"
        case grade
        case classNum = "class_num"
        case num
        case start
        case end
        case reason
    }
}

struct AcceptEarlyReturnDTO: Decodable {
    let id: String
    let userName: String
    let grade: Int
    let classNum: Int
    let num: Int
    let start: String
    let reason: String

    enum CodingKeys: String, CodingKey {
        case id
        case userName = "user_name"
        case grade
        case classNum = "class_num"
        case num
        case start
        case reason
    }
}

struct AcceptClassroomMoveDTO: Decodable {
    let id: String?
    let userId: String?
    let userName: String
    let classroomName: String
    let grade: Int
    let classNum: Int
    let num: Int
    let start: Int
    let end: Int

    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case userName = "user_name"
        case classroomName = "classroom_name"
        case grade
        case classNum = "class_num"
        case num
        case start
        case end
    }
}

// MARK: - Accept ViewModel
@Observable
public final class AcceptViewModel {
    public var studentItems: [AcceptStudentItem] = []
    public var selectedItemIds: Set<String> = []
    public var isLoading: Bool = false

    public var currentType: ApplicationType = .outgoing
    public var currentGrade: Int = 0
    public var currentClassNum: Int = 0
    public var currentFloor: Int = 3

    public var showAlert: Bool = false
    public var alertMessage: String = ""
    public var alertSuccessType: Bool = true

    public var showApprovePopup: Bool = false
    public var showRejectPopup: Bool = false

    public init() {}

    // MARK: - Fetch Self Study Info to get grade/classNum
    @MainActor
    public func fetchInitialData() async {
        isLoading = true
        defer { isLoading = false }

        do {
            let response = try await APIClient.shared.request(
                HomeAPI.getSelfStudyAndClassroom(),
                responseType: SelfStudyAndClassroomDTO.self
            )

            self.currentGrade = response.grade
            self.currentClassNum = response.classNum
            self.currentFloor = response.selfStudyFloor > 0 ? response.selfStudyFloor : 3

            // Fetch initial data based on type
            await fetchApplications()
        } catch {
            print("Failed to fetch initial data: \(error)")
        }
    }

    // MARK: - Fetch Applications (Outgoing)
    @MainActor
    public func fetchApplications() async {
        guard currentGrade > 0 && currentClassNum > 0 else { return }

        isLoading = true
        selectedItemIds = []
        studentItems = []

        defer { isLoading = false }

        do {
            let response = try await APIClient.shared.request(
                AcceptAPI.getApplicationsByGrade(grade: currentGrade, classNum: currentClassNum),
                responseType: [AcceptApplicationDTO].self
            )

            self.studentItems = response.map { dto in
                .application(AcceptApplicationStudent(
                    id: dto.id,
                    userName: dto.userName,
                    grade: dto.grade,
                    classNum: dto.classNum,
                    num: dto.num,
                    start: dto.start,
                    end: dto.end,
                    reason: dto.reason
                ))
            }
        } catch {
            print("Failed to fetch applications: \(error)")
        }
    }

    // MARK: - Fetch Early Returns
    @MainActor
    public func fetchEarlyReturns() async {
        guard currentGrade > 0 && currentClassNum > 0 else { return }

        isLoading = true
        selectedItemIds = []
        studentItems = []

        defer { isLoading = false }

        do {
            let response = try await APIClient.shared.request(
                AcceptAPI.getEarlyReturnByGrade(grade: currentGrade, classNum: currentClassNum),
                responseType: [AcceptEarlyReturnDTO].self
            )

            self.studentItems = response.map { dto in
                .earlyReturn(AcceptEarlyReturnStudent(
                    id: dto.id,
                    userName: dto.userName,
                    grade: dto.grade,
                    classNum: dto.classNum,
                    num: dto.num,
                    start: dto.start,
                    reason: dto.reason
                ))
            }
        } catch {
            print("Failed to fetch early returns: \(error)")
        }
    }

    // MARK: - Fetch Classroom Moves by Floor
    @MainActor
    public func fetchClassroomMovesByFloor(floor: Int) async {
        isLoading = true
        selectedItemIds = []
        studentItems = []
        currentFloor = floor

        defer { isLoading = false }

        do {
            let response = try await APIClient.shared.request(
                AcceptAPI.getClassroomMovesByFloor(floor: floor),
                responseType: [AcceptClassroomMoveDTO].self
            )

            self.studentItems = response.map { dto in
                .classroomMove(AcceptClassroomMoveStudent(
                    id: dto.id ?? dto.userId ?? UUID().uuidString,
                    userName: dto.userName,
                    grade: dto.grade,
                    classNum: dto.classNum,
                    num: dto.num,
                    start: dto.start,
                    end: dto.end,
                    classroomName: dto.classroomName
                ))
            }
        } catch {
            print("Failed to fetch classroom moves: \(error)")
        }
    }

    // MARK: - Toggle Selection
    public func toggleSelection(id: String) {
        if selectedItemIds.contains(id) {
            selectedItemIds.remove(id)
        } else {
            selectedItemIds.insert(id)
        }
    }

    // MARK: - Approve Selected
    @MainActor
    public func approveSelected() async {
        let idList = Array(selectedItemIds)
        guard !idList.isEmpty else { return }

        isLoading = true

        do {
            switch currentType {
            case .outgoing:
                try await APIClient.shared.requestVoid(
                    AcceptAPI.updateApplicationStatus(idList: idList, status: "OK")
                )
            case .classroomMove:
                try await APIClient.shared.requestVoid(
                    AcceptAPI.updateClassroomMoveStatus(idList: idList, status: "OK")
                )
            case .earlyReturn:
                try await APIClient.shared.requestVoid(
                    AcceptAPI.updateEarlyReturnStatus(idList: idList, status: "OK")
                )
            }

            // Remove approved items from list
            studentItems.removeAll { item in
                selectedItemIds.contains(item.id)
            }

            let count = selectedItemIds.count
            selectedItemIds = []
            showSuccessAlert(message: "\(count)명의 \(currentType.title) 수락이 완료되었습니다!")

        } catch {
            showErrorAlert(message: "수락 처리에 실패했습니다")
        }

        isLoading = false
    }

    // MARK: - Reject Selected
    @MainActor
    public func rejectSelected() async {
        let idList = Array(selectedItemIds)
        guard !idList.isEmpty else { return }

        isLoading = true

        do {
            switch currentType {
            case .outgoing:
                try await APIClient.shared.requestVoid(
                    AcceptAPI.updateApplicationStatus(idList: idList, status: "NO")
                )
            case .classroomMove:
                try await APIClient.shared.requestVoid(
                    AcceptAPI.updateClassroomMoveStatus(idList: idList, status: "NO")
                )
            case .earlyReturn:
                try await APIClient.shared.requestVoid(
                    AcceptAPI.updateEarlyReturnStatus(idList: idList, status: "NO")
                )
            }

            // Remove rejected items from list
            studentItems.removeAll { item in
                selectedItemIds.contains(item.id)
            }

            let count = selectedItemIds.count
            selectedItemIds = []
            showSuccessAlert(message: "\(count)명의 \(currentType.title) 거절이 완료되었습니다!")

        } catch {
            showErrorAlert(message: "거절 처리에 실패했습니다")
        }

        isLoading = false
    }

    // MARK: - Change Type
    @MainActor
    public func changeType(_ type: ApplicationType) async {
        currentType = type
        selectedItemIds = []

        switch type {
        case .outgoing:
            await fetchApplications()
        case .classroomMove:
            await fetchClassroomMovesByFloor(floor: currentFloor)
        case .earlyReturn:
            await fetchEarlyReturns()
        }
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

// MARK: - Accept API
public struct AcceptAPI {
    // Get applications by grade (for outgoing - PENDING status)
    public static func getApplicationsByGrade(grade: Int, classNum: Int) -> APIEndpoint {
        return APIEndpoint(
            path: "/application/grade",
            queryItems: [
                URLQueryItem(name: "grade", value: String(grade)),
                URLQueryItem(name: "class_num", value: String(classNum))
            ]
        )
    }

    // Get early returns by grade
    public static func getEarlyReturnByGrade(grade: Int, classNum: Int) -> APIEndpoint {
        return APIEndpoint(
            path: "/early-return/grade",
            queryItems: [
                URLQueryItem(name: "grade", value: String(grade)),
                URLQueryItem(name: "class_num", value: String(classNum))
            ]
        )
    }

    // Get classroom moves by floor (QUIET status for pending)
    public static func getClassroomMovesByFloor(floor: Int) -> APIEndpoint {
        return APIEndpoint(
            path: "/classroom/floor",
            queryItems: [
                URLQueryItem(name: "floor", value: String(floor)),
                URLQueryItem(name: "status", value: "QUIET")
            ]
        )
    }

    // Update application status
    public static func updateApplicationStatus(idList: [String], status: String) -> APIEndpoint {
        let body = try? JSONEncoder().encode(UpdateStatusRequest(status: status, idList: idList))
        return APIEndpoint(
            path: "/application/status",
            method: .patch,
            body: body
        )
    }

    // Update classroom move status
    public static func updateClassroomMoveStatus(idList: [String], status: String) -> APIEndpoint {
        let body = try? JSONEncoder().encode(UpdateStatusRequest(status: status, idList: idList))
        return APIEndpoint(
            path: "/classroom/status",
            method: .patch,
            body: body
        )
    }

    // Update early return status
    public static func updateEarlyReturnStatus(idList: [String], status: String) -> APIEndpoint {
        let body = try? JSONEncoder().encode(UpdateStatusRequest(status: status, idList: idList))
        return APIEndpoint(
            path: "/early-return/status",
            method: .patch,
            body: body
        )
    }
}
