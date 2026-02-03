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
                            .padding(.vertical, 12)
                        }

                        AccordionView(
                            badge: viewModel.floor,
                            title: "교실 이동자 확인"
                        ) {
                            VStack(spacing: 8) {
                                if viewModel.classroomMoveList.isEmpty {
                                    emptyStateView(message: "교실 이동자가 없습니다")
                                } else {
                                    ForEach(viewModel.classroomMoveList) { item in
                                        AcceptClassroomMoveCell(
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
                await viewModel.loadInitialDataIfNeeded()
            }

            // Alert Overlay
            if viewModel.showAlert {
                alertOverlay
            }
        }
        .background(Color.white)
    }

    private func studentNumber(grade: Int, classNum: Int, num: Int) -> String {
        return "\(grade)\(classNum)\(num < 10 ? "0" : "")\(num)"
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
