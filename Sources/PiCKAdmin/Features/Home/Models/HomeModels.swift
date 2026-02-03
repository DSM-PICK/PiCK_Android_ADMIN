import Foundation

// MARK: - Home Models (Used by View)
public struct OutingStudent: Identifiable, Hashable {
    public let id: String
    public let userName: String
    public let grade: Int
    public let classNum: Int
    public let num: Int
    public let type: OutgoingType
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
    public let type: OutgoingType
}

public enum OutgoingType: String, Codable, Hashable {
    case outgoing = "OUTGOING"
    case earlyReturn = "EARLY_RETURN"

    public var title: String {
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

// MARK: - DTOs
struct SelfStudyDirectorDTO: Decodable {
    let floor: Int
    let teacherName: String
}

struct SelfStudyAndClassroomDTO: Decodable {
    let selfStudyFloor: Int
    let grade: Int
    let classNum: Int
}

struct ApplicationDTO: Decodable {
    let id: String
    let userName: String
    let grade: Int
    let classNum: Int
    let num: Int
    
    enum CodingKeys: String, CodingKey {
        case id
        case userName = "user_name"
        case grade
        case classNum = "class_num"
        case num
    }
}

struct EarlyReturnDTO: Decodable {
    let id: String
    let userName: String
    let grade: Int
    let classNum: Int
    let num: Int
    
    enum CodingKeys: String, CodingKey {
        case id
        case userName = "user_name"
        case grade
        case classNum = "class_num"
        case num
    }
}

struct ClassroomMoveDTO: Decodable {
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
