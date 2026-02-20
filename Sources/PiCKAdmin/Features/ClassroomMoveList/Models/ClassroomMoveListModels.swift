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
    
    enum CodingKeys: String, CodingKey {
        case userName = "user_name"
        case classroomName = "classroom_name"
        case grade
        case classNum = "class_num"
        case num
        case start
        case end
        case userId = "user_id"
    }
}
