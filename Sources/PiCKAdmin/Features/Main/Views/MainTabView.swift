import SwiftUI

struct MainTabView: View {
    @Environment(\.appRouter) var router: AppRouter

    var body: some View {
        @Bindable var bindableRouter = router
        TabView(selection: $bindableRouter.selectedTab) {
            NavigationStack {
                SchoolMealView()
                    .toolbarBackground(Color.white, for: .navigationBar)
                    .toolbarBackground(.visible, for: .navigationBar)
            }
            .tag(0)
            .tabItem {
                Label {
                    Text("급식")
                } icon: {
                    Image("schoolMealIcon", bundle: .module)
                }
            }
            
            NavigationStack {
                PlanView()
                    .toolbarBackground(Color.white, for: .navigationBar)
                    .toolbarBackground(.visible, for: .navigationBar)
            }
            .tag(1)
            .tabItem {
                Label {
                    Text("일정")
                } icon: {
                    Image("scheduleIcon", bundle: .module)
                }
            }
            
            NavigationStack {
                HomeView()
                    .toolbarBackground(Color.white, for: .navigationBar)
                    .toolbarBackground(.visible, for: .navigationBar)
            }
            .tag(2)
            .tabItem {
                Label {
                    Text("홈")
                } icon: {
                    Image("homeIcon", bundle: .module)
                }
            }
            
            NavigationStack {
                AcceptView()
                    .toolbarBackground(Color.white, for: .navigationBar)
                    .toolbarBackground(.visible, for: .navigationBar)
            }
            .tag(3)
            .tabItem {
                Label {
                    Text("수락")
                } icon: {
                    Image("applyIcon", bundle: .module)
                }
            }
            
            NavigationStack {
                AllTabView()
                    .toolbarBackground(Color.white, for: .navigationBar)
                    .toolbarBackground(.visible, for: .navigationBar)
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
