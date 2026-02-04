import Foundation
import Observation
import SwiftUI

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
            
            self.meals = newMeals
            
        } catch {
            print("Failed to fetch school meal: \(error)")
            self.errorMessage = "급식 정보를 불러올 수 없습니다"
        }
        
        isLoading = false
    }
    
    private func parseMenu(_ raw: String) -> [String] {
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
