import SwiftUI

struct MainTabView: View {
    @State private var router = AppRouter()
    
    var body: some View {
        TabView(selection: $router.selectedTab) {
            // Home Tab
            NavigationStack(path: $router.homePath) {
                HomeScreen()
                    .navigationDestination(for: AppRoute.self) { route in
                        NavigationCoordinator(route: route)
                    }
            }
            .tabItem {
                Label(TabItem.home.title, systemImage: TabItem.home.iconName)
            }
            .tag(TabItem.home)
            
            // Tests Tab
            NavigationStack(path: $router.testsPath) {
                TestsScreen()
                    .navigationDestination(for: AppRoute.self) { route in
                        NavigationCoordinator(route: route)
                    }
            }
            .tabItem {
                Label(TabItem.tests.title, systemImage: TabItem.tests.iconName)
            }
            .tag(TabItem.tests)
            
            // Contents Tab
            NavigationStack(path: $router.contentsPath) {
                ContentsScreen()
                    .navigationDestination(for: AppRoute.self) { route in
                        NavigationCoordinator(route: route)
                    }
            }
            .tabItem {
                Label(TabItem.contents.title, systemImage: TabItem.contents.iconName)
            }
            .tag(TabItem.contents)
            
            // Statistics Tab
            NavigationStack(path: $router.statisticsPath) {
                StatisticsScreen()
                    .navigationDestination(for: AppRoute.self) { route in
                        NavigationCoordinator(route: route)
                    }
            }
            .tabItem {
                Label(TabItem.statistics.title, systemImage: TabItem.statistics.iconName)
            }
            .tag(TabItem.statistics)
        }
        .tint(Color.primary1)
        .environment(\.appRouter, router)
        .onAppear {
            configureTabBarAppearance()
        }
    }
    
    private func configureTabBarAppearance() {
        let appearance = UITabBarAppearance()
        appearance.configureWithDefaultBackground()
        appearance.backgroundColor = UIColor.white
        
        // Selected item colors
        appearance.stackedLayoutAppearance.selected.iconColor = UIColor(Color.primary1)
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [
            .foregroundColor: UIColor(Color.primary1)
        ]
        
        // Normal item colors
        appearance.stackedLayoutAppearance.normal.iconColor = UIColor(Color.textSecondary)
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = [
            .foregroundColor: UIColor(Color.textSecondary)
        ]
        
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }
}

#Preview {
    MainTabView()
}
