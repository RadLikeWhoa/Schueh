import Foundation

enum ShoesSortOption: String, CaseIterable, Identifiable {
    case daysRemaining = "Days Remaining"
    case name = "Name"
    case totalDistance = "Total Distance"
    case recentlyUsed = "Recently Used"
    case age = "Age"

    var id: String { rawValue }

    var systemImage: String {
        switch self {
        case .daysRemaining:
            return "arrow.right.to.line"
        case .recentlyUsed:
            return "clock.arrow.circlepath"
        case .age:
            return "calendar"
        case .name:
            return "textformat.abc"
        case .totalDistance:
            return "chart.line.uptrend.xyaxis"
        }
    }
}
