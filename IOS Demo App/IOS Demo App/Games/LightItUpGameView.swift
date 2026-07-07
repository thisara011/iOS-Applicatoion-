import SwiftUI
import AVFoundation

struct LightItUpView: View {
    @EnvironmentObject private var sessionStore: SessionStore
    @EnvironmentObject private var locationService: LocationService
    @AppStorage("lightItUpHighScore") private var highScore = 0
    @AppStorage("soundEnabled") private var soundEnabled = true

    @State private var cards: [Card] = []
    @State private var score = 0
    @State private var timeRemaining = 60
    @State private var isGameRunning = false
    @State private var showGameOver = false
    @State private var timer: Timer?
    @State private var currentLevel: GameLevel = .l1
    @State private var elapsedTime = 0
    @State private var showFeedback = false

    @State private var correctSoundPlayer: AVAudioPlayer?
    @State private var gameOverSoundPlayer: AVAudioPlayer?

    var body: some View {
        Group {
            if showGameOver {
                GameResultView(
                    mode: .lightItUp,
                    score: score,
                    best: highScore,
                    onPlayAgain: restartGame
                )
            } else {
                gamePlayView
            }
        }
        .gamePlayScroll()
        .gameScreen(accent: GameTheme.neonOrange)
        .navigationTitle(GameMode.lightItUp.displayName)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            if !showGameOver {
                ToolbarItem(placement: .topBarTrailing) {
                    GameHUD(score: score, best: highScore, compact: true)
                }
            }
        }
        .onAppear(perform: setupGame)
        .onDisappear {
            timer?.invalidate()
        }
    }

    private var gamePlayView: some View {
        ScrollView {
            VStack(spacing: 20) {
                HStack {
                    Text("LVL \(currentLevel.rawValue)")
                        .font(.headline.weight(.black))
                        .tracking(1.5)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 8)
                        .background(levelColor.gradient, in: Capsule())
                        .overlay(Capsule().strokeBorder(Color.white.opacity(0.3), lineWidth: 1))
                        .foregroundStyle(.white)

                    Spacer()

                    GameTimerDisplay(
                        value: timeRemaining,
                        unit: "TIME",
                        isUrgent: isGameRunning && timeRemaining <= 10
                    )
                    .scaleEffect(0.75)
                    .frame(width: 100)
                }

                if showFeedback {
                    Text("NICE! +1")
                        .font(.headline.weight(.black))
                        .foregroundStyle(GameTheme.neonGreen)
                        .shadow(color: GameTheme.neonGreen.opacity(0.5), radius: 6)
                        .transition(.scale.combined(with: .opacity))
                }

                if !cards.isEmpty {
                    let gridItems = Array(
                        repeating: GridItem(.flexible(), spacing: 12),
                        count: currentLevel.columnsPerRow
                    )

                    LazyVGrid(columns: gridItems, spacing: 12) {
                        ForEach($cards) { $card in
                            CardView(card: $card, level: currentLevel)
                                .onTapGesture {
                                    cardTapped(card)
                                }
                        }
                    }
                    .padding(12)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.black.opacity(0.25))
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .strokeBorder(levelColor.opacity(0.4), lineWidth: 1.5)
                            )
                    )
                }

                if !isGameRunning {
                    GamePrimaryButton(title: "Start Game", action: startGame)
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

    private func setupGame() {
        createCards(for: .l1)
    }

    private func createCards(for level: GameLevel) {
        cards = (0..<level.cardCount).map { _ in Card() }
        currentLevel = level
    }

    private func startGame() {
        score = 0
        timeRemaining = 60
        elapsedTime = 0
        isGameRunning = true
        showGameOver = false
        createCards(for: .l1)

        timer?.invalidate()

        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            elapsedTime += 1
            timeRemaining -= 1

            let newLevel = GameLevel.levelForTime(elapsedTime)
            if newLevel != currentLevel {
                currentLevel = newLevel
                createCards(for: newLevel)
            }

            if timeRemaining <= 0 {
                endGame()
            } else {
                lightUpRandomCards()
            }
        }

        lightUpRandomCards()
    }

    private func lightUpRandomCards() {
        for index in cards.indices {
            cards[index].isLit = false
        }

        let cardsToLight = currentLevel.cardsToLight
        let shuffled = cards.indices.shuffled()

        for index in shuffled.prefix(cardsToLight) {
            cards[index].isLit = true
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + currentLevel.litWindowDuration) {
            for index in cards.indices {
                cards[index].isLit = false
            }
        }
    }

    private func cardTapped(_ card: Card) {
        guard isGameRunning, card.isLit else { return }

        score += 1
        playSound(fileName: "tap", fileType: "mp3")

        withAnimation {
            showFeedback = true
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            withAnimation {
                showFeedback = false
            }
        }

        lightUpRandomCards()
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
            mode: .lightItUp,
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

            if fileName == "tap" {
                correctSoundPlayer = player
            } else if fileName == "gameover" {
                gameOverSoundPlayer = player
            }
        } catch {
            print("Could not play sound: \(error.localizedDescription)")
        }
    }

    private var levelColor: Color {
        switch currentLevel {
        case .l1: return GameTheme.neonGreen
        case .l2: return GameTheme.neonGold
        case .l3: return GameTheme.neonOrange
        case .l4: return Color.red
        }
    }
}

struct CardView: View {
    @Binding var card: Card
    let level: GameLevel

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 14)
                .fill(
                    card.isLit
                        ? AnyShapeStyle(levelGlowColor.gradient)
                        : AnyShapeStyle(Color.white.opacity(0.06))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .strokeBorder(
                            card.isLit ? levelGlowColor.opacity(0.9) : Color.white.opacity(0.12),
                            lineWidth: card.isLit ? 2 : 1
                        )
                )
                .shadow(color: card.isLit ? levelGlowColor.opacity(0.7) : .clear, radius: card.isLit ? 12 : 0)

            Image(systemName: card.isLit ? "bolt.fill" : "")
                .font(.title2.weight(.bold))
                .foregroundStyle(.white)
                .shadow(color: card.isLit ? levelGlowColor : .clear, radius: 6)
        }
        .aspectRatio(1, contentMode: .fit)
        .scaleEffect(card.isLit ? 1.06 : 1.0)
        .animation(.spring(response: 0.2, dampingFraction: 0.6), value: card.isLit)
        .accessibilityLabel(card.isLit ? "Lit card" : "Unlit card")
        .accessibilityAddTraits(card.isLit ? .isSelected : [])
    }

    private var levelGlowColor: Color {
        switch level {
        case .l1: return GameTheme.neonGreen
        case .l2: return GameTheme.neonGold
        case .l3: return GameTheme.neonOrange
        case .l4: return Color.red
        }
    }
}

#if DEBUG
#Preview {
    NavigationStack {
        LightItUpView()
    }
    .environmentObject(SessionStore())
    .environmentObject(LocationService())
    .preferredColorScheme(.dark)
}
#endif
