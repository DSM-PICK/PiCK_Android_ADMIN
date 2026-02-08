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

    public static func secretKey(secretKey: String) -> APIEndpoint {
        let body = try? JSONEncoder().encode(["secret_key": secretKey])
        return APIEndpoint(
            path: "/admin/key",
            method: .post,
            body: body
        )
    }

    public static func signup(
        accountId: String,
        password: String,
        name: String,
        grade: Int,
        classNum: Int,
        code: String,
        deviceToken: String,
        secretKey: String
    ) -> APIEndpoint {
        let body = try? JSONEncoder().encode(SignupRequest(
            accountId: accountId,
            password: password,
            name: name,
            grade: grade,
            classNum: classNum,
            code: code,
            deviceToken: deviceToken,
            secretKey: secretKey
        ))
        return APIEndpoint(
            path: "/admin/signup",
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
