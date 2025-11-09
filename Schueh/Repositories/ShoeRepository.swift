import Foundation
import SwiftData

@MainActor
class ShoeRepository {
    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    func delete(_ shoe: Shoe) throws {
        modelContext.delete(shoe)
        try modelContext.save()
    }
    
    func toggleArchive(_ shoe: Shoe) throws {
        shoe.archived = shoe.isArchived ? nil : Date()
        try modelContext.save()
    }

    func assignWorkout(
        healthKitId: UUID,
        date: Date,
        distanceKm: Double,
        duration: TimeInterval,
        elevationGain: Double?,
        to shoe: Shoe
    ) throws {
        let descriptor = FetchDescriptor<WorkoutRecord>(
            predicate: #Predicate { $0.healthKitId == healthKitId }
        )

        if let existing = try? modelContext.fetch(descriptor).first {
            existing.shoe = shoe
        } else {
            let workout = WorkoutRecord(
                healthKitId: healthKitId,
                date: date,
                distanceKm: distanceKm,
                duration: duration,
                elevationGain: elevationGain
            )
            
            workout.shoe = shoe
            modelContext.insert(workout)
        }

        try modelContext.save()
    }
    
    func removeWorkout(
        _ workout: WorkoutRecord
    ) throws {
        modelContext.delete(workout)
        try modelContext.save()
    }
    
    func allAssignedHealthKitIds() throws -> Set<UUID> {
        let workouts = try modelContext.fetch(FetchDescriptor<WorkoutRecord>())
        return Set(workouts.map { $0.healthKitId })
    }
}
