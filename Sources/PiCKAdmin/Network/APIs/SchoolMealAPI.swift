import Foundation

public struct SchoolMealAPI {
    public static func fetchSchoolMeal(date: String) -> APIEndpoint {
        let neisDate = date.replacingOccurrences(of: "-", with: "")
        return APIEndpoint(
            path: "/mealServiceDietInfo",
            queryItems: [
                URLQueryItem(name: "KEY", value: Secrets.neisAPIKey),
                URLQueryItem(name: "Type", value: "json"),
                URLQueryItem(name: "pIndex", value: "1"),
                URLQueryItem(name: "pSize", value: "100"),
                URLQueryItem(name: "ATPT_OFCDC_SC_CODE", value: Secrets.neisAtptOfcdcScCode),
                URLQueryItem(name: "SD_SCHUL_CODE", value: Secrets.neisSdSchulCode),
                URLQueryItem(name: "MLSV_YMD", value: neisDate)
            ],
            customBaseURL: Secrets.neisBaseURL
        )
    }
}
