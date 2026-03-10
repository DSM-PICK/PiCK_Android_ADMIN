import Foundation

public enum ApplicationType: String, Equatable, Hashable {
    case outgoing = "외출 수락"
    case classroomMove = "교실 이동"
    case earlyReturn = "조기 귀가"

    var title: String { rawValue }
}

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

struct AcceptApplicationDTO: Decodable {
    let id: String
    let userName: String
    let grade: Int
    let classNum: Int
    let num: Int
    let start: String
    let end: String
    let reason: String
}

struct AcceptEarlyReturnDTO: Decodable {
    let id: String
    let userName: String
    let grade: Int
    let classNum: Int
    let num: Int
    let start: String
    let reason: String
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
}
