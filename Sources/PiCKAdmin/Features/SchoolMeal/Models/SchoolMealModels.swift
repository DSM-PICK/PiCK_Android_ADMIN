import Foundation

// MARK: - Models
public struct MealInfo: Identifiable, Hashable {
    public let id = UUID()
    public let mealType: String // "중식", "석식"
    public let menu: [String]
    public let kcal: String
}

// MARK: - DTOs
struct NEISMealResponse: Decodable {
    let mealServiceDietInfo: [NEISMealInfoWrapper]?
}

enum NEISMealInfoWrapper: Decodable {
    case head([NEISHead])
    case row([NEISRow])
    
    enum CodingKeys: String, CodingKey {
        case head
        case row
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        if let head = try? container.decode([NEISHead].self, forKey: .head) {
            self = .head(head)
        } else if let row = try? container.decode([NEISRow].self, forKey: .row) {
            self = .row(row)
        } else {
            throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: container.codingPath, debugDescription: "Unknown NEIS structure"))
        }
    }
}

struct NEISHead: Decodable {
    let listTotalCount: Int?
}

struct NEISRow: Decodable {
    let mmealScCode: String
    let mmealScNm: String
    let mlsvYmd: String
    let ddishNm: String
    let calInfo: String
}
