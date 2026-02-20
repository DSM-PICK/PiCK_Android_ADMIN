import Foundation

public enum OutListType: String, Equatable, Hashable {
    case outing = "외출"
    case earlyReturn = "조기귀가"
}

public struct OutListStudent: Identifiable, Hashable {
    public let id: String
    public let userName: String
    public let grade: Int
    public let classNum: Int
    public let num: Int
    public let start: String
    public let end: String
    public let reason: String
}

public struct OutListEarlyReturnStudent: Identifiable, Hashable {
    public let id: String
    public let userName: String
    public let grade: Int
    public let classNum: Int
    public let num: Int
    public let start: String
    public let reason: String
}

struct OutListOutingDTO: Decodable {
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

struct OutListEarlyReturnDTO: Decodable {
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
