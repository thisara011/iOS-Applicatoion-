import Foundation
import UIKit

struct TriviaAPIResponse: Decodable {
    let results: [TriviaAPIQuestion]
}

struct TriviaAPIQuestion: Decodable {
    let question: String
    let correctAnswer: String
    let incorrectAnswers: [String]

    enum CodingKeys: String, CodingKey {
        case question
        case correctAnswer = "correct_answer"
        case incorrectAnswers = "incorrect_answers"
    }
}

struct QuizRushQuestion: Identifiable, Equatable {
    let id = UUID()
    let question: String
    let correctAnswer: String
    let incorrectAnswers: [String]
    let answers: [String]

    init(question: String, correctAnswer: String, incorrectAnswers: [String]) {
        self.question = question
        self.correctAnswer = correctAnswer
        self.incorrectAnswers = incorrectAnswers
        self.answers = (incorrectAnswers + [correctAnswer]).shuffled()
    }

    init(apiQuestion: TriviaAPIQuestion) {
        self.init(
            question: apiQuestion.question.htmlUnescaped,
            correctAnswer: apiQuestion.correctAnswer.htmlUnescaped,
            incorrectAnswers: apiQuestion.incorrectAnswers.map { $0.htmlUnescaped }
        )
    }
}

extension String {
    var htmlUnescaped: String {
        guard let data = data(using: .utf8) else { return self }

        let options: [NSAttributedString.DocumentReadingOptionKey: Any] = [
            .documentType: NSAttributedString.DocumentType.html,
            .characterEncoding: String.Encoding.utf8.rawValue
        ]

        if let attributed = try? NSAttributedString(data: data, options: options, documentAttributes: nil) {
            return attributed.string
        }

        return self
    }
}
