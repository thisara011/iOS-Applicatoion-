import Foundation
import SwiftData

@Model
final class Item {
    var score: Int
    var playedAt: Date

    init(score: Int, playedAt: Date = Date()) {
        self.score = score
        self.playedAt = playedAt
    }
}
