import Foundation

public struct SigninRequest: Codable {
    public let adminId: String
    public let password: String
    public let deviceToken: String

    enum CodingKeys: String, CodingKey {
        case adminId = "admin_id"
        case password
        case deviceToken = "device_token"
    }
}

public struct SigninResponse: Codable {
    public let accessToken: String
    public let refreshToken: String
}

public struct SignupRequest: Codable {
    public let secretKey: String
    public let accountId: String
    public let password: String
    public let name: String
}
