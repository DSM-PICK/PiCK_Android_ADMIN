import Foundation

public struct OutingHistoryAPI {
    public static func getOutingHistory() -> APIEndpoint {
        return APIEndpoint(path: "/story/all")
    }
}
