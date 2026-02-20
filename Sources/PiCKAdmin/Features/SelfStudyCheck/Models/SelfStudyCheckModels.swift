import Foundation

public enum Period: Int, CaseIterable, Hashable {
    case eighth = 8
    case ninth = 9
    case tenth = 10

    var title: String {
        return "\(rawValue)교시"
    }
}

public enum AttendanceStatus: String, CaseIterable {
    case attendance = "ATTENDANCE"
    case movement = "MOVEMENT"
    case goHome = "GO_HOME"
    case goOut = "GO_OUT"
    case picnic = "PICNIC"
    case employment = "EMPLOYMENT"

    var korean: String {
        switch self {
        case .attendance: return "출석"
        case .movement: return "이동"
        case .goHome: return "귀가"
        case .goOut: return "외출"
        case .picnic: return "현체"
        case .employment: return "취업"
        }
    }

    static func fromKorean(_ korean: String) -> AttendanceStatus? {
        return AttendanceStatus.allCases.first { $0.korean == korean }
    }
}

public struct StudentAttendanceItem: Identifiable, Equatable, Hashable {
    public let id: String
    public let grade: Int
    public let classNum: Int
    public let num: Int
    public let userName: String
    public var status: String  // Korean status
    public let classroomName: String

    var studentNumber: String {
        return "\(grade)\(classNum)\(num < 10 ? "0" : "")\(num)"
    }
}

struct StudentAttendanceDTO: Decodable {
    let id: String
    let userName: String
    let grade: Int
    let classNum: Int
    let num: Int
    let status: String
    let classroomName: String
}

public struct AttendanceUpdateRequest: Encodable {
    public let userId: String
    public let status: String

    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case status
    }

    public init(userId: String, status: String) {
        self.userId = userId
        self.status = status
    }
}
