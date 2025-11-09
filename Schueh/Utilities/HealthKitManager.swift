import HealthKit
import Observation

@Observable
class HealthKitManager {
    private let healthStore = HKHealthStore()

    var isAvailable: Bool {
        HKHealthStore.isHealthDataAvailable()
    }

    func requestAuthorization() async throws {
        guard isAvailable else { return }

        let workoutType = HKObjectType.workoutType()

        let distanceType = HKObjectType.quantityType(
            forIdentifier: .distanceWalkingRunning
        )!
        
        try await healthStore.requestAuthorization(
            toShare: [],
            read: [workoutType, distanceType]
        )
    }

    func fetchRunningWorkouts(from startDate: Date? = nil) async throws
        -> [HKWorkout]
    {
        guard isAvailable else { return [] }

        var predicates = [HKQuery.predicateForWorkouts(with: .running)]

        if let startDate = startDate {
            predicates.append(
                HKQuery.predicateForSamples(
                    withStart: startDate,
                    end: Date(),
                    options: .strictStartDate
                )
            )
        }

        return try await withCheckedThrowingContinuation { continuation in
            let query = HKSampleQuery(
                sampleType: HKObjectType.workoutType(),
                predicate: NSCompoundPredicate(
                    andPredicateWithSubpredicates: predicates
                ),
                limit: HKObjectQueryNoLimit,
                sortDescriptors: [
                    NSSortDescriptor(
                        key: HKSampleSortIdentifierStartDate,
                        ascending: false
                    )
                ]
            ) { _, samples, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }

                let workouts = samples as? [HKWorkout] ?? []
                continuation.resume(returning: workouts)
            }

            healthStore.execute(query)
        }
    }
}
