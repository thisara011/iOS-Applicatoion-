import SwiftUI

struct GameResultView: View {
    let mode: GameMode
    let score: Int
    let best: Int
    var extraStats: [(String, String)] = []
    var onPlayAgain: () -> Void

    private var shareText: String {
        "I just scored \(score) on \(mode.displayName) — beat that!"
    }

    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "crown.fill")
                .font(.system(size: 52))
                .foregroundStyle(GameTheme.neonGold)
                .shadow(color: GameTheme.neonGold.opacity(0.6), radius: 12)
                .accessibilityHidden(true)

            Text("ROUND COMPLETE!")
                .font(.title2.weight(.black))
                .tracking(1.5)
                .foregroundStyle(.white)

            GamePanel {
                VStack(spacing: 12) {
                    statRow(title: "Score", value: "\(score)", highlight: GameTheme.neonCyan)
                    statRow(title: "Best", value: "\(best)", highlight: GameTheme.neonGold)
                    ForEach(extraStats, id: \.0) { title, value in
                        statRow(title: title, value: value, highlight: .white)
                    }
                }
            }

            ShareLink(item: shareText) {
                Label("Share Your Score", systemImage: "square.and.arrow.up")
                    .font(.headline.weight(.bold))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .foregroundStyle(.white)
                    .background(
                        LinearGradient(
                            colors: [GameTheme.neonCyan, GameTheme.neonPurple],
                            startPoint: .leading,
                            endPoint: .trailing
                        ),
                        in: RoundedRectangle(cornerRadius: 14)
                    )
            }

            GamePrimaryButton(title: "Play Again", action: onPlayAgain)
        }
        .padding()
    }

    private func statRow(title: String, value: String, highlight: Color) -> some View {
        HStack {
            Text(title.uppercased())
                .font(.caption.weight(.bold))
                .tracking(1.2)
                .foregroundStyle(.white.opacity(0.6))
            Spacer()
            Text(value)
                .font(.title3.weight(.black))
                .foregroundStyle(highlight)
        }
    }
}

#if DEBUG
#Preview {
    ZStack {
        GameBackground()
        GameResultView(mode: .quizRush, score: 47, best: 52, extraStats: [("Streak", "5")]) {}
    }
    .preferredColorScheme(.dark)
}
#endif
