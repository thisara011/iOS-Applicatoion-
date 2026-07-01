import SwiftUI
import SwiftData
import AVFoundation

struct TapFrenzyView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) var dismiss
    @Query(sort: \Item.playedAt, order: .reverse) private var history: [Item]
    @AppStorage("tapFrenzyHighScore") private var highScore = 0

    @State private var score = 0
    @State private var timeRemaining = 20
    @State private var isGameRunning = false
    @State private var showYeeee = false
    @State private var timer: Timer?

    @State private var tapSoundPlayer: AVAudioPlayer?
    @State private var warningSoundPlayer: AVAudioPlayer?
    @State private var gameOverSoundPlayer: AVAudioPlayer?

    var body: some View {
        ZStack {
            backgroundColor
                .ignoresSafeArea()

            VStack(spacing: 28) {

                // MARK: Header with Back Button
                HStack {
                    Button("← Back") {
                        dismiss()
                    }
                    .font(.headline)
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 4) {
                        Text("Score: \(score)")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .contentTransition(.numericText())
                        
                        Text("Best: \(highScore)")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                .padding(.horizontal)

                // MARK: Title
                Text("Tap Frenzy")
                    .font(.largeTitle)
                    .fontWeight(.bold)

                if showYeeee {
                    Text("Yeeee! 🎉")
                        .font(.title2)
                        .fontWeight(.bold)
                        .transition(.scale.combined(with: .opacity))
                }

                Spacer()

                // MARK: Middle Hit Button
                Button {
                    hitButtonTapped()
                } label: {
                    ZStack {
                        Circle()
                            .fill(.blue.gradient)
                            .frame(width: 190, height: 210)
                            .shadow(radius: 12)

                        Image("tapImage")
                            .resizable()
                            .scaledToFill()
                            .frame(width: 180, height: 150)
                            .clipShape(Circle())

                        Text("Hit Me")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundStyle(.white)
                            .padding(.top, 160)
                    }
                }
                .disabled(!isGameRunning)
                .scaleEffect(showYeeee ? 1.08 : 1.0)
                .animation(.spring(response: 0.25, dampingFraction: 0.5), value: showYeeee)
                .accessibilityLabel("Hit Me button")
                .accessibilityHint("Tap to increase your score by one point")

                Spacer()

                // MARK: Timer Area
                VStack(spacing: 12) {
                    Text("Timer")
                        .font(.headline)

                    Text("\(timeRemaining) seconds")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundStyle(timeRemaining <= 5 ? .red : .primary)

                    Button {
                        startGame()
                    } label: {
                        Text(isGameRunning ? "Game Running..." : "Start Game")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(isGameRunning ? Color.gray : Color.blue)
                            .foregroundStyle(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                    }
                    .disabled(isGameRunning)
                    .padding(.horizontal)
                }

                // MARK: Player History
                VStack(alignment: .leading, spacing: 8) {
                    Text("Player History")
                        .font(.headline)
                        .padding(.horizontal)

                    if history.isEmpty {
                        Text("No games played yet.")
                            .foregroundStyle(.secondary)
                            .padding(.horizontal)
                    } else {
                        List {
                            ForEach(history.prefix(5)) { item in
                                HStack {
                                    Text("Score: \(item.score)")
                                    Spacer()
                                    Text(item.playedAt, style: .time)
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }
                        .frame(height: 150)
                        .scrollContentBackground(.hidden)
                    }
                }
            }
            .padding()
        }
    }

    // MARK: Background Warning Color
    private var backgroundColor: Color {
        if isGameRunning && timeRemaining <= 5 {
            return Color.red.opacity(0.18)
        } else {
            return Color(.systemBackground)
        }
    }

    // MARK: Hit Button Action
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

    // MARK: Start Game
    private func startGame() {
        score = 0
        timeRemaining = 20
        isGameRunning = true

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

    // MARK: End Game
    private func endGame() {
        timer?.invalidate()
        timer = nil
        isGameRunning = false

        playSound(fileName: "gameover", fileType: "mp3")

        let newHistory = Item(score: score)
        modelContext.insert(newHistory)
        
        // Update high score
        if score > highScore {
            highScore = score
        }
    }

    // MARK: Play Sound
    private func playSound(fileName: String, fileType: String) {
        guard let path = Bundle.main.path(forResource: fileName, ofType: fileType) else {
            print("Sound file not found: \(fileName).\(fileType)")
            return
        }

        let url = URL(fileURLWithPath: path)

        do {
            let player = try AVAudioPlayer(contentsOf: url)
            player.play()

            if fileName == "tap" {
                tapSoundPlayer = player
            } else if fileName == "warning" {
                warningSoundPlayer = player
            } else if fileName == "gameover" {
                gameOverSoundPlayer = player
            }

        } catch {
            print("Could not play sound: \(error.localizedDescription)")
        }
    }
}

#Preview {
    TapFrenzyView()
        .modelContainer(for: Item.self, inMemory: true)
}

// Backwards compatibility alias
typealias ContentView = TapFrenzyView
