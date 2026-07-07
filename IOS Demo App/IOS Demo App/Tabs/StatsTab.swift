import SwiftUI
import Charts

struct StatsTab: View {
    @EnvironmentObject private var sessionStore: SessionStore

    var body: some View {
        NavigationStack {
            ZStack {
                GameBackground(accent: GameTheme.neonGold, intensity: 0.25)

                Group {
                    if sessionStore.sessions.isEmpty {
                        emptyState
                    } else {
                        ScrollView {
                            VStack(alignment: .leading, spacing: 20) {
                                totalsSection
                                bestsSection
                                chartSection
                                recentSection
                            }
                            .padding(.horizontal, 16)
                            .padding(.top, 8)
                            .padding(.bottom, 12)
                        }
                        .gameTabScroll()
                    }
                }
            }
            .navigationTitle("Stats")
            .navigationBarTitleDisplayMode(.large)
            .toolbarBackground(.hidden, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
        }
    }

    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "chart.bar.fill")
                .font(.system(size: 56))
                .foregroundStyle(GameTheme.neonGold)

            Text("NO STATS YET")
                .font(.title3.weight(.black))
                .tracking(1.5)
                .foregroundStyle(.white)

            Text("Complete a game to see totals, bests, and charts.")
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.6))
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
    }

    private var totalsSection: some View {
        GamePanel {
            VStack(alignment: .leading, spacing: 12) {
                GameSectionTitle(title: "Totals", icon: "sum")

                HStack(spacing: 12) {
                    totalCard(title: "Games", value: "\(sessionStore.totalGames)")
                    totalCard(title: "All Scores", value: "\(sessionStore.sessions.map(\.score).reduce(0, +))")
                }
            }
        }
    }

    private func totalCard(title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title.uppercased())
                .font(.caption2.weight(.bold))
                .foregroundStyle(.white.opacity(0.5))
            Text(value)
                .font(.title2.weight(.black))
                .foregroundStyle(GameTheme.neonCyan)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(Color.white.opacity(0.06), in: RoundedRectangle(cornerRadius: 12))
    }

    private var bestsSection: some View {
        GamePanel {
            VStack(alignment: .leading, spacing: 12) {
                GameSectionTitle(title: "Personal Bests", icon: "trophy.fill")

                ForEach(GameMode.allCases, id: \.self) { mode in
                    HStack {
                        Text(mode.displayName)
                            .foregroundStyle(.white)
                        Spacer()
                        Text("\(sessionStore.bestScore(for: mode) ?? 0)")
                            .font(.headline.weight(.black))
                            .foregroundStyle(GameTheme.neonGold)
                    }
                }
            }
        }
    }

    private var chartSection: some View {
        GamePanel {
            VStack(alignment: .leading, spacing: 12) {
                GameSectionTitle(title: "Scores by Game", icon: "chart.bar.fill")

                Chart(sessionStore.sessions.prefix(20).reversed()) { session in
                    BarMark(
                        x: .value("Score", session.score),
                        y: .value("Game", session.mode.displayName)
                    )
                    .foregroundStyle(colorForMode(session.mode).gradient)
                    .cornerRadius(4)
                }
                .chartXAxis {
                    AxisMarks { _ in
                        AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5))
                            .foregroundStyle(Color.white.opacity(0.15))
                        AxisValueLabel()
                            .foregroundStyle(Color.white.opacity(0.6))
                    }
                }
                .chartYAxis {
                    AxisMarks { _ in
                        AxisValueLabel()
                            .foregroundStyle(Color.white.opacity(0.8))
                    }
                }
                .frame(height: CGFloat(GameMode.allCases.count) * 44 + 40)
            }
        }
    }

    private var recentSection: some View {
        GamePanel {
            VStack(alignment: .leading, spacing: 12) {
                GameSectionTitle(title: "Recent Games", icon: "clock.fill")

                ForEach(sessionStore.recentSessions) { session in
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(session.mode.displayName)
                                .font(.subheadline.weight(.bold))
                                .foregroundStyle(.white)
                            Text(session.timestamp, format: .dateTime.day().month().hour().minute())
                                .font(.caption)
                                .foregroundStyle(.white.opacity(0.5))
                        }
                        Spacer()
                        Text("\(session.score)")
                            .font(.headline.weight(.black))
                            .foregroundStyle(colorForMode(session.mode))
                    }
                    if session.id != sessionStore.recentSessions.last?.id {
                        Divider().overlay(Color.white.opacity(0.12))
                    }
                }
            }
        }
    }

    private func colorForMode(_ mode: GameMode) -> Color {
        switch mode {
        case .tapFrenzy: return GameTheme.neonCyan
        case .lightItUp: return GameTheme.neonOrange
        case .quizRush: return GameTheme.neonPurple
        }
    }
}

#if DEBUG
#Preview {
    StatsTab()
        .environmentObject(SessionStore())
        .preferredColorScheme(.dark)
}
#endif
