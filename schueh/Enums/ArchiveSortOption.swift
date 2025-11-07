import Foundation

enum ArchiveSortOption: String, CaseIterable, Identifiable {
    case name = "Name"
    case totalDistance = "Total Distance"
    case age = "Age"

    var id: String { rawValue }

    var systemImage: String {
        switch self {
        case .age:
            return "calendar"
        case .name:
            return "textformat.abc"
        case .totalDistance:
            return "chart.line.uptrend.xyaxis"
        }
    }
}
