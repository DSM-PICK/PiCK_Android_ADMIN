import SwiftUI

struct SchoolMealView: View {
    @Environment(\.appRouter) var router: AppRouter
    @State var viewModel = SchoolMealViewModel()
    @State var currentPage = Date()
    @State var isWeekMode = true
    
    var body: some View {
        ZStack(alignment: .top) {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    SelectedDateView(date: viewModel.selectedDate)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .pickText(type: .heading4)
                        .padding(.horizontal, 24)
                        .padding(.top, 184)
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
                },
                dateSelected: { date in
                }
            )
            .shadow(color: Color.Normal.black.opacity(0.25), radius: 20, x: 0, y: 0)
            .background(Color.Background.primary)
            .frame(maxHeight: .infinity, alignment: .top)
            .allowsHitTesting(true)
        }
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
            await viewModel.onAppear()
        }
    }
}
