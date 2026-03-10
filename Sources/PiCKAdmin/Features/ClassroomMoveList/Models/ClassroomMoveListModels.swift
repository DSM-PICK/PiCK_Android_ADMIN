import Foundation

public enum ClassroomMoveListType: String, Equatable, Hashable {
    case floor = "층으로"
    case classroom = "교실로"
}

public struct ClassroomMoveListStudent: Identifiable, Hashable {
    public let id: String
    public let userName: String
    public let grade: Int
    public let classNum: Int
    public let num: Int
    public let start: Int
    public let end: Int
    public let classroomName: String
}

struct ClassroomMoveListDTO: Decodable {
    let userName: String
    let classroomName: String
    let grade: Int
    let classNum: Int
    let num: Int
    let start: Int
    let end: Int
    let userId: String?
}
