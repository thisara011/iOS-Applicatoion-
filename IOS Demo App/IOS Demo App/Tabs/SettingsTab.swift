import SwiftUI

struct SettingsTab: View {
    @EnvironmentObject private var notificationService: NotificationService
    @EnvironmentObject private var sessionStore: SessionStore

    @AppStorage("soundEnabled") private var soundEnabled = true
    @AppStorage("notificationsEnabled") private var notificationsEnabled = false
    @AppStorage("dailyChallengeHour") private var dailyChallengeHour = 18
    @AppStorage("dailyChallengeMinute") private var dailyChallengeMinute = 0

    @State private var showResetConfirmation = false

    private var challengeTime: Date {
        var components = Calendar.current.dateComponents([.year, .month, .day], from: .now)
        components.hour = dailyChallengeHour
        components.minute = dailyChallengeMinute
        return Calendar.current.date(from: components) ?? .now
    }

    var body: some View {
        NavigationStack {
            ZStack {
                GameBackground(accent: GameTheme.neonPurple, intensity: 0.2)

                ScrollView {
                    VStack(spacing: 16) {
                        GamePanel {
                            Toggle(isOn: $soundEnabled) {
                                settingsLabel(
                                    icon: "speaker.wave.3.fill",
                                    color: GameTheme.neonCyan,
                                    title: "Sound Effects",
                                    subtitle: "Tap, warning & game over sounds"
                                )
                            }
                            .tint(GameTheme.neonPink)
                        }

                        GamePanel {
                            VStack(alignment: .leading, spacing: 14) {
                                Toggle(isOn: $notificationsEnabled) {
                                    settingsLabel(
                                        icon: "bell.badge.fill",
                                        color: GameTheme.neonGold,
                                        title: "Daily Challenge",
                                        subtitle: "Get a reminder to play each day"
                                    )
                                }
                                .tint(GameTheme.neonPink)
                                .onChange(of: notificationsEnabled) { _, enabled in
                                    Task { await handleNotificationsToggle(enabled) }
                                }

                                if notificationsEnabled {
                                    DatePicker(
                                        "Reminder Time",
                                        selection: Binding(
                                            get: { challengeTime },
                                            set: { newValue in
                                                let components = Calendar.current.dateComponents([.hour, .minute], from: newValue)
                                                dailyChallengeHour = components.hour ?? 18
                                                dailyChallengeMinute = components.minute ?? 0
                                                Task { await rescheduleDailyChallenge() }
                                            }
                                        ),
                                        displayedComponents: .hourAndMinute
                                    )
                                    .datePickerStyle(.compact)
                                    .foregroundStyle(.white)
                                    .tint(GameTheme.neonCyan)
                                }
                            }
                        }

                        GamePanel {
                            VStack(alignment: .leading, spacing: 12) {
                                GameSectionTitle(title: "About", icon: "info.circle.fill")
                                infoRow(label: "App", value: "PlayHub")
                                infoRow(label: "Version", value: "1.0")
                            }
                        }

                        GamePanel {
                            Button(role: .destructive) {
                                showResetConfirmation = true
                            } label: {
                                HStack {
                                    Image(systemName: "trash.fill")
                                    Text("Reset All Stats")
                                        .fontWeight(.bold)
                                    Spacer()
                                }
                                .foregroundStyle(.red)
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
                    .padding(.bottom, 12)
                }
                .gameTabScroll()
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.large)
            .toolbarBackground(.hidden, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .confirmationDialog(
                "Reset all stats?",
                isPresented: $showResetConfirmation,
                titleVisibility: .visible
            ) {
                Button("Reset Everything", role: .destructive) {
                    sessionStore.resetAllStats()
                }
            } message: {
                Text("This clears all sessions and personal bests.")
            }
            .task {
                await notificationService.refreshAuthorizationStatus()
            }
        }
    }

    private func settingsLabel(icon: String, color: Color, title: String, subtitle: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundStyle(color)
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.headline.weight(.bold))
                    .foregroundStyle(.white)
                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.5))
            }
        }
    }

    private func infoRow(label: String, value: String) -> some View {
        HStack {
            Text(label)
                .foregroundStyle(.white.opacity(0.6))
            Spacer()
            Text(value)
                .fontWeight(.bold)
                .foregroundStyle(.white)
        }
        .font(.subheadline)
    }

    private func handleNotificationsToggle(_ enabled: Bool) async {
        if enabled {
            let granted = await notificationService.requestPermission()
            if granted {
                await rescheduleDailyChallenge()
            } else {
                notificationsEnabled = false
            }
        } else {
            notificationService.cancelDailyChallenge()
        }
    }

    private func rescheduleDailyChallenge() async {
        guard notificationsEnabled else { return }
        await notificationService.scheduleDailyChallenge(at: challengeTime)
    }
}

#if DEBUG
#Preview {
    SettingsTab()
        .environmentObject(NotificationService())
        .environmentObject(SessionStore())
        .preferredColorScheme(.dark)
}
#endif
