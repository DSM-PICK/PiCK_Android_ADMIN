import SwiftUI

struct ContentView: View {
    @State var router = AppRouter()
    @State var isCheckingAuth = true

    var body: some View {
        Group {
            if isCheckingAuth {
                authLoadingView
            } else if router.path.last == .home {
                homeView
            } else {
                navigationStackView
            }
        }
        .onAppear(perform: checkAuthStatus)
        .environment(\.appRouter, router)
    }

    private var authLoadingView: some View {
        VStack {
            ProgressView()
        }
    }

    private var homeView: some View {
        MainTabView()
            .environment(\.appRouter, router)
    }

    private var navigationStackView: some View {
        ZStack {
            if router.path.isEmpty {
                OnboardingView()
                    .environment(\.appRouter, router)
                    .transition(AnyTransition.opacity.combined(with: AnyTransition.scale(scale: 0.95)))
                    .zIndex(0)
            }

            if !router.path.isEmpty {
                NavigationStack(path: Binding(
                    get: { router.path },
                    set: { router.path = $0 }
                )) {
                    Color.clear
                        .navigationDestination(for: AppRoute.self) { route in
                            routeDestination(for: route)
                        }
                }
                .transition(AnyTransition.asymmetric(
                    insertion: AnyTransition.offset(x: 0, y: 20).combined(with: AnyTransition.opacity),
                    removal: AnyTransition.opacity.combined(with: AnyTransition.scale(scale: 1.05))
                ))
                .zIndex(1)
            }
        }
        .animation(.easeInOut(duration: 0.35), value: router.path.count)
    }

    @ViewBuilder
    private func routeDestination(for route: AppRoute) -> some View {
        switch route {
        case .onboarding:
            OnboardingView()
                .environment(\.appRouter, router)
        case .signin:
            SigninView()
                .environment(\.appRouter, router)
        case .secretKey:
            SecretKeyView()
        case let .email(secretKey):
            EmailVerifyView(secretKey: secretKey)
        case let .password(secretKey, accountId, code):
            PasswordView(secretKey: secretKey, accountId: accountId, code: code)
        case let .infoSetting(secretKey, accountId, code, password):
            InfoSettingView(secretKey: secretKey, accountId: accountId, code: code, password: password)
        case .home:
            EmptyView()
        case .outList:
            OutListView()
        case .checkSelfStudyTeacher:
            CheckSelfStudyTeacherView()
        case .bugReport:
            BugReportView(router: router)
        case .changePassword:
            ChangePasswordView()
        case let .newPassword(accountId, code):
            NewPasswordView(accountId: accountId, code: code, router: router)
        case .selfStudyCheck:
            SelfStudyCheckView()
        case .classroomMoveList:
            ClassroomMoveListView()
        case .outingHistory:
            OutingHistoryView()
        }
    }

    private func checkAuthStatus() {
        let hasLaunched = UserDefaultStorage.shared.getBool(forKey: .hasLaunchedBefore)

        if !hasLaunched {
            JwtStore.shared.clearTokens()
            UserDefaultStorage.shared.set(to: true, forKey: .hasLaunchedBefore)
        }

        if JwtStore.shared.hasValidToken {
            router.path = [.home]
        }
        isCheckingAuth = false
    }
}
