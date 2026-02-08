import Foundation

public struct SigninRequest: Codable {
    public let adminId: String
    public let password: String
    public let deviceToken: String
    public let os: String

    enum CodingKeys: String, CodingKey {
        case adminId = "admin_id"
        case password
        case deviceToken = "device_token"
        case os
    }
}

public struct SigninResponse: Codable {
    public let accessToken: String
    public let refreshToken: String
}

public struct SignupRequest: Codable {
    public let accountId: String
    public let password: String
    public let name: String
    public let grade: Int
    public let classNum: Int
    public let code: String
    public let deviceToken: String
    public let secretKey: String

    enum CodingKeys: String, CodingKey {
        case accountId = "account_id"
        case password
        case name
        case grade
        case classNum = "class_num"
        case code
        case deviceToken = "device_token"
        case secretKey = "secret_key"
    }
}
