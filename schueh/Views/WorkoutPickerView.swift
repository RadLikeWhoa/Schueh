import HealthKit
import SwiftUI

struct WorkoutPickerView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel: ShoeDetailViewModel?

    let shoeViewModel: ShoeDetailViewModel?

    init(viewModel: ShoeDetailViewModel?) {
        self.shoeViewModel = viewModel
    }

    var body: some View {
        Group {
            if let viewModel = shoeViewModel {
                if viewModel.isLoading {
                    ProgressView("Loading workouts...")
                } else if viewModel.availableWorkouts.isEmpty {
                    ContentUnavailableView(
                        "No Workouts Found",
                        systemImage: "figure.run",
                        description: Text(
                            "No running workouts found in Apple Health"
                        )
                    )
                } else {
                    List {
                        ForEach(viewModel.availableWorkouts, id: \.uuid) {
                            workout in
                            WorkoutPickerRow(
                                workout: workout,
                                isAssigned: isWorkoutAssigned(workout),
                                onTap: {
                                    viewModel.assignWorkout(workout)
                                    dismiss()
                                }
                            )
                        }
                    }
                }
            }
        }
        .navigationTitle("Select Workout")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Done") {
                    dismiss()
                }
            }
        }
        .task {
            await shoeViewModel?.loadAvailableWorkouts()
        }
    }

    private func isWorkoutAssigned(_ workout: HKWorkout) -> Bool {
        guard let viewModel = shoeViewModel else { return false }

        return viewModel.shoe.workouts.contains {
            $0.healthKitId == workout.uuid
        }
    }
}
