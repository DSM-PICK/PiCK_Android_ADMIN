import SwiftUI

struct SchoolMealView: View {
    @State var viewModel = SchoolMealViewModel()
    @State var currentPage = Date()
    @State var isWeekMode = true
    
    var body: some View {
        ZStack(alignment: .top) {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    SelectedDateView(date: viewModel.selectedDate)
                        .padding(.horizontal, 24)
                        .padding(.top, 184) // Space for calendar
                        .padding(.bottom, 20)

                    if viewModel.isLoading {
                        ProgressView()
                            .frame(maxWidth: .infinity)
                            .padding(.top, 40)
                    } else if let error = viewModel.errorMessage {
                        Text(error)
                            .pickText(type: .body1, textColor: .Gray.gray600)
                            .frame(maxWidth: .infinity)
                            .padding(.top, 40)
                    } else if viewModel.meals.isEmpty {
                        Text("급식이 없습니다")
                            .pickText(type: .body1, textColor: .Gray.gray600)
                            .frame(maxWidth: .infinity)
                            .padding(.top, 40)
                    } else {
                        VStack(spacing: 20) {
                            ForEach(viewModel.meals) { meal in
                                SchoolMealCell(
                                    mealTime: meal.mealType,
                                    menu: meal.menu,
                                    kcal: meal.kcal
                                )
                            }
                        }
                        .padding(.horizontal, 24)
                        .padding(.bottom, 120) // Bottom padding
                    }
                }
            }
            .ignoresSafeArea(edges: .bottom)
            .overlay(
                Group {
                    if !isWeekMode {
                        Color.Normal.black.opacity(0.4)
                            .ignoresSafeArea()
                            .onTapGesture {
                                withAnimation {
                                    isWeekMode = true
                                }
                            }
                    }
                }
            )
            
            PiCKCalendarView(
                calendarType: .schoolMeal,
                selectedDate: Binding(
                    get: { viewModel.selectedDate },
                    set: { date in
                        _ = Task {
                            await viewModel.selectDate(date)
                        }
                    }
                ),
                currentPage: $currentPage,
                isWeekMode: $isWeekMode,
                bottomToggleButtonTapped: {
                    // Logic handled in view, but callback available
                },
                dateSelected: { date in
                    // Impact feedback or additional logic
                }
            )
            .shadow(color: Color.Normal.black.opacity(0.25), radius: 20, x: 0, y: 0)
            .background(Color.Background.primary)
        }
        .background(Color.Normal.white)
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

// MARK: - Selected Date View
struct SelectedDateView: View {
    let date: Date

    var body: some View {
        HStack(spacing: 4) {
            if isToday {
                Text("오늘")
                    .pickText(type: .heading2, textColor: .Primary.primary500)
            }
            Text(formattedDate)
                .pickText(type: .heading2, textColor: .Normal.black)
        }
    }
    
    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "MM월 dd일"
        formatter.timeZone = TimeZone(identifier: "Asia/Seoul")
        return formatter.string(from: date)
    }
    
    private var isToday: Bool {
        let todayFormatter = DateFormatter()
        todayFormatter.locale = Locale(identifier: "ko_KR")
        todayFormatter.dateFormat = "MM월 dd일"
        todayFormatter.timeZone = TimeZone(identifier: "Asia/Seoul")
        let today = todayFormatter.string(from: Date())
        return formattedDate == today
    }
}

// MARK: - School Meal Cell
struct SchoolMealCell: View {
    let mealTime: String
    let menu: [String]
    let kcal: String

    var body: some View {
        HStack(spacing: 0) {
            Spacer()

            VStack(spacing: 16) {
                Text(mealTime)
                    .pickText(type: .button1, textColor: .Primary.primary700)

                if !menu.isEmpty {
                    Text(kcal)
                        .pickText(type: .caption2, textColor: .Normal.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 4)
                        .background(Color.Primary.primary500)
                        .cornerRadius(12)
                }
            }

            Spacer()

            Text(menu.isEmpty ? "급식이 없습니다" : menu.joined(separator: "\n"))
                .pickText(type: .label1, textColor: .Normal.black)
                .multilineTextAlignment(.leading)
                .frame(width: 120, alignment: .leading)

            Spacer()
        }
        .frame(maxWidth: .infinity, minHeight: 140)
        .padding(.vertical, 10)
        .background(Color.Background.primary)
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.Primary.primary50, lineWidth: 2)
        )
    }
}