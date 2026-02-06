import Foundation

public struct AuthAPI {
    public static func signin(adminId: String, password: String, deviceToken: String = "") -> APIEndpoint {
        let body = try? JSONEncoder().encode(SigninRequest(
            adminId: adminId,
            password: password,
            deviceToken: deviceToken,
            os: "AOS"
        ))
        return APIEndpoint(
            path: "/admin/login",
            method: .post,
            body: body
        )
    }

    public static func signup(
        secretKey: String,
        accountId: String,
        password: String,
        name: String
    ) -> APIEndpoint {
        let body = try? JSONEncoder().encode(SignupRequest(
            secretKey: secretKey,
            accountId: accountId,
            password: password,
            name: name
        ))
        return APIEndpoint(
            path: "/admin/signup",
            method: .post,
            body: body
        )
    }

    public static func sendVerificationCode(accountId: String) -> APIEndpoint {
        let body = try? JSONEncoder().encode(["accountId": accountId])
        return APIEndpoint(
            path: "/admin/email/send",
            method: .post,
            body: body
        )
    }

    public static func verifyCode(accountId: String, code: String) -> APIEndpoint {
        let body = try? JSONEncoder().encode(["accountId": accountId, "code": code])
        return APIEndpoint(
            path: "/admin/email/verify",
            method: .post,
            body: body
        )
    }

    public static func refreshToken() -> APIEndpoint {
        return APIEndpoint(
            path: "/admin/refresh",
            method: .post,
            headers: ["Refresh-Token": JwtStore.shared.refreshToken ?? ""]
        )
    }

    public static func deleteAccount() -> APIEndpoint {
        return APIEndpoint(
            path: "/admin/delete",
            method: .delete
        )
    }

    public static func changePassword(adminId: String, code: String, password: String) -> APIEndpoint {
        struct ChangePasswordRequest: Encodable {
            let password: String
            let adminId: String
            let code: String

            enum CodingKeys: String, CodingKey {
                case password
                case adminId = "admin_id"
                case code
            }
        }

        let body = try? JSONEncoder().encode(ChangePasswordRequest(
            password: password,
            adminId: adminId,
            code: code
        ))
        return APIEndpoint(
            path: "/admin/password",
            method: .post,
            body: body
        )
    }
}
