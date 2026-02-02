import SwiftUI

struct AllTabView: View {
    @State var viewModel = AllTabViewModel()
    @Environment(\.appRouter) var router: AppRouter
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                TeacherInfoView(teacherName: viewModel.teacherName)
                    .padding(.top, 24)
                
                AllTabMenuList(
                    onOutListTap: { router.navigate(to: .outList) },
                    onClassroomMoveListTap: { router.navigate(to: .classroomMoveList) },
                    onLogoutTap: { viewModel.showLogoutAlert = true },
                    onCheckTeacherTap: { router.navigate(to: .checkSelfStudyTeacher) },
                    onBugReportTap: { router.navigate(to: .bugReport) },
                    onChangePasswordTap: { router.navigate(to: .changePassword) },
                    onSelfStudyCheckTap: { router.navigate(to: .selfStudyCheck) },
                    onOutingHistoryTap: { router.navigate(to: .outingHistory) },
                    onResignTap: { viewModel.showResignAlert = true }
                )
                .padding(.top, 32)
            }
        }
        .background(Color.Gray.gray50) // Background color check
        .task {
            await viewModel.fetchMyName()
        }
        .alert("로그아웃", isPresented: $viewModel.showLogoutAlert) {
            Button("취소", role: .cancel) {}
            Button("확인", role: .destructive) {
                viewModel.logout()
                router.popToRoot()
            }
        } message: {
            Text("정말 로그아웃 하시겠습니까?")
        }
        .alert("회원탈퇴", isPresented: $viewModel.showResignAlert) {
            Button("취소", role: .cancel) {}
            Button("확인", role: .destructive) {
                Task {
                    await viewModel.resign()
                    router.popToRoot()
                }
            }
        } message: {
            Text("정말로 탈퇴하시겠습니까?\n탈퇴 후에는 계정을 복구할 수 없습니다.")
        }
    }
}

// MARK: - Components

struct TeacherInfoView: View {
    let teacherName: String
    
    var body: some View {
        HStack(spacing: 0) {
            Image(systemName: "person.circle.fill")
                .resizable()
                .scaledToFit()
                .foregroundColor(.Gray.gray300)
                .frame(width: 60, height: 60)
                .padding(.leading, 24)
                .padding(.top, 12)
            
            VStack(alignment: .leading, spacing: 4) {
                Text("대덕소프트웨어마이스터고등학교")
                    .pickText(type: .label1, textColor: .Normal.black)
                
                Text("\(teacherName) 선생님")
                    .pickText(type: .label1, textColor: .Normal.black)
            }
            .padding(.leading, 24)
            .padding(.top, 12)
            
            Spacer()
        }
        .frame(maxWidth: .infinity)
        .frame(height: 84)
        .background(Color.Normal.white)
    }
}

struct AllTabMenuList: View {
    let onOutListTap: () -> Void
    let onClassroomMoveListTap: () -> Void
    let onLogoutTap: () -> Void
    let onCheckTeacherTap: () -> Void
    let onBugReportTap: () -> Void
    let onChangePasswordTap: () -> Void
    let onSelfStudyCheckTap: () -> Void
    let onOutingHistoryTap: () -> Void
    let onResignTap: () -> Void

    var body: some View {
        MenuListView(
            sections: [
                MenuSectionModel(title: "출결 확인", items: [
                    MenuItemModel(
                        iconName: "mappin.and.ellipse",
                        title: "외출자 목록",
                        action: onOutListTap
                    ),
                    MenuItemModel(
                        iconName: "clock",
                        title: "자습시간 출결",
                        action: onSelfStudyCheckTap
                    ),
                    MenuItemModel(
                        iconName: "arrow.left.arrow.right",
                        title: "교실 이동 현황",
                        action: onClassroomMoveListTap
                    ),
                    MenuItemModel(
                        iconName: "book.closed",
                        title: "이전 외출기록",
                        action: onOutingHistoryTap
                    )
                ]),
                MenuSectionModel(title: "도움말", items: [
                    MenuItemModel(
                        iconName: "face.smiling",
                        title: "자습 감독 선생님 확인",
                        action: onCheckTeacherTap
                    ),
                    MenuItemModel(
                        iconName: "ladybug",
                        title: "버그 제보",
                        action: onBugReportTap
                    )
                ]),
                MenuSectionModel(title: "계정", items: [
                    MenuItemModel(
                        iconName: "lock.rotation",
                        title: "비밀번호 변경",
                        action: onChangePasswordTap
                    ),
                    MenuItemModel(
                        iconName: "rectangle.portrait.and.arrow.right",
                        title: "로그아웃",
                        iconColor: .Error.error,
                        action: onLogoutTap
                    ),
                    MenuItemModel(
                        iconName: "person.crop.circle.badge.minus",
                        title: "회원탈퇴",
                        iconColor: .Error.error,
                        action: onResignTap
                    )
                ])
            ]
        )
    }
}

struct MenuListView: View {
    let sections: [MenuSectionModel]
    
    var body: some View {
        VStack(spacing: 0) {
            ForEach(sections) { section in
                MenuSectionView(section: section)
            }
        }
        .padding(.leading, 24)
    }
}

struct MenuSectionModel: Identifiable {
    let id = UUID()
    let title: String
    let items: [MenuItemModel]
}

struct MenuItemModel: Identifiable {
    let id = UUID()
    let iconName: String
    let title: String
    let iconColor: Color
    let action: (() -> Void)?
    
    init(
        iconName: String,
        title: String,
        iconColor: Color = .Primary.primary500,
        action: (() -> Void)? = nil
    ) {
        self.iconName = iconName
        self.title = title
        self.iconColor = iconColor
        self.action = action
    }
}

struct MenuSectionView: View {
    let section: MenuSectionModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(section.title)
                .pickText(type: .label1)
                .foregroundColor(.Gray.gray400)
                .padding(.top, 32)
                .padding(.bottom, 16)

            VStack(spacing: 0) {
                ForEach(section.items) { item in
                    MenuItemCell(item: item)
                }
            }
        }
    }
}

struct MenuItemCell: View {
    let item: MenuItemModel
    
    var body: some View {
        Button(action: {
            item.action?()
        }) {
            HStack(spacing: 20) {
                Image(systemName: item.iconName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 24, height: 24)
                    .foregroundColor(item.iconColor)
                
                Text(item.title)
                    .pickText(type: .label1, textColor: .Normal.black)
                
                Spacer()
            }
            .padding(.vertical, 20)
            .background(Color.Normal.white)
            .background(Color.white.opacity(0.001))
        }
        .buttonStyle(.plain)
    }
}
