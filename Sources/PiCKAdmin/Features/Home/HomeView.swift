import SwiftUI

struct HomeView: View {
    @Environment(\.appRouter) var router: AppRouter
    @State var viewModel = HomeViewModel()

    var body: some View {
        ZStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Self Study Info Card
                    SelfStudyCard(adminMessage: viewModel.adminSelfStudyTeacher)
                        .frame(maxWidth: .infinity)
                        .frame(minHeight: 72)

                    // Outing Accept Section
                    if viewModel.isHomeroomTeacher {
                        AccordionView(
                            badge: viewModel.classroom,
                            title: "외출 수락"
                        ) {
                            VStack(spacing: 8) {
                                if viewModel.outingAcceptList.isEmpty {
                                    emptyStateView(message: "외출 신청이 없습니다")
                                }
 else {
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
                            .padding(.vertical, 12)
                        }
                    }

                    // Monitoring Sections
                    if viewModel.isSelfStudyTeacher {
                        AccordionView(
                            badge: viewModel.floor,
                            title: "외출자 확인"
                        ) {
                            VStack(spacing: 8) {
                                if viewModel.outingStudentList.isEmpty {
                                    emptyStateView(message: "외출자가 없습니다")
                                }
 else {
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
                            .padding(.vertical, 12)
                        }

                        AccordionView(
                            badge: viewModel.floor,
                            title: "교실 이동자 확인"
                        ) {
                            VStack(spacing: 8) {
                                if viewModel.classroomMoveList.isEmpty {
                                    emptyStateView(message: "교실 이동자가 없습니다")
                                }
 else {
                                    ForEach(viewModel.classroomMoveList) { item in
                                        PiCKClassroomMoveCell(
                                            studentNumber: studentNumber(
                                                grade: item.grade,
                                                classNum: item.classNum,
                                                num: item.num
                                            ),
                                            studentName: item.userName,
                                            startPeriod: item.start,
                                            endPeriod: item.end,
                                            currentClassroom: "\(item.grade)학년 \(item.classNum)반",
                                            moveToClassroom: item.classroomName,
                                            isSelected: false,
                                            onTap: {}
                                        )
                                    }
                                }
                            }
                            .padding(.vertical, 12)
                        }
                    }

                    // All Self Study Directors
                    AllSelfStudyCard(selfStudyDirector: viewModel.selfStudyDirector)
                        .frame(maxWidth: .infinity)
                }
                .padding(24)
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

    private func emptyStateView(message: String) -> some View {
        Text(message)
            .pickText(type: .body1, textColor: .Gray.gray600)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 24)
    }

    private var alertOverlay: some View {
        VStack {
            Spacer()
            HStack(spacing: 12) {
                Image(systemName: viewModel.alertSuccessType ? "checkmark.circle.fill" : "xmark.circle.fill")
                    .foregroundColor(viewModel.alertSuccessType ? .Primary.primary500 : .Error.error)
                Text(viewModel.alertMessage)
                    .pickText(type: .body1, textColor: .Normal.black)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(Color.Gray.gray50)
            .cornerRadius(24)
            .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 4)
            .padding(.bottom, 100)
        }
        .transition(AnyTransition.move(edge: .bottom).combined(with: .opacity))
        .animation(.easeInOut, value: viewModel.showAlert)
    }
}

// MARK: - Self Study Card
struct SelfStudyCard: View {
    let adminMessage: String

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(Date().koreanDateString())
                .pickText(type: .body2)
                .padding(.top, 14)
                .padding(.leading, 20)

            Spacer()

            Text(adminMessage.isEmpty ? "자습감독 정보를 불러오는 중입니다" : adminMessage)
                .pickText(type: .body1)
                .padding(.bottom, 14)
                .padding(.leading, 20)
        }
        .frame(maxWidth: .infinity, minHeight: 72, alignment: .topLeading)
        .background(Color(hex: "#F5F5F5"))
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color(hex: "#E0E0E0"), lineWidth: 1)
        )
    }
}

// MARK: - Accordion View
struct AccordionView<Content: View>: View {
    @State var isExpanded: Bool = false
    let badge: String
    let title: String
    @ViewBuilder let content: () -> Content

    var body: some View {
        VStack(spacing: 0) {
            Button(action: { withAnimation { isExpanded.toggle() } }) {
                HStack(spacing: 8) {
                    Image("bottomArrow", bundle: .module)
                        .foregroundColor(.Normal.black)
                        .rotationEffect(.degrees(isExpanded ? 180 : 0))
                    
                    Text(badge)
                        .pickText(type: .label1, textColor: .Primary.primary500)
                    
                    Text(title)
                        .pickText(type: .label1, textColor: .Normal.black)
                    
                    Spacer()
                }
                .padding(16)
                .background(Color.Normal.white)
            }
            .buttonStyle(PlainButtonStyle())

            if isExpanded {
                VStack(spacing: 0) {
                    content()
                }
                .padding(.bottom)
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
    let type: OutgoingType
    let onAccept: () -> Void
    let onReject: () -> Void

    var body: some View {
        HStack(spacing: 2) {
            HStack(spacing: 8) {
                Text("\(studentNumber) \(name)")
                    .pickText(type: .heading3, textColor: .Normal.black) // subTitle2 -> heading3
                
                Text(type.title)
                    .pickText(type: .body2, textColor: .Primary.primary400)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(
                        Capsule()
                            .strokeBorder(Color.Primary.primary400, lineWidth: 1)
                    )
            }

            Spacer()

            HStack(spacing: 8) {
                Button(action: onReject) {
                    Text("거절")
                        .pickText(type: .body2, textColor: .Normal.white)
                        .padding(.horizontal, 15)
                        .padding(.vertical, 8)
                        .background(Color.Error.error)
                        .cornerRadius(8)
                }

                Button(action: onAccept) {
                    Text("승인")
                        .pickText(type: .body2, textColor: .Normal.white)
                        .padding(.horizontal, 15)
                        .padding(.vertical, 8)
                        .background(Color.Primary.primary500)
                        .cornerRadius(8)
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color.Gray.gray50)
        .cornerRadius(12)
    }
}

// MARK: - Outing Cell
struct OutingCell: View {
    let studentNumber: String
    let name: String
    let type: OutgoingType

    var body: some View {
        HStack(spacing: 2) {
            Text("\(studentNumber) \(name)")
                .pickText(type: .heading3, textColor: .Normal.black) // subTitle2 -> heading3

            Spacer()

            HStack(spacing: 8) {
                Button(action: {}) {
                    Text(type.title)
                        .pickText(type: .body2, textColor: .Normal.white)
                        .padding(.horizontal, 15)
                        .padding(.vertical, 8)
                        .background(type == .outgoing ? Color.Primary.primary500 : Color.Primary.primary300)
                        .cornerRadius(8)
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color.Gray.gray50)
        .cornerRadius(12)
    }
}

// MARK: - Classroom Move Cell
struct PiCKClassroomMoveCell: View {
    let studentNumber: String
    let studentName: String
    let startPeriod: Int
    let endPeriod: Int
    let currentClassroom: String
    let moveToClassroom: String
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 0) {
                HStack(spacing: 12) {
                    Text("\(studentNumber) \(studentName)")
                        .pickText(type: .button1, textColor: .Normal.black) // subTitle3 -> button1

                    Text("\(startPeriod)교시 - \(endPeriod)교시")
                        .pickText(type: .body2, textColor: .Gray.gray900)
                }
                .padding(.top, 16)
                .padding(.horizontal, 16)

                HStack(spacing: 8) {
                    Text(currentClassroom)
                        .pickText(type: .body1, textColor: .Normal.black)
                    
                    Image(systemName: "arrow.right")
                        .font(.system(size: 14))
                        .foregroundColor(.Normal.black)
                    
                    Text(moveToClassroom)
                        .pickText(type: .body1, textColor: .Normal.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.Primary.primary300)
                        .cornerRadius(14)
                }
                .padding(.top, 8)
                .padding(.horizontal, 16)
                .padding(.bottom, 16)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.Gray.gray50)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(borderColor, lineWidth: 2)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }

    private var borderColor: Color {
        isSelected ? .Primary.primary500 : .clear
    }
}

struct AllSelfStudyCard: View {
    let selfStudyDirector: [SelfStudyDirector]

    var body: some View {
        ZStack {
            HStack(spacing: 0) {
                if selfStudyDirector.isEmpty {
                    VStack(alignment: .leading, spacing: 0) {
                        Spacer()
                        Text("오늘은\n자습감독 선생님이 없습니다.")
                            .pickText(type: .body2, textColor: .Normal.black)
                        Spacer()
                    }
                    .padding(.leading, 20)
                } else {
                    VStack(alignment: .leading, spacing: 0) {
                        Text("오늘의 자습 감독 선생님 입니다")
                            .pickText(type: .body2)
                            .padding(.top, 27.5)

                        VStack(alignment: .leading, spacing: 12) {
                            ForEach(selfStudyDirector, id: \.floor) { director in
                                HStack(spacing: 16) {
                                    Text("\(director.floor)층")
                                        .pickText(type: .body2, textColor: .Primary.primary500)

                                    Text("\(director.teacherName) 선생님")
                                        .pickText(type: .button1, textColor: .Normal.black)
                                }
                            }
                        }
                        .padding(.top, 16)

                        Spacer()
                    }
                    .padding(.leading, 20)
                }

                Spacer()
            }

            HStack {
                Spacer()
                Image("calendar", bundle: .module)
                    .renderingMode(.original)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 120, height: 120)
                    .padding(.trailing, 20)
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: 172)
        .background(Color(hex: "#F5F5F5"))
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color(hex: "#E0E0E0"), lineWidth: 1)
        )
    }
}

// MARK: - Date Extension
extension Date {
    func koreanDateString() -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "M월 d일 EEEE"
        formatter.timeZone = TimeZone(identifier: "Asia/Seoul")
        return formatter.string(from: self)
    }
    
    static func todayString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.timeZone = TimeZone(identifier: "Asia/Seoul")
        return formatter.string(from: Date())
    }
}
