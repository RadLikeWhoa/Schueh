import Foundation
import SwiftData

@Model
final class Shoe {
    var id: UUID
    var name: String
    var color: String?
    var created: Date
    var purchased: Date
    var targetDistance: Int
    var archived: Date?

    @Relationship(deleteRule: .cascade)
    var workouts: [WorkoutRecord] = []

    init(
        name: String,
        targetDistance: Int,
        archived: Date? = nil,
        color: String? = nil,
        purchased: Date,
    ) {
        self.id = UUID()
        self.name = name
        self.targetDistance = targetDistance
        self.archived = archived
        self.color = color
        self.created = Date()
        self.purchased = purchased
    }

    var totalKilometers: Double {
        max(0, workouts.reduce(0) { $0 + $1.distanceKm })
    }

    var totalDuration: Double {
        max(0, workouts.reduce(0) { $0 + $1.duration })
    }

    var numberOfRuns: Int {
        workouts.count
    }

    var averageKmPerRun: Double? {
        guard numberOfRuns > 0 else { return nil }
        return totalKilometers / Double(numberOfRuns)
    }

    var averageKmPerWeek: Double? {
        guard let firstWorkout = workouts.min(by: { $0.date < $1.date }) else {
            return nil
        }

        let weeksSinceFirst =
            Calendar.current.dateComponents(
                [.weekOfYear],
                from: firstWorkout.date,
                to: archived ?? Date()
            ).weekOfYear ?? 1

        guard weeksSinceFirst > 0 else { return totalKilometers }

        return totalKilometers / Double(weeksSinceFirst)
    }

    var age: Int? {
        let age = Calendar.current.dateComponents(
            [.day],
            from: purchased,
            to: archived ?? Date()
        ).day
        
        guard age != nil, age! > 0 else { return 0 }
        return age
    }

    var lastWorkoutDate: Date? {
        workouts.max(by: { $0.date < $1.date })?.date
    }

    var progress: Double {
        guard targetDistance > 0 else { return 0 }
        return totalKilometers / Double(targetDistance) * 100
    }

    var remainder: Double {
        max(Double(targetDistance) - totalKilometers, 0)
    }

    var maximumDistance: Double? {
        workouts.max(by: { $0.distanceKm < $1.distanceKm })?.distanceKm
    }

    var daysRemaining: Int? {
        guard averageKmPerWeek != nil, averageKmPerWeek! > 0 else { return nil }
        return Int(ceil(remainder / averageKmPerWeek! * 7))
    }

    var hasExpired: Bool {
        remainder <= 0
    }

    var closeToExpiration: Bool {
        progress >= 80
    }

    var isArchived: Bool {
        archived != nil
    }
}
