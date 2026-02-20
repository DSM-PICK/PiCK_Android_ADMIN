import SwiftUI

public enum CalendarType {
    case schoolMeal
    case selfStudy
}

struct PiCKCalendarView: View {
    private let calendarType: CalendarType
    @Binding private var selectedDate: Date
    @Binding private var currentPage: Date
    @Binding private var isWeekMode: Bool

    let topToggleButtonTapped: () -> Void
    let bottomToggleButtonTapped: () -> Void
    let dateSelected: (Date) -> Void

    private let calendar: Calendar = {
        var cal = Calendar.current
        cal.timeZone = TimeZone(identifier: "Asia/Seoul")!
        cal.firstWeekday = 1 // 일요일 시작
        return cal
    }()
    private let weekSymbols = ["일", "월", "화", "수", "목", "금", "토"]

    private let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.locale = Locale(identifier: "ko_KR")
        f.dateFormat = "yyyy년 M월"
        f.timeZone = TimeZone(identifier: "Asia/Seoul")
        return f
    }()

    public init(
        calendarType: CalendarType,
        selectedDate: Binding<Date>,
        currentPage: Binding<Date>,
        isWeekMode: Binding<Bool>,
        topToggleButtonTapped: @escaping () -> Void = {},
        bottomToggleButtonTapped: @escaping () -> Void = {},
        dateSelected: @escaping (Date) -> Void = { _ in }
    ) {
        self.calendarType = calendarType
        self._selectedDate = selectedDate
        self._currentPage = currentPage
        self._isWeekMode = isWeekMode
        self.topToggleButtonTapped = topToggleButtonTapped
        self.bottomToggleButtonTapped = bottomToggleButtonTapped
        self.dateSelected = dateSelected
    }

    public var body: some View {
        VStack(spacing: 12) {
            if calendarType == .selfStudy {
                Button(action: {
                    withAnimation(.easeInOut) {
                        if !isWeekMode {
                            currentPage = selectedDate
                        }
                        isWeekMode.toggle()
                    }
                    topToggleButtonTapped()
                }) {
                    Image(systemName: isWeekMode ? "chevron.up" : "chevron.down")
                        .foregroundColor(Color.Primary.primary500)
                }
            }

            HStack (spacing: 16) {
                if !isWeekMode {
                    Button(action: previousMonth) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 16, weight: .regular))
                            .foregroundColor(Color.Normal.black)
                    }
                }

                Text(dateFormatter.string(from: currentPage))
                    .pickText(type: .label1, textColor: Color.Normal.black)
                    .foregroundColor(.primary)

                if !isWeekMode {
                    Button(action: nextMonth) {
                        Image(systemName: "chevron.right")
                            .font(.system(size: 16, weight: .regular))
                            .foregroundColor(Color.Normal.black)
                    }
                }
            }
            .padding(.horizontal, 4)

            HStack(spacing: 0) {
                ForEach(weekSymbols, id: \.self) { day in
                    Text(day)
                        .font(.system(size: 13, weight: .medium))
                        .frame(maxWidth: .infinity)
                }
            }

            calendarGrid

            if calendarType == .schoolMeal {
                Button(action: {
                    withAnimation(.easeInOut) {
                        if !isWeekMode {
                            currentPage = selectedDate
                        }
                        isWeekMode.toggle()
                    }
                    bottomToggleButtonTapped()
                }) {
                    Image(systemName: isWeekMode ? "chevron.down" : "chevron.up")
                        .foregroundColor(Color.Primary.primary500)
                }
            }
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 24)
        .background(Color.Normal.white) // System background replacement
        .clipShape(
            RoundedCorner(
                radius: 20,
                corners: calendarType == .schoolMeal
                    ? [RectCorner.bottomLeft, RectCorner.bottomRight]
                    : [RectCorner.topLeft, RectCorner.topRight]
            )
        )
    }

    private var calendarGrid: some View {
        let allDates = generateDates(for: currentPage)
        let visibleDates = isWeekMode ? weekDates(from: selectedDate, in: allDates) : allDates
        let columns = Array(repeating: GridItem(.flexible(), spacing: 4), count: 7)

        return LazyVGrid(columns: columns, spacing: 4) {
            ForEach(Array(visibleDates.enumerated()), id: \.offset) { index, date in
                let isCurrentMonth = calendar.isDate(date, equalTo: currentPage, toGranularity: .month)
                let isSelected = calendar.isDate(date, inSameDayAs: selectedDate)
                let isToday = calendar.isDateInToday(date)

                Button(action: {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        selectedDate = date
                    }
                    dateSelected(date)
                }) {
                    ZStack {
                        if isToday {
                            Circle()
                                .fill(Color.Primary.primary100)
                                .frame(width: 32, height: 32)
                        }
                        
                        if isSelected {
                            Circle()
                                .stroke(Color.Primary.primary500, lineWidth: 1) // Changed to 500 for visibility
                                .frame(width: 32, height: 32)
                        }

                        Text("\(calendar.component(.day, from: date))")
                            .font(.system(size: 14))
                            .foregroundColor(isCurrentMonth ? .black : .gray)
                            .frame(width: 32, height: 32)
                    }
                    .frame(minWidth: 44, minHeight: 44)
                }
                .buttonStyle(.plain)
            }
        }
    }

    private func generateDates(for month: Date) -> [Date] {
        guard let monthInterval = calendar.dateInterval(of: .month, for: month) else {
            return []
        }

        guard let firstWeekInterval = calendar.dateInterval(of: .weekOfMonth, for: monthInterval.start),
              let lastWeekInterval = calendar.dateInterval(of: .weekOfMonth, for: monthInterval.end.addingTimeInterval(-1)) else {
            return []
        }

        var dates: [Date] = []
        var currentDate = firstWeekInterval.start

        while currentDate < lastWeekInterval.end {
            dates.append(currentDate)
            guard let nextDate = calendar.date(byAdding: .day, value: 1, to: currentDate) else { break }
            currentDate = nextDate
        }

        return dates
    }

    private func weekDates(from selected: Date, in allDates: [Date]) -> [Date] {
        
        guard let index = allDates.firstIndex(where: { calendar.isDate($0, inSameDayAs: selected) }) else { 
            return generateCurrentWeek(from: selected)
        }
        
        let weekStart = (index / 7) * 7
        let weekEnd = min(weekStart + 7, allDates.count)
        return Array(allDates[weekStart..<weekEnd])
    }
    
    private func generateCurrentWeek(from date: Date) -> [Date] {
        let weekday = calendar.component(.weekday, from: date)
        let startOfWeek = calendar.date(byAdding: .day, value: -(weekday - 1), to: date)!
        return (0..<7).compactMap { calendar.date(byAdding: .day, value: $0, to: startOfWeek) }
    }

    private func previousMonth() {
        withAnimation(.easeInOut(duration: 0.3)) {
            if let prev = calendar.date(byAdding: .month, value: -1, to: currentPage) {
                currentPage = prev
            }
        }
    }

    private func nextMonth() {
        withAnimation(.easeInOut(duration: 0.3)) {
            if let next = calendar.date(byAdding: .month, value: 1, to: currentPage) {
                currentPage = next
            }
        }
    }
}
