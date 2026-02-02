import Foundation
import Observation
import SwiftUI

// MARK: - Plan Models
public struct AcademicSchedule: Identifiable, Hashable {
    public let id: String
    public let eventName: String
    public let month: Int
    public let day: Int
    public let dayName: String
}

struct AcademicScheduleDTO: Decodable {
    let id: String
    let eventName: String
    let month: Int
    let day: Int
    let dayName: String
}

@Observable
public final class PlanViewModel {
    public var monthAcademicSchedule: [AcademicSchedule] = []
    public var academicSchedule: [AcademicSchedule] = []
    public var selectedDate: Date = Date()
    public var currentMonth: Date = Date()
    
    public init() {
        let today = Date()
        self.selectedDate = today
        self.currentMonth = today
    }
    
    @MainActor
    public func onAppear() async {
        await fetchInitialData()
    }
    
    @MainActor
    public func changeMonth(by value: Int) async {
        print("Changing month by \(value)")
        guard let newMonth = Calendar.current.date(byAdding: .month, value: value, to: currentMonth) else { 
            print("Failed to calculate new month")
            return 
        }
        self.currentMonth = newMonth
        print("New month: \(currentMonth)")
        await fetchMonthSchedule()
    }
    
    @MainActor
    public func selectDate(_ date: Date) async {
        print("Selecting date: \(date)")
        self.selectedDate = date
        await fetchDaySchedule()
    }
    
    @MainActor
    private func fetchInitialData() async {
        await fetchMonthSchedule()
        await fetchDaySchedule()
    }
    
    @MainActor
    private func fetchMonthSchedule() async {
        var calendar = Calendar.current
        calendar.timeZone = TimeZone(identifier: "Asia/Seoul")!
        
        let year = String(calendar.component(.year, from: currentMonth))
        let monthFormatter = DateFormatter()
        monthFormatter.dateFormat = "MMMM"
        monthFormatter.locale = Locale(identifier: "en_US") // API expects English month name?
        monthFormatter.timeZone = TimeZone(identifier: "Asia/Seoul")
        let month = monthFormatter.string(from: currentMonth)
        
        do {
            print("📅 Fetching month schedule for: \(year) \(month)")
            let response = try await APIClient.shared.request(
                PlanAPI.fetchMonthAcademicSchedule(year: year, month: month),
                responseType: [AcademicScheduleDTO].self
            )
            print("✅ Month schedule fetched: \(response.count) events")
            self.monthAcademicSchedule = response.map {
                AcademicSchedule(id: $0.id, eventName: $0.eventName, month: $0.month, day: $0.day, dayName: $0.dayName)
            }
        } catch {
            print("❌ Failed to fetch month schedule: \(error)")
            self.monthAcademicSchedule = []
        }
    }
    
    @MainActor
    private func fetchDaySchedule() async {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        dateFormatter.timeZone = TimeZone(identifier: "Asia/Seoul") // Fix timezone issue
        dateFormatter.locale = Locale(identifier: "ko_KR")
        let dateString = dateFormatter.string(from: selectedDate)
        
        do {
            print("📅 Fetching day schedule for: \(dateString)")
            let response = try await APIClient.shared.request(
                PlanAPI.fetchAcademicScheduleByDate(date: dateString),
                responseType: [AcademicScheduleDTO].self
            )
            self.academicSchedule = response.map {
                AcademicSchedule(id: $0.id, eventName: $0.eventName, month: $0.month, day: $0.day, dayName: $0.dayName)
            }
        } catch {
            print("Failed to fetch day schedule: \(error)")
            self.academicSchedule = []
        }
    }
}
