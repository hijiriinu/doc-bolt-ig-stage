import Foundation

enum AppSection: String, CaseIterable, Identifiable {
    case home
    case explanation
    case remedies
    case alternatives
    case diagnosis

    var id: Self { self }

    var title: String {
        switch self {
        case .home: return "ホーム"
        case .explanation: return "解説"
        case .remedies: return "対処法"
        case .alternatives: return "代替ツール"
        case .diagnosis: return "診断"
        }
    }

    var icon: String {
        switch self {
        case .home: return "house"
        case .explanation: return "text.book.closed"
        case .remedies: return "wrench.and.screwdriver"
        case .alternatives: return "square.grid.2x2"
        case .diagnosis: return "checklist"
        }
    }
}
