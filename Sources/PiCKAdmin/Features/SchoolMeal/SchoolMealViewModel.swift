import Foundation
import Observation
import SwiftUI

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
    
    // Custom decoding to handle the weird array structure of NEIS API
    // [ { head: ... }, { row: ... } ]
    // Decodable might struggle with heterogeneous array.
    // However, the wrapper trick usually works if we check for keys.
    // Or we can assume index 1 has "row".
    
    // Simpler approach:
    // Decode as [[String: Any]]? No, Swift is strong typed.
    // Let's look at `SchoolMealDTO.swift` from iOS again.
    // It used `[NEISMealInfo]?`.
    // Let's replicate that structure.
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

@Observable
public final class SchoolMealViewModel {
    public var meals: [MealInfo] = []
    public var selectedDate: Date = Date()
    public var isLoading: Bool = false
    public var errorMessage: String?
    
    public init() {}
    
    @MainActor
    public func onAppear() async {
        await fetchSchoolMeal()
    }
    
    @MainActor
    public func changeDate(by value: Int) async {
        guard let newDate = Calendar.current.date(byAdding: .day, value: value, to: selectedDate) else { return }
        self.selectedDate = newDate
        await fetchSchoolMeal()
    }
    
    @MainActor
    public func selectDate(_ date: Date) async {
        self.selectedDate = date
        await fetchSchoolMeal()
    }
    
    @MainActor
    public func fetchSchoolMeal() async {
        isLoading = true
        errorMessage = nil
        meals = []
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        dateFormatter.timeZone = TimeZone(identifier: "Asia/Seoul")
        dateFormatter.locale = Locale(identifier: "ko_KR")
        let dateString = dateFormatter.string(from: selectedDate)
        
        do {
            // Note: APIClient might try snake_case conversion.
            // NEIS uses UPPERCASE_UNDERSCORE keys (MMEAL_SC_CODE).
            // snake_case strategy might lowercase them.
            // If APIClient enforces .convertFromSnakeCase, MMEAL_SC_CODE -> mmealScCode.
            // So my NEISRow struct should use camelCase properties matching that conversion.
            // MMEAL_SC_CODE -> mmealScCode
            // MLSV_YMD -> mlsvYmd
            // DDISH_NM -> ddishNm
            // CAL_INFO -> calInfo
            
            let response = try await APIClient.shared.request(
                SchoolMealAPI.fetchSchoolMeal(date: dateString),
                responseType: NEISMealResponse.self
            )
            
            var newMeals: [MealInfo] = []
            
            if let infoList = response.mealServiceDietInfo {
                for wrapper in infoList {
                    if case .row(let rows) = wrapper {
                        for row in rows {
                            let menuItems = parseMenu(row.ddishNm)
                            let cal = row.calInfo
                            
                            let mealType: String
                            if row.mmealScCode == "2" {
                                mealType = "중식"
                            } else if row.mmealScCode == "3" {
                                mealType = "석식"
                            } else {
                                continue
                            }
                            
                            newMeals.append(MealInfo(mealType: mealType, menu: menuItems, kcal: cal))
                        }
                    }
                }
            }
            
            // Sort by meal type code/order?
            // "2" comes before "3".
            // Or just trust API order.
            
            self.meals = newMeals
            
        } catch {
            print("Failed to fetch school meal: \(error)")
            self.errorMessage = "급식 정보를 불러올 수 없습니다"
        }
        
        isLoading = false
    }
    
    private func parseMenu(_ raw: String) -> [String] {
        // Remove <br/> and (allergy info)
        return raw
            .replacingOccurrences(of: "<br/>", with: "\n")
            .components(separatedBy: "\n")
            .map { item in
                item.replacingOccurrences(of: "\\s*\\([^)]*\\)", with: "", options: .regularExpression)
                    .trimmingCharacters(in: .whitespaces)
            }
            .filter { !$0.isEmpty }
    }
}

// Updated DTOs for camelCase conversion
struct NEISRow: Decodable {
    let mmealScCode: String
    let mmealScNm: String
    let mlsvYmd: String
    let ddishNm: String
    let calInfo: String
}
