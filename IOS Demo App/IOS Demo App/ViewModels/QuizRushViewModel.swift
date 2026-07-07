import Foundation
import Combine
import SwiftUI

@MainActor
final class QuizRushViewModel: ObservableObject {
    enum ViewState: Equatable {
        case loading
        case loaded
        case failed(String)
        case finished
    }

    @Published private(set) var viewState: ViewState = .loading
    @Published private(set) var questions: [QuizRushQuestion] = []
    @Published private(set) var currentIndex = 0
    @Published private(set) var score = 0
    @Published private(set) var streak = 0
    @Published private(set) var revealedAnswer: String?
    @Published private(set) var flashCorrect = false
    @Published private(set) var flashWrong = false

    private let service: QuizRushQuestionFetching
    private let questionCount = 10

    init(service: QuizRushQuestionFetching? = nil) {
        self.service = service ?? OpenTriviaDBService()
    }

    var currentQuestion: QuizRushQuestion? {
        guard questions.indices.contains(currentIndex) else { return nil }
        return questions[currentIndex]
    }

    var progressText: String {
        guard !questions.isEmpty else { return "0 of \(questionCount)" }
        return "\(min(currentIndex + 1, questions.count)) of \(questions.count)"
    }

    var currentQuestionNumber: Int {
        min(currentIndex + 1, questions.count)
    }

    func load() async {
        viewState = .loading
        flashCorrect = false
        flashWrong = false
        revealedAnswer = nil

        do {
            let fetchedQuestions = try await service.fetchQuestions(count: questionCount)
            questions = Array(fetchedQuestions.prefix(questionCount))
            currentIndex = 0
            score = 0
            streak = 0
            viewState = .loaded
        } catch {
            viewState = .failed(error.localizedDescription)
        }
    }

    func retry() {
        Task {
            await load()
        }
    }

    func answerTapped(_ answer: String) {
        guard case .loaded = viewState,
              revealedAnswer == nil,
              let question = currentQuestion else { return }

        revealedAnswer = answer

        if answer == question.correctAnswer {
            handleCorrectAnswer()
        } else {
            handleWrongAnswer()
        }

        Task { @MainActor in
            try? await Task.sleep(nanoseconds: 650_000_000)
            advanceOrFinish()
        }
    }

    func restart() {
        Task {
            await load()
        }
    }

    private func handleCorrectAnswer() {
        streak += 1
        let bonus = min(max(streak - 1, 0), 2)
        score += 1 + bonus

        withAnimation(.spring(response: 0.25, dampingFraction: 0.55)) {
            flashCorrect = true
            flashWrong = false
        }
    }

    private func handleWrongAnswer() {
        streak = 0
        score = max(0, score - 1)

        withAnimation(.easeInOut(duration: 0.2)) {
            flashWrong = true
            flashCorrect = false
        }
    }

    private func advanceOrFinish() {
        flashCorrect = false
        flashWrong = false
        revealedAnswer = nil

        if currentIndex + 1 < questions.count {
            currentIndex += 1
        } else {
            viewState = .finished
        }
    }
}
