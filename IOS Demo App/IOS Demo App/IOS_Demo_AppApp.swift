
import SwiftUI
import SwiftData

/// Main application entrypoint for the reorganized PlayHub app.
@main
struct PlayHubApp: App {
    @StateObject private var sessionStore = SessionStore()
    @StateObject private var locationService = LocationService()
    @StateObject private var notificationService = NotificationService()

    @AppStorage("notificationsEnabled") private var notificationsEnabled = false
    @AppStorage("dailyChallengeHour") private var dailyChallengeHour = 18
    @AppStorage("dailyChallengeMinute") private var dailyChallengeMinute = 0

    var body: some Scene {
        WindowGroup {
            MainTabView()
                .environmentObject(sessionStore)
                .environmentObject(locationService)
                .environmentObject(notificationService)
                .onAppear {
                    locationService.requestPermission()
                    locationService.startUpdating()
                }
                .task {
                    await notificationService.refreshAuthorizationStatus()
                    if notificationsEnabled {
                        var components = DateComponents()
                        components.hour = dailyChallengeHour
                        components.minute = dailyChallengeMinute
                        let date = Calendar.current.date(from: components) ?? .now
                        await notificationService.scheduleDailyChallenge(at: date)
                    }
                }
        }
        .modelContainer(for: Item.self)
    }
}
