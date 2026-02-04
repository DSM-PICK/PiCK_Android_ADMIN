import Foundation

public struct BugReportAPI {
    public static func uploadImages(boundary: String, body: Data) -> APIEndpoint {
        return APIEndpoint(
            path: "/bug/upload",
            method: .post,
            headers: ["Content-Type": "multipart/form-data; boundary=\(boundary)"],
            body: body
        )
    }

    public static func submitBugReport(title: String, content: String, fileNames: [String]) -> APIEndpoint {
        let requestBody: [String: Any] = [
            "title": title,
            "model": "ANDROID",
            "content": content,
            "file_name": fileNames
        ]
        let body = try? JSONSerialization.data(withJSONObject: requestBody)
        return APIEndpoint(
            path: "/bug/message",
            method: .post,
            body: body
        )
    }
}
