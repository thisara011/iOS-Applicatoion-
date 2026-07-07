import Foundation
import Combine
import UserNotifications

@MainActor
final class NotificationService: ObservableObject {
    static let dailyChallengeID = "playhub.daily.challenge"

    @Published private(set) var authorizationStatus: UNAuthorizationStatus = .notDetermined

    private let center = UNUserNotificationCenter.current()

    func refreshAuthorizationStatus() async {
        let settings = await center.notificationSettings()
        authorizationStatus = settings.authorizationStatus
    }

    func requestPermission() async -> Bool {
        do {
            let granted = try await center.requestAuthorization(options: [.alert, .sound, .badge])
            await refreshAuthorizationStatus()
            return granted
        } catch {
            print("NotificationService permission error: \(error.localizedDescription)")
            await refreshAuthorizationStatus()
            return false
        }
    }

    func scheduleDailyChallenge(at time: Date) async {
        center.removePendingNotificationRequests(withIdentifiers: [Self.dailyChallengeID])

        let components = Calendar.current.dateComponents([.hour, .minute], from: time)
        let content = UNMutableNotificationContent()
        content.title = "Daily Challenge"
        content.body = "Your PlayHub daily challenge is ready — jump in and beat your best!"
        content.sound = .default

        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        let request = UNNotificationRequest(
            identifier: Self.dailyChallengeID,
            content: content,
            trigger: trigger
        )

        do {
            try await center.add(request)
        } catch {
            print("NotificationService schedule error: \(error.localizedDescription)")
        }
    }

    func cancelDailyChallenge() {
        center.removePendingNotificationRequests(withIdentifiers: [Self.dailyChallengeID])
    }
}
