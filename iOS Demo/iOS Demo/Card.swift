import Foundation

struct Card: Identifiable {
    let id: UUID
    var isLit: Bool
    
    init(id: UUID = UUID(), isLit: Bool = false) {
        self.id = id
        self.isLit = isLit
    }
}

enum GameLevel: Int, CaseIterable {
    case l1 = 1
    case l2 = 2
    case l3 = 3
    case l4 = 4
    
    var cardCount: Int {
        switch self {
        case .l1: return 3
        case .l2: return 4
        case .l3: return 6
        case .l4: return 9
        }
    }
    
    var columnsPerRow: Int {
        switch self {
        case .l1: return 3
        case .l2: return 4
        case .l3: return 3
        case .l4: return 3
        }
    }
    
    var litWindowDuration: Double {
        switch self {
        case .l1: return 1.5
        case .l2: return 1.2
        case .l3: return 1.0
        case .l4: return 0.8
        }
    }
    
    var cardsToLight: Int {
        switch self {
        case .l4: return 2
        default: return 1
        }
    }
    
    var glowColor: UInt32 {
        switch self {
        case .l1: return 0x00FF00 // Green
        case .l2: return 0xFFFF00 // Yellow
        case .l3: return 0xFF8800 // Orange
        case .l4: return 0xFF0000 // Red
        }
    }
    
    static func levelForTime(_ elapsed: Int) -> GameLevel {
        switch elapsed {
        case 0..<15:
            return .l1
        case 15..<30:
            return .l2
        case 30..<45:
            return .l3
        default:
            return .l4
        }
    }
}
