import Foundation

public struct AdminAPI {
    public static func getMyName() -> APIEndpoint {
        return APIEndpoint(path: "/admin/my-name")
    }
}
