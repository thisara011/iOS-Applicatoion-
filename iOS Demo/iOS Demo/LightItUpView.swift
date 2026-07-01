import SwiftUI
import AVFoundation

struct LightItUpView: View {
    @Environment(\.dismiss) var dismiss
    @AppStorage("lightItUpHighScore") private var highScore = 0
    
    @State private var cards: [Card] = []
    @State private var score = 0
    @State private var timeRemaining = 60
    @State private var isGameRunning = false
    @State private var timer: Timer?
    @State private var currentLevel: GameLevel = .l1
    @State private var elapsedTime = 0
    @State private var showYeeee = false
    
    @State private var correctSoundPlayer: AVAudioPlayer?
    @State private var incorrectSoundPlayer: AVAudioPlayer?
    @State private var gameOverSoundPlayer: AVAudioPlayer?
    
    var body: some View {
        ZStack {
            // Background changes with level
            levelBackgroundColor
                .ignoresSafeArea()
            
            VStack(spacing: 16) {
                // MARK: Header with High Score
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
                .padding()
                
                // MARK: Level & Timer
                VStack(spacing: 12) {
                    HStack(spacing: 16) {
                        Text("Level \(currentLevel.rawValue)")
                            .font(.headline)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(levelColor)
                            .foregroundStyle(.white)
                            .clipShape(Capsule())
                        
                        Spacer()
                        
                        Text("\(timeRemaining)s")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundStyle(timeRemaining <= 10 ? .red : .primary)
                            .monospacedDigit()
                    }
                    .padding(.horizontal)
                    
                    if showYeeee {
                        Text("Correct! +1")
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundStyle(.green)
                            .transition(.scale.combined(with: .opacity))
                    }
                }
                
                Spacer()
                
                // MARK: Card Grid
                if !cards.isEmpty {
                    let gridItems = Array(repeating: GridItem(.flexible(), spacing: 12), count: currentLevel.columnsPerRow)
                    
                    LazyVGrid(columns: gridItems, spacing: 12) {
                        ForEach($cards) { $card in
                            CardView(card: $card, level: currentLevel)
                                .onTapGesture {
                                    cardTapped(card)
                                }
                        }
                    }
                    .padding()
                }
                
                Spacer()
                
                // MARK: Start Button
                if !isGameRunning {
                    Button(action: startGame) {
                        Text("Start Game")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundStyle(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .padding()
                }
            }
        }
        .onAppear(perform: setupGame)
    }
    
    // MARK: Card View Component
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
        
        // Initial light up
        lightUpRandomCards()
    }
    
    private func lightUpRandomCards() {
        // Dim all first
        for i in 0..<cards.count {
            cards[i].isLit = false
        }
        
        // Light up random cards
        let cardsToLight = currentLevel.cardsToLight
        let shuffled = (0..<cards.count).shuffled()
        
        for i in 0..<min(cardsToLight, shuffled.count) {
            cards[shuffled[i]].isLit = true
        }
        
        // Auto-dim after window duration
        DispatchQueue.main.asyncAfter(deadline: .now() + currentLevel.litWindowDuration) {
            for i in 0..<cards.count {
                cards[i].isLit = false
            }
        }
    }
    
    private func cardTapped(_ card: Card) {
        guard isGameRunning else { return }
        
        if card.isLit {
            score += 1
            playSound(fileName: "tap", fileType: "mp3")
            
            withAnimation {
                showYeeee = true
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                withAnimation {
                    showYeeee = false
                }
            }
            
            // Immediately light new cards
            lightUpRandomCards()
        }
    }
    
    private func endGame() {
        timer?.invalidate()
        timer = nil
        isGameRunning = false
        
        playSound(fileName: "gameover", fileType: "mp3")
        
        // Update high score
        if score > highScore {
            highScore = score
        }
    }
    
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
        case .l1: return .green
        case .l2: return .yellow
        case .l3: return .orange
        case .l4: return .red
        }
    }
    
    private var levelBackgroundColor: Color {
        if isGameRunning && timeRemaining <= 10 {
            return levelColor.opacity(0.1)
        } else {
            return Color(.systemBackground)
        }
    }
}

// MARK: Card View Component
struct CardView: View {
    @Binding var card: Card
    let level: GameLevel
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12)
                .fill(card.isLit ? levelGlowColor : Color.gray.opacity(0.3))
                .shadow(color: card.isLit ? levelGlowColor.opacity(0.6) : .clear, radius: card.isLit ? 8 : 0)
            
            Text(card.isLit ? "✓" : "")
                .font(.title)
                .fontWeight(.bold)
                .foregroundStyle(.white)
        }
        .aspectRatio(1, contentMode: .fit)
        .scaleEffect(card.isLit ? 1.05 : 1.0)
        .animation(.easeInOut(duration: 0.1), value: card.isLit)
    }
    
    private var levelGlowColor: Color {
        switch level {
        case .l1: return .green
        case .l2: return .yellow
        case .l3: return .orange
        case .l4: return .red
        }
    }
}

#Preview {
    LightItUpView()
}
