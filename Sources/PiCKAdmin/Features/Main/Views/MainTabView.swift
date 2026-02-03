import SwiftUI

struct MainTabView: View {
    @Environment(\.appRouter) var router: AppRouter

    var body: some View {
        @Bindable var bindableRouter = router
        TabView(selection: $bindableRouter.selectedTab) {
            // Tab 0: 급식
            NavigationStack {
                SchoolMealView()
            }
            .tag(0)
            .tabItem {
                Label {
                    Text("급식")
                } icon: {
                    Image("schoolMealIcon", bundle: .module)
                }
            }
            
            // Tab 1: 일정
            NavigationStack {
                PlanView()
            }
            .tag(1)
            .tabItem {
                Label {
                    Text("일정")
                } icon: {
                    Image("scheduleIcon", bundle: .module)
                }
            }
            
            // Tab 2: 홈
            NavigationStack {
                HomeView()
            }
            .tag(2)
            .tabItem {
                Label {
                    Text("홈")
                } icon: {
                    Image("homeIcon", bundle: .module)
                }
            }
            
            // Tab 3: 수락
            NavigationStack {
                AcceptView()
            }
            .tag(3)
            .tabItem {
                Label {
                    Text("수락")
                } icon: {
                    Image("applyIcon", bundle: .module)
                }
            }
            
            // Tab 4: 전체
            NavigationStack {
                AllTabView()
            }
            .tag(4)
            .tabItem {
                Label {
                    Text("전체")
                } icon: {
                    Image("allTabIcon", bundle: .module)
                }
            }
        }
        .tint(Color.Primary.primary500)
    }
}
