import SwiftUI

struct PlanView: View {
    @State var viewModel = PlanViewModel()
    
    var body: some View {
        VStack(spacing: 0) {
            MonthHeaderView(
                currentMonth: viewModel.currentMonth,
                onPrevMonth: {
                    print("Prev Month Clicked")
                    Task { await viewModel.changeMonth(by: -1) }
                },
                onNextMonth: {
                    print("Next Month Clicked")
                    Task { await viewModel.changeMonth(by: 1) }
                }
            )
            .padding(.top, 32)
            .padding(.horizontal, 20)

            ScrollView {
                VStack(spacing: 0) {
                    // DEBUG Text removed for cleaner UI as logic is fixed
                    // Text("Events: \(viewModel.monthAcademicSchedule.count)")
                    //    .font(.caption)
                    //    .foregroundColor(.gray)

                    AcademicScheduleCalendarView(
                        monthSchedule: viewModel.monthAcademicSchedule,
                        selectedDate: viewModel.selectedDate,
                        currentMonth: viewModel.currentMonth,
                        onDateSelect: { date in
                            print("Date Selected: \(date)")
                            Task { await viewModel.selectDate(date) }
                        }
                    )
                    .id("\(viewModel.currentMonth)\(viewModel.selectedDate)\(viewModel.monthAcademicSchedule.count)") // Combine IDs
                    .padding(.top, 12)
                    .padding(.horizontal, 24)
                    
                    ScheduleListView(
                        selectedDate: viewModel.selectedDate,
                        schedules: viewModel.academicSchedule
                    )
                    
                    Spacer()
                }
            }
        }
        .background(Color.white)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Image("pickLogo", bundle: .module)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 20)
            }
        }
        .task {
            await viewModel.onAppear()
        }
    }
}

// MARK: - Month Header
struct MonthHeaderView: View {
    let currentMonth: Date
    let onPrevMonth: () -> Void
    let onNextMonth: () -> Void

    var body: some View {
        HStack(spacing: 0) {
            Button(action: onPrevMonth) {
                Image(systemName: "chevron.left")
                    .foregroundColor(.black)
                    .frame(width: 24, height: 24)
            }

            Spacer()
                .frame(width: 12)

            Text(currentMonth.toKoreanYearMonthString())
                .pickText(type: .body1)
                .foregroundColor(.black)

            Spacer()
                .frame(width: 12)

            Button(action: onNextMonth) {
                Image(systemName: "chevron.right")
                    .foregroundColor(.black)
                    .frame(width: 24, height: 24)
            }
        }
    }
}

// MARK: - Calendar View
struct AcademicScheduleCalendarView: View {
    let monthSchedule: [AcademicSchedule]
    let selectedDate: Date
    let currentMonth: Date
    let onDateSelect: (Date) -> Void

    private let calendar: Calendar = {
        var cal = Calendar.current
        cal.timeZone = TimeZone(identifier: "Asia/Seoul")!
        return cal
    }()
    private let daysOfWeek = ["일", "월", "화", "수", "목", "금", "토"]
    
    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                ForEach(daysOfWeek, id: \.self) { day in
                    Text(day)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                }
            }
            .padding(.bottom, 16)

            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 5) {
                ForEach(Array(calendarDates.enumerated()), id: \.offset) { index, date in
                    if let date = date {
                        DateCell(
                            date: date,
                            isSelected: calendar.isDate(date, inSameDayAs: selectedDate),
                            isToday: calendar.isDateInToday(date),
                            hasEvent: hasEvent(for: date),
                            isCurrentMonth: calendar.isDate(date, equalTo: currentMonth, toGranularity: .month)
                        )
                        .onTapGesture {
                            onDateSelect(date)
                        }
                    } else {
                        Color.clear
                            .frame(height: 40)
                    }
                }
            }
        }
        .padding(.vertical)
        .id(currentMonth) // Force redraw when month changes
    }
    
    private var calendarDates: [Date?] {
        guard let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: currentMonth)) else { return [] }
        guard let range = calendar.range(of: .day, in: .month, for: startOfMonth) else { return [] }
        
        var dates: [Date?] = []
        
        let firstWeekday = calendar.component(.weekday, from: startOfMonth) // 1 = Sun, 7 = Sat
        for _ in 0..<(firstWeekday - 1) {
            dates.append(nil)
        }
        
        for day in range {
            if let date = calendar.date(byAdding: .day, value: day - 1, to: startOfMonth) {
                dates.append(date)
            }
        }
        
        return dates
    }
    
    private func hasEvent(for date: Date) -> Bool {
        let month = calendar.component(.month, from: date)
        let day = calendar.component(.day, from: date)
        
        return monthSchedule.contains { schedule in
            schedule.month == month && schedule.day == day
        }
    }
}

// MARK: - Date Cell
struct DateCell: View {
    let date: Date
    let isSelected: Bool
    let isToday: Bool
    let hasEvent: Bool
    let isCurrentMonth: Bool
    
    private let calendar: Calendar = {
        var cal = Calendar.current
        cal.timeZone = TimeZone(identifier: "Asia/Seoul")!
        return cal
    }()
    
    var body: some View {
        VStack(spacing: 4) {
            Text("\(calendar.component(.day, from: date))")
                .font(.system(size: 14, weight: isSelected ? .semibold : .regular))
                .foregroundColor(textColor)
                .frame(width: 36, height: 36)
                .background(backgroundColor)
                .clipShape(Circle())
                .overlay(
                    Circle()
                        .stroke(borderColor, lineWidth: isSelected && !isToday ? 2 : 0)
                )
            
            if hasEvent {
                Circle()
                    .fill(Color.Primary.primary500)
                    .frame(width: 4, height: 4)
            } else {
                Color.clear
                    .frame(width: 4, height: 4)
            }
        }
        .opacity(isCurrentMonth ? 1.0 : 0.3)
        .background(Color.white.opacity(0.001)) // Ensure tap area covers the whole cell
    }
    
    private var textColor: Color {
        if !isCurrentMonth {
            return .gray
        }
        if isSelected || isToday {
            return .black
        }
        return .black
    }
    
    private var backgroundColor: Color {
        if isToday {
            return Color.Primary.primary100
        }
        return .clear
    }
    
    private var borderColor: Color {
        if isSelected && !isToday {
            return Color.Primary.primary100
        }
        return .clear
    }
}

// MARK: - Schedule List View
struct ScheduleListView: View {
    let selectedDate: Date
    let schedules: [AcademicSchedule]
    
    private let calendar: Calendar = {
        var cal = Calendar.current
        cal.timeZone = TimeZone(identifier: "Asia/Seoul")!
        return cal
    }()
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 4) {
                if calendar.isDateInToday(selectedDate) {
                    Text("오늘")
                        .pickText(type: .caption1, textColor: .Primary.primary500)
                    
                    Text(selectedDate.koreanDateString()) // Using existing extension
                        .pickText(type: .caption1, textColor: .Normal.black)
                } else {
                    Text(selectedDate.koreanDateString())
                        .pickText(type: .caption1, textColor: .Normal.black)
                }
            }
            .padding(.leading, 24)
            
            if schedules.isEmpty {
                Text("일정이 없습니다.")
                    .font(.system(size: 14, weight: .regular))
                    .foregroundColor(.gray)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.top, 72)
            } else {
                Text("\(schedules.count)개의 일정이 있습니다.")
                    .pickText(type: .caption2, textColor: .Gray.gray800)
                    .padding(.leading, 24)
                    .padding(.top, 8)

                VStack(spacing: 0) {
                    ForEach(schedules) { schedule in
                        ScheduleRow(schedule: schedule)
                    }
                }
                .padding(.top, 24)
            }
        }
    }
}

struct ScheduleRow: View {
    let schedule: AcademicSchedule
    
    var body: some View {
        HStack(spacing: 0) {
            Rectangle()
                .fill(Color.Primary.primary500)
                .frame(width: 4, height: 51)
            
            Text(schedule.eventName)
                .pickText(type: .body2, textColor: .Normal.black)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.leading, 20)
        }
        .padding(.horizontal, 24)
    }
}

// MARK: - Extensions
extension Date {
    func toKoreanYearMonthString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy년 M월"
        formatter.timeZone = TimeZone(identifier: "Asia/Seoul") // Fix timezone
        return formatter.string(from: self)
    }
}