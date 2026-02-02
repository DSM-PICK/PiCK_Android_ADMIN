import Foundation
import Observation

// MARK: - Home Models
public struct OutingStudent: Identifiable, Hashable {
    public let id: String
    public let userName: String
    public let grade: Int
    public let classNum: Int
    public let num: Int
    public let type: OutingType
}

public struct ClassroomMoveStudent: Identifiable, Hashable {
    public let id: String
    public let userName: String
    public let grade: Int
    public let classNum: Int
    public let num: Int
    public let start: Int
    public let end: Int
    public let classroomName: String
}

public struct AcceptStudent: Identifiable, Hashable {
    public let id: String
    public let userName: String
    public let grade: Int
    public let classNum: Int
    public let num: Int
    public let type: OutingType
}

public enum OutingType: String, Codable, Hashable {
    case outgoing = "OUTGOING"
    case earlyReturn = "EARLY_RETURN"

    public var displayName: String {
        switch self {
        case .outgoing: return "외출"
        case .earlyReturn: return "조기귀가"
        }
    }
}

public struct SelfStudyDirector: Hashable {
    public let floor: Int
    public let teacherName: String
}

// MARK: - Home ViewModel
@Observable
public final class HomeViewModel {
    public var adminSelfStudyTeacher: String = ""
    public var selfStudyDirector: [SelfStudyDirector] = []
    public var outingAcceptList: [AcceptStudent] = []
    public var outingStudentList: [OutingStudent] = []
    public var classroomMoveList: [ClassroomMoveStudent] = []

    public var isHomeroomTeacher: Bool = true
    public var isSelfStudyTeacher: Bool = true
    public var classroom: String = "2학년 1반"
    public var floor: String = "2층"

    public var isLoading: Bool = false
    public var showAlert: Bool = false
    public var alertMessage: String = ""
    public var alertSuccessType: Bool = true

    public init() {}

    @MainActor
    public func fetchSelfStudyDirector(date: String) async {
        // TODO: Implement API call
        // Mock data for now
        selfStudyDirector = [
            SelfStudyDirector(floor: 2, teacherName: "김선생"),
            SelfStudyDirector(floor: 3, teacherName: "이선생"),
            SelfStudyDirector(floor: 4, teacherName: "박선생"),
        ]
    }

    @MainActor
    public func fetchAdminSelfStudyInfo() async {
        // TODO: Implement API call
        adminSelfStudyTeacher = "오늘의 자습감독 선생님: 김선생님"
    }

    @MainActor
    public func fetchSelfStudyAndClassroom() async {
        // TODO: Implement API call
        // Mock data
        outingAcceptList = [
            AcceptStudent(id: "1", userName: "홍길동", grade: 2, classNum: 1, num: 1, type: .outgoing),
            AcceptStudent(id: "2", userName: "김철수", grade: 2, classNum: 1, num: 5, type: .earlyReturn),
        ]

        outingStudentList = [
            OutingStudent(id: "3", userName: "이영희", grade: 2, classNum: 2, num: 3, type: .outgoing),
        ]

        classroomMoveList = [
            ClassroomMoveStudent(
                id: "4",
                userName: "박민수",
                grade: 2,
                classNum: 1,
                num: 10,
                start: 7,
                end: 8,
                classroomName: "세미나실1"
            ),
        ]
    }

    @MainActor
    public func acceptApplication(id: String) async {
        // TODO: Implement API call
        outingAcceptList.removeAll { $0.id == id }
        showSuccessAlert(message: "외출이 승인되었습니다")
    }

    @MainActor
    public func rejectApplication(id: String) async {
        // TODO: Implement API call
        outingAcceptList.removeAll { $0.id == id }
        showSuccessAlert(message: "외출이 거절되었습니다")
    }

    @MainActor
    public func acceptEarlyReturn(id: String) async {
        // TODO: Implement API call
        outingAcceptList.removeAll { $0.id == id }
        showSuccessAlert(message: "조기귀가가 승인되었습니다")
    }

    @MainActor
    public func rejectEarlyReturn(id: String) async {
        // TODO: Implement API call
        outingAcceptList.removeAll { $0.id == id }
        showSuccessAlert(message: "조기귀가가 거절되었습니다")
    }

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
    public func dismissAlert() {
        showAlert = false
    }
}

// MARK: - Date Extension
extension Date {
    static func todayString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: Date())
    }
}
