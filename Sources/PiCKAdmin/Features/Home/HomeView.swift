import SwiftUI

struct HomeView: View {
    @Environment(\.appRouter) var router: AppRouter
    @State var viewModel = HomeViewModel()

    var body: some View {
        ZStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Self Study Info Card (SelfStudyView)
                    SelfStudyCard(adminMessage: viewModel.adminSelfStudyTeacher)
                        .frame(height: 120)

                    // Outing Accept Section (AccordionView)
                    if viewModel.isHomeroomTeacher {
                        AccordionView(
                            badge: viewModel.classroom,
                            title: "외출 수락"
                        ) {
                            if viewModel.outingAcceptList.isEmpty {
                                Text("외출 신청이 없습니다")
                                    .pickText(type: .body2, textColor: .Gray.gray600)
                                    .padding(.vertical, 12)
                            } else {
                                ForEach(viewModel.outingAcceptList) { item in
                                    AcceptCell(
                                        studentNumber: studentNumber(
                                            grade: item.grade,
                                            classNum: item.classNum,
                                            num: item.num
                                        ),
                                        name: item.userName,
                                        type: item.type,
                                        onAccept: {
                                            Task {
                                                if item.type == .outgoing {
                                                    await viewModel.acceptApplication(id: item.id)
                                                } else {
                                                    await viewModel.acceptEarlyReturn(id: item.id)
                                                }
                                            }
                                        },
                                        onReject: {
                                            Task {
                                                if item.type == .outgoing {
                                                    await viewModel.rejectApplication(id: item.id)
                                                } else {
                                                    await viewModel.rejectEarlyReturn(id: item.id)
                                                }
                                            }
                                        }
                                    )
                                }
                            }
                        }
                    }

                    // Monitor Sections (AccordionView)
                    if viewModel.isSelfStudyTeacher {
                        // Outing Student List
                        AccordionView(
                            badge: viewModel.floor,
                            title: "외출자 확인"
                        ) {
                            if viewModel.outingStudentList.isEmpty {
                                Text("외출자가 없습니다")
                                    .pickText(type: .body2, textColor: .Gray.gray600)
                                    .padding(.vertical, 12)
                            } else {
                                ForEach(viewModel.outingStudentList) { item in
                                    OutingCell(
                                        studentNumber: studentNumber(
                                            grade: item.grade,
                                            classNum: item.classNum,
                                            num: item.num
                                        ),
                                        name: item.userName,
                                        type: item.type
                                    )
                                }
                            }
                        }

                        // Classroom Move List
                        AccordionView(
                            badge: viewModel.floor,
                            title: "교실 이동자 확인"
                        ) {
                            if viewModel.classroomMoveList.isEmpty {
                                Text("교실 이동자가 없습니다")
                                    .pickText(type: .body2, textColor: .Gray.gray600)
                                    .padding(.vertical, 12)
                            } else {
                                ForEach(viewModel.classroomMoveList) { item in
                                    ClassroomMoveCell(
                                        studentNumber: studentNumber(
                                            grade: item.grade,
                                            classNum: item.classNum,
                                            num: item.num
                                        ),
                                        studentName: item.userName,
                                        startPeriod: item.start,
                                        endPeriod: item.end,
                                        currentClassroom: "\(item.grade)학년 \(item.classNum)반",
                                        moveToClassroom: item.classroomName
                                    )
                                }
                            }
                        }
                    }

                    // All Self Study Directors (AllSelfStudyView)
                    AllSelfStudyCard(selfStudyDirector: viewModel.selfStudyDirector)
                }
                .padding(24)
            }
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    HStack(spacing: 8) {
                        Image(systemName: "checkmark.shield.fill")
                            .foregroundColor(.Primary.primary500)
                        Text("PiCK")
                            .pickText(type: .heading3, textColor: .Primary.primary500)
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button(action: { router.navigate(to: .outList) }) {
                            Label("외출 목록", systemImage: "list.bullet")
                        }
                        Button(action: { router.navigate(to: .classroomMoveList) }) {
                            Label("교실 이동", systemImage: "arrow.left.arrow.right")
                        }
                        Button(action: { router.navigate(to: .bugReport) }) {
                            Label("버그 신고", systemImage: "ant")
                        }
                        Divider()
                        Button(role: .destructive, action: logout) {
                            Label("로그아웃", systemImage: "rectangle.portrait.and.arrow.right")
                        }
                    } label: {
                        Image(systemName: "line.3.horizontal")
                            .foregroundColor(.Normal.black)
                    }
                }
            }
            .task {
                await viewModel.fetchSelfStudyDirector(date: Date.todayString())
                await viewModel.fetchAdminSelfStudyInfo()
                await viewModel.fetchSelfStudyAndClassroom()
            }

            // Alert Overlay
            if viewModel.showAlert {
                alertOverlay
            }
        }
    }

    private func studentNumber(grade: Int, classNum: Int, num: Int) -> String {
        return "\(grade)\(classNum)\(num < 10 ? "0" : "")\(num)"
    }

    private func logout() {
        JwtStore.shared.clearTokens()
        router.popToRoot()
    }

    private var alertOverlay: some View {
        VStack {
            Spacer()
            HStack {
                Image(systemName: viewModel.alertSuccessType ? "checkmark.circle.fill" : "xmark.circle.fill")
                    .foregroundColor(viewModel.alertSuccessType ? .Primary.primary500 : .Error.error)
                Text(viewModel.alertMessage)
                    .pickText(type: .body2, textColor: .Normal.white)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .background(Color.Gray.gray800)
            .cornerRadius(12)
            .padding(.bottom, 100)
        }
        .transition(AnyTransition.move(edge: .bottom).combined(with: .opacity))
        .animation(.easeInOut, value: viewModel.showAlert)
    }
}

// MARK: - Self Study Card (Matching SelfStudyView)
struct SelfStudyCard: View {
    let adminMessage: String

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(Date.koreanDateString())
                .pickText(type: .body2)
                .padding(.top, 14)
                .padding(.leading, 20)
            
            Spacer()
            
            // Note: Simple text for now as complex AttributedString regex might be unstable in Skip/SwiftUI-Android
            Text(adminMessage.isEmpty ? "자습감독 정보를 불러오는 중입니다" : adminMessage)
                .pickText(type: .body1)
                .padding(.bottom, 14)
                .padding(.leading, 20)
        }
        .frame(maxWidth: .infinity, alignment: .topLeading)
        .background(Color.Gray.gray50)
        .cornerRadius(8)
    }
}

// MARK: - Accordion View (Matching AccordionView)
struct AccordionView<Content: View>: View {
    @State var isExpanded: Bool = false
    let badge: String
    let title: String
    @ViewBuilder let content: () -> Content

    var body: some View {
        VStack(spacing: 0) {
            Button(action: { withAnimation { isExpanded.toggle() } }) {
                HStack(spacing: 8) {
                    // Left Arrow (Simulated with system image)
                    Image(systemName: "chevron.down")
                        .foregroundColor(.Normal.black)
                        .rotationEffect(.degrees(isExpanded ? 180 : 0))
                    
                    Text(badge)
                        .pickText(type: .label1, textColor: .Primary.primary500)
                    
                    Text(title)
                        .pickText(type: .label1, textColor: .Normal.black)
                    
                    Spacer()
                }
                .padding(16)
                .background(Color.Normal.white) // Assuming white background for header
            }

            if isExpanded {
                VStack(spacing: 8) {
                    content()
                }
                .padding(.bottom, 16)
                .padding(.horizontal, 16)
            }
        }
        .background(Color.Normal.white) // Overall background
        // Note: iOS version didn't seem to have card styling (shadow/radius) on the View itself, 
        // but often it's used in a context. I'll keep it simple or match surrounding style.
        // The iOS AccordionView code didn't show cornerRadius/shadow. 
        // But previously I added them. I will REMOVE them to match iOS code exactly, 
        // or keep them if they were applied by parent. 
        // Looking at iOS HomeView (not visible here), it likely composes them.
        // I will add slight radius/shadow for better look on Android if not specified, 
        // or stick to flat if iOS is flat. 
        // Let's stick to the previous card style for container but use the NEW internal layout.
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
}

// MARK: - All Self Study Card (Matching AllSelfStudyView)
struct AllSelfStudyCard: View {
    let selfStudyDirector: [SelfStudyDirector]

    var body: some View {
        ZStack {
            if selfStudyDirector.isEmpty {
                VStack(alignment: .leading) {
                    Text("오늘은\n자습감독 선생님이 없습니다.")
                        .pickText(type: .body1, textColor: .Normal.black) // label2 mapping
                        .padding(.top, 70)
                        .padding(.leading, 20)
                        .padding(.bottom, 70)
                    Spacer()
                }
                .frame(maxWidth: .infinity, alignment: .topLeading)
            } else {
                VStack(alignment: .leading, spacing: 0) {
                    Text("오늘의 자습 감독 선생님 입니다")
                        .pickText(type: .body1) // label2 mapping
                        .padding(.top, 27.5)
                        .padding(.leading, 20)
                    
                    VStack(alignment: .leading, spacing: 12) {
                        ForEach(selfStudyDirector, id: \.floor) { director in
                            HStack(spacing: 16) {
                                Text("\(director.floor)층")
                                    .pickText(type: .body1, textColor: .Primary.primary500) // label2 mapping
                                
                                Text("\(director.teacherName) 선생님")
                                    .pickText(type: .heading3, textColor: .Normal.black) // subTitle2 mapping
                            }
                        }
                    }
                    .padding(.top, 16)
                    .padding(.leading, 20)
                    
                    Spacer()
                }
                .frame(maxWidth: .infinity, alignment: .topLeading)
            }
        }
        .frame(height: 172)
        .background(Color.Gray.gray50)
        .cornerRadius(8)
    }
}

// MARK: - Accept Cell
struct AcceptCell: View {
    let studentNumber: String
    let name: String
    let type: OutingType
    let onAccept: () -> Void
    let onReject: () -> Void

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("\(studentNumber) \(name)")
                    .pickText(type: .body1)
                Text(type.displayName)
                    .pickText(type: .caption1, textColor: .Gray.gray600)
            }

            Spacer()

            HStack(spacing: 8) {
                Button(action: onReject) {
                    Text("거절")
                        .pickText(type: .button2, textColor: .Error.error)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Color.Error.errorLight)
                        .cornerRadius(8)
                }

                Button(action: onAccept) {
                    Text("승인")
                        .pickText(type: .button2, textColor: .Normal.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Color.Primary.primary500)
                        .cornerRadius(8)
                }
            }
        }
        .padding(12)
        .background(Color.Gray.gray50)
        .cornerRadius(8)
    }
}

// MARK: - Outing Cell
struct OutingCell: View {
    let studentNumber: String
    let name: String
    let type: OutingType

    var body: some View {
        HStack {
            Text("\(studentNumber) \(name)")
                .pickText(type: .body1)
            Spacer()
            Text(type.displayName)
                .pickText(type: .caption1, textColor: .Primary.primary500)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color.Primary.primary50)
                .cornerRadius(4)
        }
        .padding(12)
        .background(Color.Gray.gray50)
        .cornerRadius(8)
    }
}

// MARK: - Classroom Move Cell
struct ClassroomMoveCell: View {
    let studentNumber: String
    let studentName: String
    let startPeriod: Int
    let endPeriod: Int
    let currentClassroom: String
    let moveToClassroom: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("\(studentNumber) \(studentName)")
                    .pickText(type: .body1)
                Spacer()
                Text("\(startPeriod)교시 ~ \(endPeriod)교시")
                    .pickText(type: .caption1, textColor: .Gray.gray600)
            }

            HStack(spacing: 8) {
                Text(currentClassroom)
                    .pickText(type: .caption1, textColor: .Gray.gray600)
                Image(systemName: "arrow.right")
                    .foregroundColor(.Gray.gray400)
                    .font(.caption)
                Text(moveToClassroom)
                    .pickText(type: .caption1, textColor: .Primary.primary500)
            }
        }
        .padding(12)
        .background(Color.Gray.gray50)
        .cornerRadius(8)
    }
}

// MARK: - Date Extension
extension Date {
    static func koreanDateString() -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "M월 d일 EEEE"
        return formatter.string(from: Date())
    }
}
