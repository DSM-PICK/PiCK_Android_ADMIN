import SwiftUI

struct ContentView: View {
    @StateObject var router = AppRouter()
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
        .environmentObject(router)
    }

    private var authLoadingView: some View {
        VStack {
            ProgressView()
        }
    }

    private var homeView: some View {
        NavigationStack {
            HomeView()
        }
        .environmentObject(router)
    }

    private var navigationStackView: some View {
        ZStack {
            if router.path.isEmpty {
                OnboardingView()
                    .environmentObject(router)
                    .transition(.opacity.combined(with: .scale(scale: 0.95)))
                    .zIndex(0)
            }

            if !router.path.isEmpty {
                NavigationStack(path: $router.path) {
                    Color.clear
                        .navigationDestination(for: AppRoute.self) { route in
                            routeDestination(for: route)
                        }
                }
                .transition(.asymmetric(
                    insertion: AnyTransition.offset(x: 0, y: 20).combined(with: .opacity),
                    removal: .opacity.combined(with: .scale(scale: 1.05))
                ))
                .zIndex(1)
            }
        }
        .animation(.spring(response: 0.35, dampingFraction: 0.85), value: router.path.count)
    }

    @ViewBuilder
    private func routeDestination(for route: AppRoute) -> some View {
        switch route {
        case .onboarding:
            OnboardingView()
                .environmentObject(router)
        case .signin:
            SigninView()
                .environmentObject(router)
        case .secretKey:
            SecretKeyView()
                .environmentObject(router)
        case let .email(secretKey):
            EmailVerifyView(secretKey: secretKey)
                .environmentObject(router)
        case let .password(secretKey, accountId, code):
            PasswordView(secretKey: secretKey, accountId: accountId, code: code)
                .environmentObject(router)
        case let .infoSetting(secretKey, accountId, code, password):
            InfoSettingView(secretKey: secretKey, accountId: accountId, code: code, password: password)
                .environmentObject(router)
        case .home:
            EmptyView()
        case .outList:
            OutListView()
                .environmentObject(router)
        case .checkSelfStudyTeacher:
            CheckSelfStudyTeacherView()
                .environmentObject(router)
        case .bugReport:
            BugReportView()
                .environmentObject(router)
        case .changePassword:
            ChangePasswordView()
                .environmentObject(router)
        case let .newPassword(accountId, code):
            NewPasswordView(accountId: accountId, code: code)
                .environmentObject(router)
        case .selfStudyCheck:
            SelfStudyCheckView()
                .environmentObject(router)
        case .classroomMoveList:
            ClassroomMoveListView()
                .environmentObject(router)
        case .outingHistory:
            OutingHistoryView()
                .environmentObject(router)
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
    @EnvironmentObject var router: AppRouter

    var body: some View {
        PlaceholderView(title: "시크릿 키 입력", backAction: { router.pop() })
    }
}

struct EmailVerifyView: View {
    let secretKey: String
    @EnvironmentObject var router: AppRouter

    var body: some View {
        PlaceholderView(title: "이메일 인증", backAction: { router.pop() })
    }
}

struct PasswordView: View {
    let secretKey: String
    let accountId: String
    let code: String
    @EnvironmentObject var router: AppRouter

    var body: some View {
        PlaceholderView(title: "비밀번호 설정", backAction: { router.pop() })
    }
}

struct InfoSettingView: View {
    let secretKey: String
    let accountId: String
    let code: String
    let password: String
    @EnvironmentObject var router: AppRouter

    var body: some View {
        PlaceholderView(title: "정보 설정", backAction: { router.pop() })
    }
}

struct OutListView: View {
    @EnvironmentObject var router: AppRouter

    var body: some View {
        PlaceholderView(title: "외출 목록", backAction: { router.pop() })
    }
}

struct CheckSelfStudyTeacherView: View {
    @EnvironmentObject var router: AppRouter

    var body: some View {
        PlaceholderView(title: "자습감독 확인", backAction: { router.pop() })
    }
}

struct BugReportView: View {
    @EnvironmentObject var router: AppRouter

    var body: some View {
        PlaceholderView(title: "버그 신고", backAction: { router.pop() })
    }
}

struct ChangePasswordView: View {
    @EnvironmentObject var router: AppRouter

    var body: some View {
        PlaceholderView(title: "비밀번호 변경", backAction: { router.pop() })
    }
}

struct NewPasswordView: View {
    let accountId: String
    let code: String
    @EnvironmentObject var router: AppRouter

    var body: some View {
        PlaceholderView(title: "새 비밀번호", backAction: { router.pop() })
    }
}

struct SelfStudyCheckView: View {
    @EnvironmentObject var router: AppRouter

    var body: some View {
        PlaceholderView(title: "자습 확인", backAction: { router.pop() })
    }
}

struct ClassroomMoveListView: View {
    @EnvironmentObject var router: AppRouter

    var body: some View {
        PlaceholderView(title: "교실 이동 목록", backAction: { router.pop() })
    }
}

struct OutingHistoryView: View {
    @EnvironmentObject var router: AppRouter

    var body: some View {
        PlaceholderView(title: "외출 기록", backAction: { router.pop() })
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
