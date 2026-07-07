import Foundation
import Combine
import CoreLocation

final class SessionStore: ObservableObject {
    @Published private(set) var sessions: [GameSession] = []

    private let key = "playhub_sessions_v1"
    private var cancellables = Set<AnyCancellable>()

    init() {
        load()

        $sessions
            .sink { [weak self] _ in
                self?.save()
            }
            .store(in: &cancellables)
    }

    var totalGames: Int { sessions.count }

    var recentSessions: [GameSession] {
        Array(sessions.prefix(10))
    }

    func bestScore(for mode: GameMode) -> Int? {
        sessions
            .filter { $0.mode == mode }
            .map(\.score)
            .max()
    }

    func sessions(for mode: GameMode) -> [GameSession] {
        sessions.filter { $0.mode == mode }
    }

    func totalScore(for mode: GameMode) -> Int {
        sessions(for: mode).map(\.score).reduce(0, +)
    }

    func add(_ session: GameSession) {
        sessions.insert(session, at: 0)
    }

    func recordGame(mode: GameMode, score: Int, coordinate: CLLocationCoordinate2D?) {
        add(GameSession(mode: mode, score: score, coordinate: coordinate))
    }

    func clear() {
        sessions.removeAll()
    }

    func remove(atOffsets offsets: IndexSet) {
        for index in offsets.sorted(by: >) {
            if sessions.indices.contains(index) {
                sessions.remove(at: index)
            }
        }
    }

    func resetAllStats() {
        clear()
        let defaults = UserDefaults.standard
        defaults.removeObject(forKey: "tapFrenzyHighScore")
        defaults.removeObject(forKey: "lightItUpHighScore")
        defaults.removeObject(forKey: "quizRushHighScore")
    }

    private func save() {
        do {
            let data = try JSONEncoder().encode(sessions)
            UserDefaults.standard.set(data, forKey: key)
        } catch {
            print("SessionStore save error: \(error)")
        }
    }

    private func load() {
        guard let data = UserDefaults.standard.data(forKey: key) else { return }
        do {
            sessions = try JSONDecoder().decode([GameSession].self, from: data)
        } catch {
            print("SessionStore load error: \(error)")
        }
    }
}
