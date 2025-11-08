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

            let assignedIds = try repository.allAssignedHealthKitIds()
            let allWorkouts = try await healthKitManager.fetchRunningWorkouts()

            let timeRangeRaw = UserDefaults.standard.string(forKey: "timeRange") ?? TimeRangeOption.days30.rawValue
            let timeRange = TimeRangeOption(rawValue: timeRangeRaw) ?? .days30

            let now = Date()
            let filteredWorkouts: [HKWorkout]

            switch timeRange {
            case .days30:
                let fromDate = Calendar.current.date(byAdding: .day, value: -30, to: now)!
                filteredWorkouts = allWorkouts.filter { $0.startDate >= fromDate }
            case .days90:
                let fromDate = Calendar.current.date(byAdding: .day, value: -90, to: now)!
                filteredWorkouts = allWorkouts.filter { $0.startDate >= fromDate }
            case .days365:
                let fromDate = Calendar.current.date(byAdding: .day, value: -365, to: now)!
                filteredWorkouts = allWorkouts.filter { $0.startDate >= fromDate }
            case .all:
                filteredWorkouts = allWorkouts
            }

            availableWorkouts = filteredWorkouts.filter { !assignedIds.contains($0.uuid) }

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
    
    func toggleArchive() {
        do {
            try repository.toggleArchive(shoe)
        } catch {
            errorMessage =
            "Failed to \(shoe.isArchived ? "unarchive" : "archive") shoe: \(error.localizedDescription)"
        }
    }
}
