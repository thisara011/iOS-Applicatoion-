import SwiftUI

enum TabItem: Hashable {
    case home, stats, map, settings
}

struct MainTabView: View {
    init() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(red: 0.06, green: 0.04, blue: 0.14, alpha: 1.0)

        let normal = UIColor.white.withAlphaComponent(0.45)
        let selected = UIColor(red: 0.20, green: 0.92, blue: 1.00, alpha: 1.0)

        appearance.stackedLayoutAppearance.normal.iconColor = normal
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = [.foregroundColor: normal]
        appearance.stackedLayoutAppearance.selected.iconColor = selected
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [.foregroundColor: selected]

        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }

    var body: some View {
        TabView {
            HomeTab()
                .tabItem {
                    Label("Home", systemImage: "gamecontroller")
                }
                .tag(TabItem.home)

            StatsTab()
                .tabItem {
                    Label("Stats", systemImage: "chart.bar")
                }
                .tag(TabItem.stats)

            MapTab()
                .tabItem {
                    Label("Map", systemImage: "map")
                }
                .tag(TabItem.map)

            SettingsTab()
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
                .tag(TabItem.settings)
        }
        .tint(GameTheme.neonCyan)
        .preferredColorScheme(.dark)
    }
}

#if DEBUG
#Preview {
    MainTabView()
        .environmentObject(SessionStore())
        .environmentObject(LocationService())
        .environmentObject(NotificationService())
}
#endif
