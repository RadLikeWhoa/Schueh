import SwiftData
import SwiftUI

struct ShoeDetailView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) private var modelContext

    let shoe: Shoe

    @State private var viewModel: ShoeDetailViewModel?
    @State private var showingWorkoutPicker = false
    @State private var showingEditSheet = false
    @State private var showingDeleteAlert = false

    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter
    }()

    var body: some View {
        List {
            Section("Progress") {
                LabeledContent("Total Distance") {
                    Text("\(shoe.totalKilometers, specifier: "%.2f") km")
                }

                LabeledContent("Target Distance") {
                    Text("\(shoe.targetDistance) km")
                }

                if shoe.remainder > 0 {
                    LabeledContent("Remaining") {
                        Text(
                            "\(shoe.remainder, specifier: "%.2f") km • \(100 - shoe.progress, specifier: "%.2f")%"
                        )
                    }
                }

                if let daysRemaining = shoe.daysRemaining {
                    LabeledContent("Days Remaining") {
                        Text(
                            "^[\(daysRemaining) day](inflect: true)"
                        )
                    }
                }

                ShoeProgress(shoe: shoe)
            }

            Section("Statistics") {
                LabeledContent("Runs", value: "\(shoe.numberOfRuns)")

                if shoe.numberOfRuns > 0 {
                    LabeledContent("Avg. per Run") {
                        Text("\(shoe.averageKmPerRun, specifier: "%.2f") km")
                    }

                    LabeledContent("Avg. per Week") {
                        Text("\(shoe.averageKmPerWeek, specifier: "%.2f") km")
                    }

                    if let maximumDistance = shoe.maximumDistance {
                        LabeledContent("Longest Run") {
                            Text("\(maximumDistance, specifier: "%.2f") km")
                        }
                    }

                    if let totalElevationGain = shoe.totalElevationGain {
                        LabeledContent("Total Elevation Gain") {
                            Text("\(totalElevationGain, specifier: "%.2f") m")
                        }
                    }
                }
            }

            if shoe.color != nil || shoe.purchased != nil || shoe.age != nil {
                Section("Details") {
                    if let color = shoe.color {
                        LabeledContent("Color", value: color)
                    }

                    if let purchased = shoe.purchased {
                        LabeledContent("Purchased") {
                            Text("\(dateFormatter.string(from: purchased))")
                        }
                    }

                    if let age = shoe.age {
                        LabeledContent("Age") {
                            Text("^[\(age) day](inflect: true)")
                        }
                    }
                }
            }

            Section {
                Button {
                    showingWorkoutPicker = true
                } label: {
                    Label("Assign Workouts", systemImage: "plus.circle.fill")
                }
            }

            if !shoe.workouts.isEmpty {
                Section("Assigned Workouts") {
                    ForEach(shoe.workouts.sorted(by: { $0.date > $1.date })) { workout in
                        WorkoutRow(workout: workout)
                    }
                }
            }
        }
        .navigationTitle(shoe.name)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Edit") {
                    showingEditSheet = true
                }
            }
            
            ToolbarSpacer(placement: .topBarTrailing)
            
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    Button {
                        viewModel?.toggleArchive()
                    } label: {
                        Label(
                            shoe.archived ? "Unarchive Shoe" : "Archive Shoe",
                            systemImage: "archivebox.fill"
                        )
                    }

                    Button(role: .destructive) {
                        showingDeleteAlert = true
                    } label: {
                        Label("Delete", systemImage: "xmark")
                    }
                } label: {
                    Label("More", systemImage: "ellipsis")
                }
            }
        }
        .sheet(isPresented: $showingWorkoutPicker) {
            WorkoutPickerView(viewModel: viewModel)
        }
        .sheet(isPresented: $showingEditSheet) {
            ShoeFormView(existingShoe: shoe)
        }
        .alert("Delete Shoe", isPresented: $showingDeleteAlert) {
            Button("Cancel", role: .cancel) {}
            Button("Delete", role: .destructive) {
                if let viewModel = viewModel {
                    viewModel.deleteShoe()
                    dismiss()
                }
            }
        } message: {
            Text(
                "Are you sure you want to delete this shoe? This will also unassign all workouts from this shoe."
            )
        }
        .onAppear {
            if viewModel == nil {
                let repository = ShoeRepository(modelContext: modelContext)
                let healthKit = HealthKitManager()

                viewModel = ShoeDetailViewModel(
                    shoe: shoe,
                    repository: repository,
                    healthKitManager: healthKit
                )
            }
        }
    }
}
