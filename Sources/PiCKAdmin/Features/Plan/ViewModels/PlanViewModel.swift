import Foundation
import Observation
import SwiftUI

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
        var calendar = Calendar.current
        calendar.timeZone = TimeZone(identifier: "Asia/Seoul")!
        
        guard let newMonth = calendar.date(byAdding: .month, value: value, to: currentMonth) else { 
            return 
        }
        self.currentMonth = newMonth
        self.selectedDate = newMonth
        self.academicSchedule = []
        
        await fetchMonthSchedule()
        await fetchDaySchedule()
    }
    
    @MainActor
    public func selectDate(_ date: Date) async {
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
        monthFormatter.locale = Locale(identifier: "en_US")
        monthFormatter.timeZone = TimeZone(identifier: "Asia/Seoul")
        let month = monthFormatter.string(from: currentMonth)
        
        do {
            let response = try await APIClient.shared.request(
                PlanAPI.fetchMonthAcademicSchedule(year: year, month: month),
                responseType: [AcademicScheduleDTO].self
            )
            self.monthAcademicSchedule = response.map {
                AcademicSchedule(id: $0.id, eventName: $0.eventName, month: $0.month, day: $0.day, dayName: $0.dayName)
            }
        } catch {
            print("Failed to fetch month schedule: \(error)")
            self.monthAcademicSchedule = []
        }
    }
    
    @MainActor
    private func fetchDaySchedule() async {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        dateFormatter.timeZone = TimeZone(identifier: "Asia/Seoul")
        dateFormatter.locale = Locale(identifier: "ko_KR")
        let dateString = dateFormatter.string(from: selectedDate)
        
        do {
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
