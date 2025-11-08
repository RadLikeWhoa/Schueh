import Foundation

enum TimeRangeOption: String, CaseIterable, Identifiable {
    case days30 = "Last 30 Days"
    case days90 = "Last 90 Days"
    case days365 = "Last Year"
    case all = "All Time"

    var id: String { rawValue }
}
