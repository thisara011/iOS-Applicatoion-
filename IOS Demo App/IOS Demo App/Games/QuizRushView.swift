import SwiftUI

struct QuizRushView: View {
    @EnvironmentObject private var sessionStore: SessionStore
    @EnvironmentObject private var locationService: LocationService
    @AppStorage("quizRushHighScore") private var highScore = 0
    @StateObject private var viewModel: QuizRushViewModel
    @State private var didRecordSession = false

    @MainActor
    init() {
        _viewModel = StateObject(wrappedValue: QuizRushViewModel())
    }

    @MainActor
    init(viewModel: QuizRushViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        ZStack {
            GameBackground(accent: flashAccent, intensity: flashIntensity)
                .ignoresSafeArea()

            content
                .padding()
        }
        .toolbarBackground(.hidden, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .navigationTitle(GameMode.quizRush.displayName)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            if case .loaded = viewModel.viewState {
                ToolbarItem(placement: .topBarTrailing) {
                    HStack(spacing: 6) {
                        GameHUD(score: viewModel.score, best: highScore, label: "PTS", compact: true)
                        streakBadge
                    }
                }
            }
        }
        .task {
            if case .loading = viewModel.viewState {
                await viewModel.load()
            }
        }
        .onChange(of: viewModel.viewState) { _, newValue in
            if case .finished = newValue {
                highScore = max(highScore, viewModel.score)
                recordFinishedSessionIfNeeded()
            } else {
                didRecordSession = false
            }
        }
    }

    private func recordFinishedSessionIfNeeded() {
        guard !didRecordSession else { return }
        sessionStore.recordGame(
            mode: .quizRush,
            score: viewModel.score,
            coordinate: locationService.currentCoordinate
        )
        didRecordSession = true
    }

    private var flashIntensity: Double {
        if viewModel.flashCorrect { return 0.55 }
        if viewModel.flashWrong { return 0.5 }
        return 0.35
    }

    private var flashAccent: Color {
        if viewModel.flashCorrect { return GameTheme.neonGreen }
        if viewModel.flashWrong { return Color.red }
        return GameTheme.neonPurple
    }

    private var streakBadge: some View {
        HStack(spacing: 4) {
            Image(systemName: "flame.fill")
                .foregroundStyle(GameTheme.neonOrange)
            Text("\(viewModel.streak)")
                .font(.caption.weight(.bold))
                .foregroundStyle(.white)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(Color.black.opacity(0.45), in: Capsule())
        .overlay(Capsule().strokeBorder(GameTheme.neonOrange.opacity(0.5), lineWidth: 1))
    }

    @ViewBuilder
    private var content: some View {
        switch viewModel.viewState {
        case .loading:
            loadingView
        case .failed(let message):
            failureView(message: message)
        case .loaded:
            loadedView
        case .finished:
            resultsView
        }
    }

    private var loadingView: some View {
        VStack(spacing: 20) {
            ProgressView()
                .tint(GameTheme.neonCyan)
                .scaleEffect(1.4)
            Text("LOADING TRIVIA")
                .font(.headline.weight(.black))
                .tracking(2)
                .foregroundStyle(.white)
            Text("Fetching 10 live questions…")
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.6))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func failureView(message: String) -> some View {
        VStack(spacing: 20) {
            Image(systemName: "wifi.exclamationmark")
                .font(.system(size: 48))
                .foregroundStyle(GameTheme.neonPink)

            Text("CONNECTION LOST")
                .font(.title2.weight(.black))
                .foregroundStyle(.white)

            Text(message)
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.6))
                .multilineTextAlignment(.center)

            GamePrimaryButton(title: "Retry") {
                viewModel.retry()
            }
            .padding(.horizontal)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var loadedView: some View {
        ScrollView {
            VStack(spacing: 20) {
                questionCard
                answerGrid
            }
        }
        .gamePlayScroll()
    }

    private var resultsView: some View {
        GameResultView(
            mode: .quizRush,
            score: viewModel.score,
            best: highScore,
            extraStats: [("Streak", "\(viewModel.streak)")],
            onPlayAgain: { viewModel.restart() }
        )
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var questionCard: some View {
        GamePanel {
            VStack(alignment: .leading, spacing: 14) {
                HStack {
                    Text(viewModel.progressText.uppercased())
                        .font(.caption.weight(.heavy))
                        .tracking(1.5)
                        .foregroundStyle(GameTheme.neonCyan)
                    Spacer()
                    Text("BEST \(highScore)")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(GameTheme.neonGold)
                }

                if let question = viewModel.currentQuestion {
                    Text(question.question)
                        .font(.title3.weight(.bold))
                        .foregroundStyle(.white)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
    }

    private var answerGrid: some View {
        VStack(spacing: 12) {
            if let question = viewModel.currentQuestion {
                ForEach(Array(question.answers.enumerated()), id: \.element) { index, answer in
                    Button {
                        viewModel.answerTapped(answer)
                    } label: {
                        HStack(spacing: 12) {
                            Text(answerLetter(for: index))
                                .font(.headline.weight(.black))
                                .foregroundStyle(GameTheme.neonCyan)
                                .frame(width: 28, height: 28)
                                .background(Color.white.opacity(0.1), in: Circle())

                            Text(answer)
                                .fontWeight(.semibold)
                                .multilineTextAlignment(.leading)
                                .foregroundStyle(.white)

                            Spacer()
                        }
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(answerBackground(for: answer, question: question), in: RoundedRectangle(cornerRadius: 14))
                        .overlay(
                            RoundedRectangle(cornerRadius: 14)
                                .strokeBorder(answerBorder(for: answer, question: question), lineWidth: 1.5)
                        )
                    }
                    .buttonStyle(.plain)
                    .disabled(viewModel.revealedAnswer != nil)
                    .modifier(ShakeEffect(animatableData: viewModel.flashWrong ? 1 : 0))
                }
            }
        }
    }

    private func answerLetter(for index: Int) -> String {
        String(UnicodeScalar(65 + index)!)
    }

    private func answerBackground(for answer: String, question: QuizRushQuestion) -> Color {
        guard let revealed = viewModel.revealedAnswer else {
            return Color.white.opacity(0.08)
        }

        if answer == question.correctAnswer {
            return GameTheme.neonGreen.opacity(0.25)
        }

        if answer == revealed {
            return Color.red.opacity(0.25)
        }

        return Color.white.opacity(0.04)
    }

    private func answerBorder(for answer: String, question: QuizRushQuestion) -> Color {
        guard let revealed = viewModel.revealedAnswer else {
            return Color.white.opacity(0.15)
        }

        if answer == question.correctAnswer {
            return GameTheme.neonGreen.opacity(0.7)
        }

        if answer == revealed {
            return Color.red.opacity(0.7)
        }

        return Color.white.opacity(0.08)
    }
}

private struct ShakeEffect: GeometryEffect {
    var amount: CGFloat = 8
    var shakesPerUnit: CGFloat = 3
    var animatableData: CGFloat

    func effectValue(size: CGSize) -> ProjectionTransform {
        ProjectionTransform(CGAffineTransform(translationX: amount * sin(animatableData * .pi * shakesPerUnit), y: 0))
    }
}

#if DEBUG
private struct PreviewQuizRushService: QuizRushQuestionFetching {
    func fetchQuestions(count: Int) async throws -> [QuizRushQuestion] {
        [
            QuizRushQuestion(
                question: "What is the capital of Japan?",
                correctAnswer: "Tokyo",
                incorrectAnswers: ["Kyoto", "Osaka", "Sapporo"]
            ),
            QuizRushQuestion(
                question: "Which planet is known as the Red Planet?",
                correctAnswer: "Mars",
                incorrectAnswers: ["Venus", "Jupiter", "Mercury"]
            )
        ]
    }
}

struct QuizRushView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            QuizRushView(viewModel: QuizRushView.previewViewModel)
        }
        .environmentObject(SessionStore())
        .environmentObject(LocationService())
        .preferredColorScheme(.dark)
    }
}
#endif

private extension QuizRushView {
    @MainActor
    static var previewViewModel: QuizRushViewModel {
        QuizRushViewModel(service: PreviewQuizRushService())
    }
}
