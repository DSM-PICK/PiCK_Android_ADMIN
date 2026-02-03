import SwiftUI

struct PlanView: View {
    @Environment(\.appRouter) var router: AppRouter
    @State var viewModel = PlanViewModel()
    
    var body: some View {
        VStack(spacing: 0) {
            MonthHeaderView(
                currentMonth: viewModel.currentMonth,
                onPrevMonth: {
                    Task { await viewModel.changeMonth(by: -1) }
                },
                onNextMonth: {
                    Task { await viewModel.changeMonth(by: 1) }
                }
            )
            .padding(.top, 32)
            .padding(.horizontal, 20)

            ScrollView {
                VStack(spacing: 0) {
                    AcademicScheduleCalendarView(
                        monthSchedule: viewModel.monthAcademicSchedule,
                        selectedDate: viewModel.selectedDate,
                        currentMonth: viewModel.currentMonth,
                        onDateSelect: { date in
                            Task { await viewModel.selectDate(date) }
                        }
                    )
                    .id("\(viewModel.currentMonth)\(viewModel.selectedDate)\(viewModel.monthAcademicSchedule.count)")
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
                    .padding(.leading, 8)
            }
        }
        .task {
            router.selectedTab = 1
            await viewModel.onAppear()
        }
    }
}
