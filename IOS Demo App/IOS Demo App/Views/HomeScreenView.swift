import SwiftUI

struct HomeScreenView: View {
    @AppStorage("tapFrenzyHighScore") private var tapFrenzyHighScore = 0
    @AppStorage("lightItUpHighScore") private var lightItUpHighScore = 0
    @AppStorage("quizRushHighScore") private var quizRushHighScore = 0

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("PLAYHUB")
                        .font(.system(size: 34, weight: .black, design: .rounded))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [GameTheme.neonCyan, GameTheme.neonPink],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)

                    Text("Pick your next challenge")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.white.opacity(0.7))
                }
                .padding(.top, 4)

                VStack(alignment: .leading, spacing: 12) {
                    GameSectionTitle(title: "Arcade", icon: "gamecontroller.fill")

                    GameCard(
                        title: GameMode.tapFrenzy.displayName,
                        subtitle: "Tap as fast as you can!",
                        systemImage: "hand.tap.fill",
                        colors: [Color(red: 0.15, green: 0.35, blue: 1.0), GameTheme.neonCyan.opacity(0.8)],
                        bestScore: tapFrenzyHighScore
                    ) {
                        TapFrenzyView()
                    }

                    GameCard(
                        title: GameMode.lightItUp.displayName,
                        subtitle: "Hit the glowing cards!",
                        systemImage: "lightbulb.fill",
                        colors: [Color(red: 1.0, green: 0.45, blue: 0.1), GameTheme.neonOrange],
                        bestScore: lightItUpHighScore
                    ) {
                        LightItUpView()
                    }
                }

                VStack(alignment: .leading, spacing: 12) {
                    GameSectionTitle(title: "Brain Battle", icon: "brain.head.profile")

                    GameCard(
                        title: GameMode.quizRush.displayName,
                        subtitle: "10 live trivia questions!",
                        systemImage: "questionmark.circle.fill",
                        colors: [GameTheme.neonPurple, GameTheme.neonPink],
                        bestScore: quizRushHighScore
                    ) {
                        QuizRushView()
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)
            .padding(.bottom, 12)
        }
        .gameTabScroll()
        .gameScreen(accent: GameTheme.neonPink)
    }
}

#if DEBUG
struct HomeScreenView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            HomeScreenView()
        }
        .environmentObject(SessionStore())
        .environmentObject(LocationService())
        .environmentObject(NotificationService())
        .preferredColorScheme(.dark)
    }
}
#endif
