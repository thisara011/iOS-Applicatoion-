import SwiftUI

enum GameTheme {
    static let backgroundTop = Color(red: 0.10, green: 0.06, blue: 0.22)
    static let backgroundBottom = Color(red: 0.04, green: 0.02, blue: 0.10)
    static let cardBackground = Color.white.opacity(0.08)
    static let cardBorder = Color.white.opacity(0.18)

    static let neonCyan = Color(red: 0.20, green: 0.92, blue: 1.00)
    static let neonPink = Color(red: 1.00, green: 0.25, blue: 0.65)
    static let neonGold = Color(red: 1.00, green: 0.84, blue: 0.20)
    static let neonPurple = Color(red: 0.62, green: 0.35, blue: 1.00)
    static let neonOrange = Color(red: 1.00, green: 0.55, blue: 0.15)
    static let neonGreen = Color(red: 0.30, green: 1.00, blue: 0.55)

    static let titleFont = Font.system(.largeTitle, design: .rounded).weight(.black)
    static let headlineFont = Font.system(.headline, design: .rounded).weight(.bold)
    static let scoreFont = Font.system(size: 36, weight: .heavy, design: .rounded)
}

struct GameBackground: View {
    var accent: Color = GameTheme.neonPurple
    var intensity: Double = 0.35

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [GameTheme.backgroundTop, GameTheme.backgroundBottom],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            RadialGradient(
                colors: [accent.opacity(intensity), .clear],
                center: .topTrailing,
                startRadius: 20,
                endRadius: 320
            )

            RadialGradient(
                colors: [GameTheme.neonCyan.opacity(0.12), .clear],
                center: .bottomLeading,
                startRadius: 10,
                endRadius: 260
            )
        }
        .ignoresSafeArea()
    }
}

struct GameSectionTitle: View {
    let title: String
    let icon: String

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .foregroundStyle(GameTheme.neonGold)
            Text(title.uppercased())
                .font(.subheadline.weight(.heavy))
                .tracking(1.5)
                .foregroundStyle(.white.opacity(0.85))
            Spacer()
        }
    }
}

struct GameHUD: View {
    let score: Int
    let best: Int
    var label: String = "SCORE"
    var compact: Bool = false

    var body: some View {
        HStack(spacing: compact ? 8 : 12) {
            VStack(alignment: .leading, spacing: 1) {
                Text(label)
                    .font(.caption2.weight(.bold))
                    .tracking(1.0)
                    .foregroundStyle(GameTheme.neonCyan)
                Text("\(score)")
                    .font(compact ? .headline.weight(.black) : .title3.weight(.black))
                    .foregroundStyle(.white)
                    .contentTransition(.numericText())
            }

            if !compact {
                Divider()
                    .frame(height: 24)
                    .overlay(Color.white.opacity(0.25))
            }

            VStack(alignment: .leading, spacing: 1) {
                Text("BEST")
                    .font(.caption2.weight(.bold))
                    .tracking(1.0)
                    .foregroundStyle(GameTheme.neonGold)
                Text("\(best)")
                    .font(compact ? .subheadline.weight(.bold) : .headline.weight(.bold))
                    .foregroundStyle(.white.opacity(0.9))
            }
        }
        .padding(.horizontal, compact ? 10 : 14)
        .padding(.vertical, compact ? 6 : 8)
        .background(
            Capsule()
                .fill(Color.black.opacity(0.45))
                .overlay(
                    Capsule()
                        .strokeBorder(
                            LinearGradient(
                                colors: [GameTheme.neonCyan.opacity(0.7), GameTheme.neonPurple.opacity(0.5)],
                                startPoint: .leading,
                                endPoint: .trailing
                            ),
                            lineWidth: 1.5
                        )
                )
        )
    }
}

struct GamePrimaryButton: View {
    let title: String
    var isDisabled: Bool = false
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title.uppercased())
                .font(.headline.weight(.heavy))
                .tracking(1.2)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .foregroundStyle(.white)
                .background(
                    LinearGradient(
                        colors: isDisabled
                            ? [Color.gray.opacity(0.5), Color.gray.opacity(0.35)]
                            : [GameTheme.neonPink, GameTheme.neonPurple],
                        startPoint: .leading,
                        endPoint: .trailing
                    ),
                    in: RoundedRectangle(cornerRadius: 16)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .strokeBorder(Color.white.opacity(0.25), lineWidth: 1)
                )
                .shadow(color: isDisabled ? .clear : GameTheme.neonPink.opacity(0.45), radius: 12, y: 4)
        }
        .disabled(isDisabled)
    }
}

struct GameCard<Destination: View>: View {
    let title: String
    let subtitle: String
    let systemImage: String
    let colors: [Color]
    let bestScore: Int
    @ViewBuilder let destination: () -> Destination

    var body: some View {
        NavigationLink(destination: destination) {
            ZStack(alignment: .bottomLeading) {
                RoundedRectangle(cornerRadius: 20)
                    .fill(
                        LinearGradient(colors: colors, startPoint: .topLeading, endPoint: .bottomTrailing)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .strokeBorder(Color.white.opacity(0.22), lineWidth: 1.5)
                    )
                    .shadow(color: colors.first?.opacity(0.45) ?? .clear, radius: 12, y: 6)

                Circle()
                    .fill(Color.white.opacity(0.08))
                    .frame(width: 90, height: 90)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
                    .padding(12)

                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image(systemName: systemImage)
                            .font(.system(size: 22, weight: .bold))
                            .foregroundStyle(.white)
                            .padding(10)
                            .background(Color.black.opacity(0.22), in: RoundedRectangle(cornerRadius: 12))

                        Spacer()

                        if bestScore > 0 {
                            HStack(spacing: 4) {
                                Image(systemName: "trophy.fill")
                                    .font(.caption2)
                                Text("\(bestScore)")
                                    .font(.caption2.weight(.bold))
                            }
                            .foregroundStyle(GameTheme.neonGold)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 5)
                            .background(Color.black.opacity(0.35), in: Capsule())
                        }
                    }

                    Text(title)
                        .font(.title3.weight(.black))
                        .foregroundStyle(.white)
                        .lineLimit(1)
                        .minimumScaleFactor(0.85)

                    Text(subtitle)
                        .font(.caption.weight(.medium))
                        .foregroundStyle(.white.opacity(0.85))
                        .lineLimit(2)
                        .fixedSize(horizontal: false, vertical: true)

                    HStack(spacing: 6) {
                        Text("PLAY NOW")
                            .font(.caption2.weight(.heavy))
                            .tracking(1.2)
                        Image(systemName: "arrow.right.circle.fill")
                            .font(.caption)
                    }
                    .foregroundStyle(.white.opacity(0.9))
                }
                .padding(16)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 158)
        }
        .buttonStyle(.plain)
    }
}

struct GamePanel<Content: View>: View {
  @ViewBuilder let content: Content

  var body: some View {
    content
      .padding()
      .frame(maxWidth: .infinity, alignment: .leading)
      .background(
        RoundedRectangle(cornerRadius: 18)
          .fill(GameTheme.cardBackground)
          .overlay(
            RoundedRectangle(cornerRadius: 18)
              .strokeBorder(GameTheme.cardBorder, lineWidth: 1)
          )
      )
  }
}

struct GameTimerDisplay: View {
    let value: Int
    var unit: String = "SEC"
    var isUrgent: Bool = false

    var body: some View {
        VStack(spacing: 6) {
            Text(unit)
                .font(.caption.weight(.heavy))
                .tracking(2)
                .foregroundStyle(isUrgent ? Color.red : GameTheme.neonCyan)

            Text("\(value)")
                .font(GameTheme.scoreFont)
                .foregroundStyle(isUrgent ? Color.red : .white)
                .monospacedDigit()
                .contentTransition(.numericText())
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 24)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(Color.black.opacity(0.4))
                .overlay(
                    RoundedRectangle(cornerRadius: 18)
                        .strokeBorder(
                            isUrgent ? Color.red.opacity(0.6) : GameTheme.neonCyan.opacity(0.4),
                            lineWidth: 2
                        )
                )
        )
        .shadow(color: isUrgent ? Color.red.opacity(0.3) : GameTheme.neonCyan.opacity(0.2), radius: 10)
    }
}

struct GameScreenModifier: ViewModifier {
    var accent: Color = GameTheme.neonPurple

    func body(content: Content) -> some View {
        content
            .background(GameBackground(accent: accent))
            .toolbarBackground(.hidden, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
    }
}

extension View {
    func gameScreen(accent: Color = GameTheme.neonPurple) -> some View {
        modifier(GameScreenModifier(accent: accent))
    }

    /// Keeps scroll content above the floating tab bar on home/stats/map/settings tabs.
    func gameTabScroll() -> some View {
        contentMargins(.bottom, 44, for: .scrollContent)
            .scrollIndicators(.hidden)
    }

    /// Bottom breathing room inside pushed game screens.
    func gamePlayScroll() -> some View {
        contentMargins(.bottom, 16, for: .scrollContent)
    }
}
