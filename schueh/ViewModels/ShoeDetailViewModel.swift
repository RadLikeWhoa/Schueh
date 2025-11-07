import Foundation
import HealthKit
import SwiftData

@MainActor
@Observable
class ShoeDetailViewModel {
    private let repository: ShoeRepository
    private let healthKitManager: HealthKitManager

    let shoe: Shoe
    var availableWorkouts: [HKWorkout] = []
    var isLoading = false
    var errorMessage: String?

    init(
        shoe: Shoe,
        repository: ShoeRepository,
        healthKitManager: HealthKitManager
    ) {
        self.shoe = shoe
        self.repository = repository
        self.healthKitManager = healthKitManager
    }

    func loadAvailableWorkouts() async {
        isLoading = true

        defer { isLoading = false }

        do {
            try await healthKitManager.requestAuthorization()

            availableWorkouts =
                try await healthKitManager.fetchRunningWorkouts()
        } catch {
            errorMessage =
                "Failed to load workouts: \(error.localizedDescription)"
        }
    }

    func assignWorkout(_ workout: HKWorkout) {
        guard let distance = workout.totalDistance else { return }

        do {
            try repository.assignWorkout(
                healthKitId: workout.uuid,
                date: workout.startDate,
                distanceKm: distance.doubleValue(for: .meterUnit(with: .kilo)),
                duration: workout.duration,
                elevationGain: workout.metadata?[HKMetadataKeyElevationAscended] as? Double,
                to: shoe
            )
        } catch {
            errorMessage =
                "Failed to assign workout: \(error.localizedDescription)"
        }
    }
    
    func deleteShoe() {
        do {
            try repository.delete(shoe)
        } catch {
            errorMessage =
                "Failed to delete shoe: \(error.localizedDescription)"
        }
    }
    
    func toggleArchive() {
        do {
            try repository.toggleArchive(shoe)
        } catch {
            errorMessage =
            "Failed to \(shoe.archived ? "unarchive" : "archive") shoe: \(error.localizedDescription)"
        }
    }
}
