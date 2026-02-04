import Foundation

public struct UpdateStatusRequest: Codable {
    public let status: String
    public let idList: [String]

    enum CodingKeys: String, CodingKey {
        case status
        case idList = "id_list"
    }
}
