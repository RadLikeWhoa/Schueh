import HealthKit
import SwiftUI

struct WorkoutPickerView: View {
    @Environment(\.dismiss) private var dismiss

    @State private var selection = Set<HKWorkout>()

    let shoeViewModel: ShoeDetailViewModel?

    init(viewModel: ShoeDetailViewModel?) {
        self.shoeViewModel = viewModel
    }

    var body: some View {
        NavigationStack {
            Group {
                if let viewModel = shoeViewModel {
                    if viewModel.isLoading {
                        ProgressView("Loading workouts...")
                    } else if viewModel.availableWorkouts.isEmpty {
                        ContentUnavailableView(
                            "No Workouts Found",
                            systemImage: "figure.run",
                            description: Text(
                                "No running workouts found in Apple Health."
                            )
                        )
                    } else {
                        List(
                            viewModel.availableWorkouts,
                            id: \.self,
                            selection: $selection
                        ) {
                            workout in
                            WorkoutPickerRow(workout: workout)
                        }
                        .environment(\.editMode, .constant(EditMode.active))
                    }
                }
            }
            .contentMargins(.top, 16)
            .navigationTitle("Assign Workouts")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", systemImage: "xmark") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Save", systemImage: "checkmark") {
                        selection.forEach { workout in
                            shoeViewModel?.assignWorkout(workout)
                        }
                        
                        dismiss()
                    }
                    .disabled(selection.isEmpty)
                }

                if let viewModel = shoeViewModel {
                    if !viewModel.availableWorkouts.isEmpty {
                        ToolbarItem(placement: .bottomBar) {
                            if viewModel.availableWorkouts.count == selection.count
                            {
                                Button("Deselect All") {
                                    selection.removeAll()
                                }
                            } else {
                                Button("Select All") {
                                    viewModel.availableWorkouts.forEach { workout in
                                        selection.insert(workout)
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        .task {
            await shoeViewModel?.loadAvailableWorkouts()
        }
    }
}
