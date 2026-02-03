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
        .background(Color.Gray.gray50)
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
            router.selectedTab = 4
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
