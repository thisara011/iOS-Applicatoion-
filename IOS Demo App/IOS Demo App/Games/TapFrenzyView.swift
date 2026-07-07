import SwiftUI
import AVFoundation

struct TapFrenzyView: View {
    @EnvironmentObject private var sessionStore: SessionStore
    @EnvironmentObject private var locationService: LocationService
    @AppStorage("tapFrenzyHighScore") private var highScore = 0
    @AppStorage("soundEnabled") private var soundEnabled = true

    @State private var score = 0
    @State private var timeRemaining = 20
    @State private var isGameRunning = false
    @State private var showGameOver = false
    @State private var showYeeee = false
    @State private var timer: Timer?

    @State private var tapSoundPlayer: AVAudioPlayer?
    @State private var warningSoundPlayer: AVAudioPlayer?
    @State private var gameOverSoundPlayer: AVAudioPlayer?

    private var tapFrenzyHistory: [GameSession] {
        sessionStore.sessions.filter { $0.mode == .tapFrenzy }
    }

    var body: some View {
        Group {
            if showGameOver {
                GameResultView(
                    mode: .tapFrenzy,
                    score: score,
                    best: highScore,
                    onPlayAgain: restartGame
                )
            } else {
                gamePlayView
            }
        }
        .gameScreen(accent: GameTheme.neonCyan)
        .gamePlayScroll()
        .navigationTitle(GameMode.tapFrenzy.displayName)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            if !showGameOver {
                ToolbarItem(placement: .topBarTrailing) {
                    GameHUD(score: score, best: highScore, compact: true)
                }
            }
        }
        .onDisappear {
            timer?.invalidate()
        }
    }

    private var gamePlayView: some View {
        ScrollView {
            VStack(spacing: 20) {
                if showYeeee {
                    Text("YEEEE! 🎉")
                        .font(.title2.weight(.black))
                        .foregroundStyle(GameTheme.neonGold)
                        .shadow(color: GameTheme.neonGold.opacity(0.6), radius: 8)
                        .transition(.scale.combined(with: .opacity))
                }

                Button {
                    hitButtonTapped()
                } label: {
                    ZStack {
                        Circle()
                            .fill(
                                RadialGradient(
                                    colors: [GameTheme.neonCyan, Color.blue],
                                    center: .center,
                                    startRadius: 10,
                                    endRadius: 100
                                )
                            )
                            .frame(width: 180, height: 180)
                            .shadow(color: GameTheme.neonCyan.opacity(0.6), radius: 16)

                        Circle()
                            .strokeBorder(Color.white.opacity(0.35), lineWidth: 3)
                            .frame(width: 180, height: 180)

                        Image("tapImage")
                            .resizable()
                            .scaledToFill()
                            .frame(width: 150, height: 120)
                            .clipShape(Circle())

                        Text("HIT ME!")
                            .font(.headline.weight(.black))
                            .foregroundStyle(.white)
                            .shadow(color: .black.opacity(0.5), radius: 4)
                            .offset(y: 72)
                    }
                    .frame(height: 200)
                }
                .disabled(!isGameRunning)
                .scaleEffect(showYeeee ? 1.1 : 1.0)
                .animation(.spring(response: 0.25, dampingFraction: 0.5), value: showYeeee)
                .accessibilityLabel("Hit Me")
                .accessibilityHint("Tap to increase your score by one point")

                GameTimerDisplay(
                    value: timeRemaining,
                    isUrgent: isGameRunning && timeRemaining <= 5
                )

                GamePrimaryButton(
                    title: isGameRunning ? "Running…" : "Start Game",
                    isDisabled: isGameRunning,
                    action: startGame
                )

                if !tapFrenzyHistory.isEmpty {
                    GamePanel {
                        VStack(alignment: .leading, spacing: 12) {
                            GameSectionTitle(title: "Recent Runs", icon: "clock.fill")

                            ForEach(tapFrenzyHistory.prefix(5)) { session in
                                HStack {
                                    Image(systemName: "star.fill")
                                        .foregroundStyle(GameTheme.neonGold)
                                        .font(.caption)
                                    Text("\(session.score) pts")
                                        .font(.subheadline.weight(.semibold))
                                        .foregroundStyle(.white)
                                    Spacer()
                                    Text(session.timestamp, style: .time)
                                        .font(.caption)
                                        .foregroundStyle(.white.opacity(0.5))
                                }
                            }
                        }
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        }
    }

    private func restartGame() {
        showGameOver = false
        startGame()
    }

    private func hitButtonTapped() {
        guard isGameRunning else { return }

        score += 1
        playSound(fileName: "tap", fileType: "mp3")

        withAnimation {
            showYeeee = true
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
            withAnimation {
                showYeeee = false
            }
        }
    }

    private func startGame() {
        score = 0
        timeRemaining = 20
        isGameRunning = true
        showYeeee = false
        showGameOver = false

        timer?.invalidate()

        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            if timeRemaining > 0 {
                timeRemaining -= 1

                if timeRemaining == 5 {
                    playSound(fileName: "warning", fileType: "mp3")
                }
            } else {
                endGame()
            }
        }
    }

    private func endGame() {
        timer?.invalidate()
        timer = nil
        isGameRunning = false

        playSound(fileName: "gameover", fileType: "mp3")

        if score > highScore {
            highScore = score
        }

        sessionStore.recordGame(
            mode: .tapFrenzy,
            score: score,
            coordinate: locationService.currentCoordinate
        )
        showGameOver = true
    }

    private func playSound(fileName: String, fileType: String) {
        guard soundEnabled else { return }
        guard let path = Bundle.main.path(forResource: fileName, ofType: fileType) else {
            print("Sound file not found: \(fileName).\(fileType)")
            return
        }

        let url = URL(fileURLWithPath: path)

        do {
            let player = try AVAudioPlayer(contentsOf: url)
            player.play()

            switch fileName {
            case "tap":
                tapSoundPlayer = player
            case "warning":
                warningSoundPlayer = player
            case "gameover":
                gameOverSoundPlayer = player
            default:
                break
            }
        } catch {
            print("Could not play sound: \(error.localizedDescription)")
        }
    }
}

#if DEBUG
#Preview {
    NavigationStack {
        TapFrenzyView()
    }
    .environmentObject(SessionStore())
    .environmentObject(LocationService())
    .preferredColorScheme(.dark)
}
#endif
