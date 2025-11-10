import Foundation
import SwiftUI

enum UnitOption: String, CaseIterable, Identifiable {
    case system = "System"
    case metric = "Metric"
    case imperial = "Imperial"

    var id: String { rawValue }

    static var user: UnitOption {
        let stored = UserDefaults.standard.string(forKey: "unitOption")
        return UnitOption(rawValue: stored ?? "") ?? .system
    }

    static var current: UnitOption {
        switch user {
        case .system:
            let usesMetric =
                Locale.current.measurementSystem == .metric

            return usesMetric ? .metric : .imperial

        default:
            return user
        }
    }

    var distanceUnit: String {
        switch self {
        case .imperial:
            return "mi"

        default:
            return "km"
        }
    }

    var elevationUnit: String {
        switch self {
        case .imperial:
            return "ft"

        default:
            return "m"
        }
    }

    func convertDistance(kilometers: Double) -> Double {
        switch self {
        case .imperial:
            return kilometers * 0.621371
        default:
            return kilometers
        }
    }

    func convertDistanceToKilometers(distance: Double) -> Double {
        switch self {
        case .imperial:
            return distance / 0.621371
        default:
            return distance
        }
    }

    func convertElevation(meters: Double) -> Double {
        switch self {
        case .imperial:
            return meters * 3.28084
        default:
            return meters
        }
    }

    func formatDistance(_ kilometers: Double, fractionDigits: Int = 2) -> String
    {
        let value = convertDistance(kilometers: kilometers)

        let formatter = NumberFormatter()
        formatter.minimumFractionDigits = fractionDigits
        formatter.maximumFractionDigits = fractionDigits

        let string =
            formatter.string(from: NSNumber(value: value)) ?? "\(value)"

        return "\(string) \(distanceUnit)"
    }

    func formatElevation(_ meters: Double, fractionDigits: Int = 0) -> String {
        let value = convertElevation(meters: meters)

        let formatter = NumberFormatter()
        formatter.minimumFractionDigits = fractionDigits
        formatter.maximumFractionDigits = fractionDigits

        let string =
            formatter.string(from: NSNumber(value: value)) ?? "\(value)"

        return "\(string) \(elevationUnit)"
    }
}
