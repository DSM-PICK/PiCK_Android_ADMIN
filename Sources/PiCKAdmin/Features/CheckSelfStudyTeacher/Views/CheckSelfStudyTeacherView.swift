import SwiftUI

struct CheckSelfStudyTeacherView: View {
    @Environment(\.appRouter) var router: AppRouter
    @State var viewModel = CheckSelfStudyTeacherViewModel()
    @State var selectedDate = Date()
    @State var currentPage = Date()
    @State var isWeekMode = true

    var calendar: Calendar {
        var cal = Calendar.current
        cal.timeZone = TimeZone(identifier: "Asia/Seoul") ?? TimeZone.current
        return cal
    }

    var body: some View {
        ZStack {
            Color.Background.background
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // 커스텀 네비게이션 바
                navigationBar

                // 컨텐츠 영역
                VStack(alignment: .leading, spacing: 0) {
                    titleView(selectedDate: viewModel.selectedDate)
                        .padding(.top, 24)
                        .padding(.leading, 24)

                    if !viewModel.teachers.isEmpty {
                        teacherListView(teachers: viewModel.teachers)
                            .padding(.leading, 24)
                            .padding(.top, 32)
                    }

                    Spacer()
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }

            if viewModel.teachers.isEmpty && !viewModel.isLoading {
                VStack {
                    Spacer()
                    Text("등록된 자습 감독 선생님이 없습니다.")
                        .pickText(type: .body1, textColor: .Normal.black)
                    Spacer()
                    Spacer()
                }
            }

            VStack {
                Spacer()

                PiCKCalendarView(
                    calendarType: .selfStudy,
                    selectedDate: $selectedDate,
                    currentPage: $currentPage,
                    isWeekMode: $isWeekMode,
                    dateSelected: { date in
                        selectedDate = date
                        Task { @MainActor in
                            await viewModel.fetchSelfStudyTeacher(for: date)
                        }
                    }
                )
                .padding(.bottom, 16)
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden)
        .task { @MainActor in
            await viewModel.fetchSelfStudyTeacher(for: selectedDate)
        }
    }

    private var navigationBar: some View {
        ZStack {
            // 중앙 타이틀
            Text("자습 감독 선생님 확인")
                .pickText(type: .subTitle1, textColor: .Normal.black)

            // 뒤로가기 버튼
            HStack {
                Button {
                    router.pop()
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(.Normal.black)
                }
                .padding(.leading, 16)

                Spacer()
            }
        }
        .frame(height: 56)
        .background(Color.Background.background)
    }

    @ViewBuilder
    private func titleView(selectedDate: Date) -> some View {
        let isToday = calendar.isDateInToday(selectedDate)
        let dateString = formatDateString(selectedDate)

        VStack(alignment: .leading, spacing: 0) {
            if isToday {
                Text(dateString + ",")
                    .pickText(type: .heading4, textColor: .Normal.black)
                HStack(spacing: 0) {
                    Text("오늘의 자습 감독")
                        .pickText(type: .heading4, textColor: .Primary.primary500)
                    Text(" 선생님입니다.")
                        .pickText(type: .heading4, textColor: .Normal.black)
                }
            } else {
                Text(dateString + "의")
                    .pickText(type: .heading4, textColor: .Primary.primary500)
                Text("자습 감독 선생님입니다.")
                    .pickText(type: .heading4, textColor: .Normal.black)
            }
        }
    }

    @ViewBuilder
    private func teacherListView(teachers: [SelfStudyTeacherEntity]) -> some View {
        HStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 32) {
                ForEach(teachers) { teacher in
                    Text("\(teacher.floor)층")
                        .pickText(type: .body1, textColor: .Gray.gray800)
                }
            }

            VStack(alignment: .leading, spacing: 32) {
                ForEach(teachers) { teacher in
                    Text("\(teacher.teacherName) 선생님")
                        .pickText(type: .body1, textColor: .Normal.black)
                }
            }

            Spacer()
        }
    }

    private func formatDateString(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.timeZone = TimeZone(identifier: "Asia/Seoul")
        formatter.dateFormat = "M월 d일"
        return formatter.string(from: date)
    }
}
