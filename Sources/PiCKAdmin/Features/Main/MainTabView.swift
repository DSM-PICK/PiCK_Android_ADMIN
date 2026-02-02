import SwiftUI

struct MainTabView: View {
    @State var selectedTab = 2
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // Tab 0: 급식
            Color.red
                .tag(0)
                .tabItem {
                    Label("급식", systemImage: "fork.knife")
                }
            
            // Tab 1: 일정
            Color.blue
                .tag(1)
                .tabItem {
                    Label("일정", systemImage: "calendar")
                }
            
            // Tab 2: 홈
            NavigationStack {
                HomeView()
            }
            .tag(2)
            .tabItem {
                Label("홈", systemImage: "house.fill")
            }
            
            // Tab 3: 수락
            Color.green
                .tag(3)
                .tabItem {
                    Label("수락", systemImage: "checkmark.circle")
                }
            
            // Tab 4: 전체
            Color.orange
                .tag(4)
                .tabItem {
                    Label("전체", systemImage: "line.3.horizontal")
                }
        }
        .tint(Color.Primary.primary500)
    }
}
