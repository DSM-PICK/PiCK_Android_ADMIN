import Foundation

public struct MailAPI {
    public static func emailSend(email: String, title: String = "비밀번호 변경 인증", message: String = "비밀번호 변경 인증") -> APIEndpoint {
        let body = try? JSONEncoder().encode([
            "mail": email,
            "title": title,
            "message": message
        ])
        return APIEndpoint(
            path: "/mail/send",
            method: .post,
            body: body
        )
    }

    public static func codeCheck(email: String, code: String) -> APIEndpoint {
        let body = try? JSONEncoder().encode([
            "email": email,
            "code": code
        ])
        return APIEndpoint(
            path: "/mail/check",
            method: .post,
            body: body
        )
    }
}
