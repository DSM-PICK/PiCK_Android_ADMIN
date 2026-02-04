import Foundation

public struct PlanAPI {
    public static func fetchAcademicScheduleByDate(date: String) -> APIEndpoint {
        return APIEndpoint(
            path: "/schedule/date",
            queryItems: [URLQueryItem(name: "date", value: date)]
        )
    }

    public static func fetchMonthAcademicSchedule(year: String, month: String) -> APIEndpoint {
        return APIEndpoint(
            path: "/schedule/month",
            queryItems: [
                URLQueryItem(name: "year", value: year),
                URLQueryItem(name: "month", value: month)
            ]
        )
    }
}
