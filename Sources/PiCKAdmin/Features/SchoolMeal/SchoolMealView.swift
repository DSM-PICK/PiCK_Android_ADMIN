import SwiftUI

struct SchoolMealView: View {
    @State var viewModel = SchoolMealViewModel()
    
    var body: some View {
        VStack(spacing: 0) {
            // Date Header
            HStack(spacing: 12) {
                Button(action: {
                    Task { await viewModel.changeDate(by: -1) }
                }) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.black)
                        .frame(width: 24, height: 24)
                }
                
                Text(dateString(viewModel.selectedDate))
                    .pickText(type: .heading2)
                
                Button(action: {
                    Task { await viewModel.changeDate(by: 1) }
                }) {
                    Image(systemName: "chevron.right")
                        .foregroundColor(.black)
                        .frame(width: 24, height: 24)
                }
            }
            .padding(.top, 24)
            .padding(.bottom, 20)
            
            // Content
            ScrollView {
                if viewModel.isLoading {
                    ProgressView()
                        .padding(.top, 40)
                } else if let error = viewModel.errorMessage {
                    Text(error)
                        .pickText(type: .body1, textColor: .Gray.gray600)
                        .padding(.top, 40)
                } else if viewModel.meals.isEmpty {
                    Text("급식이 없습니다")
                        .pickText(type: .body1, textColor: .Gray.gray600)
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
                    .padding(.bottom, 24)
                }
            }
        }
        .background(Color.white)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                HStack(spacing: 8) {
                    Image(systemName: "checkmark.shield.fill")
                        .foregroundColor(.Primary.primary500)
                    Text("PiCK")
                        .pickText(type: .heading3, textColor: .Primary.primary500)
                }
            }
        }
        .task {
            await viewModel.onAppear()
        }
    }
    
    private func dateString(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "MM월 dd일"
        formatter.timeZone = TimeZone(identifier: "Asia/Seoul")
        
        let formatted = formatter.string(from: date)
        
        let todayFormatter = DateFormatter()
        todayFormatter.locale = Locale(identifier: "ko_KR")
        todayFormatter.dateFormat = "MM월 dd일"
        todayFormatter.timeZone = TimeZone(identifier: "Asia/Seoul")
        let today = todayFormatter.string(from: Date())
        
        if formatted == today {
            return "오늘 \(formatted)"
        }
        return formatted
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
                .frame(width: 120, alignment: .leading) // Fixed width for alignment

            Spacer()
        }
        .frame(maxWidth: .infinity, minHeight: 140)
        .padding(.vertical, 10)
        .background(Color.Background.primary) // Check if Background.background exists, else .white
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.Primary.primary50, lineWidth: 2)
        )
    }
}

// Extension to support .subTitle1 if not present (PiCK iOS DesignSystem check)
// Assuming .subTitle1 exists based on previous file reads.
// If not, I will map it to .body1
