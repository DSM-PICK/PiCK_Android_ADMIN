import SwiftUI

struct HomeView: View {
    @EnvironmentObject var router: AppRouter
    @StateObject var viewModel = HomeViewModel()

    var body: some View {
        ZStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Self Study Info Card
                    SelfStudyInfoCard(message: viewModel.adminSelfStudyTeacher)

                    // Outing Accept Section (for Homeroom Teacher)
                    if viewModel.isHomeroomTeacher {
                        AccordionSection(
                            badge: viewModel.classroom,
                            title: "외출 수락",
                            isEmpty: viewModel.outingAcceptList.isEmpty,
                            emptyMessage: "외출 신청이 없습니다"
                        ) {
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

                    // Self Study Teacher Sections
                    if viewModel.isSelfStudyTeacher {
                        // Outing Student List
                        AccordionSection(
                            badge: viewModel.floor,
                            title: "외출자 확인",
                            isEmpty: viewModel.outingStudentList.isEmpty,
                            emptyMessage: "외출자가 없습니다"
                        ) {
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

                        // Classroom Move List
                        AccordionSection(
                            badge: viewModel.floor,
                            title: "교실 이동자 확인",
                            isEmpty: viewModel.classroomMoveList.isEmpty,
                            emptyMessage: "교실 이동자가 없습니다"
                        ) {
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

                    // All Self Study Directors
                    AllSelfStudySection(selfStudyDirector: viewModel.selfStudyDirector)
                }
                .padding(24)
            }
            .navigationBarBackButtonHidden(true)
            #if os(iOS)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    HStack(spacing: 8) {
                        Image(systemName: "checkmark.shield.fill")
                            .foregroundColor(.Primary.primary500)
                        Text("PiCK")
                            .pickText(type: .heading3, textColor: .Primary.primary500)
                    }
                }

                ToolbarItem(placement: .topBarTrailing) {
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
            #endif
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
        .animation(.spring(), value: viewModel.showAlert)
    }
}

// MARK: - Self Study Info Card
struct SelfStudyInfoCard: View {
    let message: String

    var body: some View {
        HStack {
            Image(systemName: "info.circle.fill")
                .foregroundColor(.Primary.primary500)
            Text(message)
                .pickText(type: .body1)
            Spacer()
        }
        .padding(16)
        .background(Color.Primary.primary50)
        .cornerRadius(12)
    }
}

// MARK: - Accordion Section
struct AccordionSection<Content: View>: View {
    let badge: String
    let title: String
    let isEmpty: Bool
    let emptyMessage: String
    @ViewBuilder let content: () -> Content

    @State var isExpanded: Bool = true

    var body: some View {
        VStack(spacing: 0) {
            // Header
            Button(action: { withAnimation { isExpanded.toggle() } }) {
                HStack {
                    Text(badge)
                        .pickText(type: .caption1, textColor: .Primary.primary500)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.Primary.primary50)
                        .cornerRadius(4)

                    Text(title)
                        .pickText(type: .body1)

                    Spacer()

                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .foregroundColor(.Gray.gray500)
                }
            }
            .padding(16)
            .background(Color.Normal.white)

            // Content
            if isExpanded {
                if isEmpty {
                    Text(emptyMessage)
                        .pickText(type: .body1, textColor: .Gray.gray600)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 24)
                } else {
                    VStack(spacing: 8) {
                        content()
                    }
                    .padding(.vertical, 12)
                    .padding(.horizontal, 16)
                }
            }
        }
        .background(Color.Normal.white)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
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

// MARK: - All Self Study Section
struct AllSelfStudySection: View {
    let selfStudyDirector: [SelfStudyDirector]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("전체 자습감독")
                .pickText(type: .body1)

            VStack(spacing: 8) {
                ForEach(selfStudyDirector, id: \.floor) { director in
                    HStack {
                        Text("\(director.floor)층")
                            .pickText(type: .body2, textColor: .Gray.gray600)
                        Spacer()
                        Text(director.teacherName)
                            .pickText(type: .body2)
                    }
                    .padding(12)
                    .background(Color.Gray.gray50)
                    .cornerRadius(8)
                }
            }
        }
        .padding(16)
        .background(Color.Normal.white)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
}
