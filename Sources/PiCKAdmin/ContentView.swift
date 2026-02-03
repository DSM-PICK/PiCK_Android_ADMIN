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
            SecretKeyView(router: router)
        case let .email(secretKey):
            EmailVerifyView(secretKey: secretKey, router: router)
        case let .password(secretKey, accountId, code):
            PasswordView(secretKey: secretKey, accountId: accountId, code: code, router: router)
        case let .infoSetting(secretKey, accountId, code, password):
            InfoSettingView(secretKey: secretKey, accountId: accountId, code: code, password: password, router: router)
        case .home:
            EmptyView()
        case .outList:
            OutListView(router: router)
        case .checkSelfStudyTeacher:
            CheckSelfStudyTeacherView(router: router)
        case .bugReport:
            BugReportView(router: router)
        case .changePassword:
            ChangePasswordView(router: router)
        case let .newPassword(accountId, code):
            NewPasswordView(accountId: accountId, code: code, router: router)
        case .selfStudyCheck:
            SelfStudyCheckView(router: router)
        case .classroomMoveList:
            ClassroomMoveListView(router: router)
        case .outingHistory:
            OutingHistoryView(router: router)
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

// MARK: - Placeholder Views (TODO: Implement)

struct SecretKeyView: View {
    var router: AppRouter

    var body: some View {
        PlaceholderView(title: "시크릿 키 입력", backAction: { router.pop() })
    }
}

struct EmailVerifyView: View {
    let secretKey: String
    var router: AppRouter

    var body: some View {
        PlaceholderView(title: "이메일 인증", backAction: { router.pop() })
    }
}

struct PasswordView: View {
    let secretKey: String
    let accountId: String
    let code: String
    var router: AppRouter

    var body: some View {
        PlaceholderView(title: "비밀번호 설정", backAction: { router.pop() })
    }
}

struct InfoSettingView: View {
    let secretKey: String
    let accountId: String
    let code: String
    let password: String
    var router: AppRouter

    var body: some View {
        PlaceholderView(title: "정보 설정", backAction: { router.pop() })
    }
}

struct OutListView: View {
    var router: AppRouter

    var body: some View {
        PlaceholderView(title: "외출 목록", backAction: { router.pop() })
    }
}


struct BugReportView: View {
    var router: AppRouter

    var body: some View {
        PlaceholderView(title: "버그 신고", backAction: { router.pop() })
    }
}

struct ChangePasswordView: View {
    var router: AppRouter

    var body: some View {
        PlaceholderView(title: "비밀번호 변경", backAction: { router.pop() })
    }
}

struct NewPasswordView: View {
    let accountId: String
    let code: String
    var router: AppRouter

    var body: some View {
        PlaceholderView(title: "새 비밀번호", backAction: { router.pop() })
    }
}


struct ClassroomMoveListView: View {
    var router: AppRouter

    var body: some View {
        PlaceholderView(title: "교실 이동 목록", backAction: { router.pop() })
    }
}


// MARK: - Placeholder View Component
struct PlaceholderView: View {
    let title: String
    let backAction: () -> Void

    var body: some View {
        VStack {
            Text(title)
                .pickText(type: .heading2)
            Text("이 화면은 아직 구현되지 않았습니다")
                .pickText(type: .body1, textColor: .Gray.gray600)
                .padding(.top, 8)
        }
        .navigationBarBackButtonHidden(true)
        #if os(iOS)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button(action: backAction) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.Normal.black)
                }
            }
        }
        #endif
        .navigationTitle(title)
    }
}
