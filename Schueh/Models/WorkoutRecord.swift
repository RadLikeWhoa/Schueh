import Foundation
import SwiftData

@Model
final class WorkoutRecord {
    var id: UUID
    var healthKitId: UUID
    var date: Date
    var distanceKm: Double
    var duration: TimeInterval
    var shoe: Shoe?

    init(
        healthKitId: UUID,
        date: Date,
        distanceKm: Double,
        duration: TimeInterval
    ) {
        self.id = UUID()
        self.healthKitId = healthKitId
        self.date = date
        self.distanceKm = distanceKm
        self.duration = duration
    }
}
