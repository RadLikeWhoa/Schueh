import HealthKit
import SwiftUI
import SwiftData

struct WorkoutPickerView: View {
    @Environment(\.dismiss) private var dismiss

    let shoe: Shoe

    @State private var selection = Set<HKWorkout>()
    @State private var viewModel: WorkoutPickerViewModel

    init(shoe: Shoe, modelContext: ModelContext) {
        self.shoe = shoe
        
        _viewModel = State(
            initialValue: WorkoutPickerViewModel(
                shoe: shoe,
                repository: ShoeRepository(modelContext: modelContext),
                healthKitManager: HealthKitManager()
            )
        )
    }

    var body: some View {
        NavigationStack {
            Group {
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
                    ) { workout in
                        WorkoutPickerRow(workout: workout)
                    }
                    .environment(\.editMode, .constant(EditMode.active))
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
                            viewModel.assignWorkout(workout)
                        }
                        dismiss()
                    }
                    .disabled(selection.isEmpty)
                }

                if !viewModel.availableWorkouts.isEmpty {
                    ToolbarItem(placement: .bottomBar) {
                        if viewModel.availableWorkouts.count == selection.count {
                            Button("Deselect All") {
                                selection.removeAll()
                            }
                        } else {
                            Button("Select All") {
                                viewModel.availableWorkouts.forEach {
                                    workout in
                                    selection.insert(workout)
                                }
                            }
                        }
                    }
                }
            }
        }
        .task {
            await viewModel.loadAvailableWorkouts()
        }
    }
}
