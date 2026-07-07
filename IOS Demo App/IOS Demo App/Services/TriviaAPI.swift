import Foundation

protocol QuizRushQuestionFetching {
    func fetchQuestions(count: Int) async throws -> [QuizRushQuestion]
}

struct OpenTriviaDBService: QuizRushQuestionFetching {
    private let baseURL = URL(string: "https://opentdb.com/api.php")!

    func fetchQuestions(count: Int = 10) async throws -> [QuizRushQuestion] {
        var components = URLComponents(url: baseURL, resolvingAgainstBaseURL: false)
        components?.queryItems = [
            URLQueryItem(name: "amount", value: String(count)),
            URLQueryItem(name: "type", value: "multiple")
        ]

        guard let url = components?.url else {
            throw QuizRushServiceError.invalidURL
        }

        let (data, response) = try await URLSession.shared.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw QuizRushServiceError.invalidResponse
        }

        let decoded = try JSONDecoder().decode(TriviaAPIResponse.self, from: data)
        guard !decoded.results.isEmpty else {
            throw QuizRushServiceError.emptyResults
        }

        return decoded.results.prefix(count).map(QuizRushQuestion.init(apiQuestion:))
    }
}

enum QuizRushServiceError: LocalizedError {
    case invalidURL
    case invalidResponse
    case emptyResults

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "The trivia URL could not be created."
        case .invalidResponse:
            return "The trivia server returned an invalid response."
        case .emptyResults:
            return "No trivia questions were returned."
        }
    }
}
