import SwiftData
import SwiftUI

struct ShoeDetailView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) private var modelContext

    let shoe: Shoe

    @State private var viewModel: ShoeDetailViewModel?
    @State private var showingWorkoutPicker = false
    @State private var showingEditSheet = false

    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter
    }()

    var body: some View {
        List {
            Section {
                LabeledContent("Total Distance") {
                    Text("\(shoe.totalKilometers, specifier: "%.2f") km")
                }

                LabeledContent("Target Distance") {
                    Text("\(shoe.targetDistance) km")
                }

                if !shoe.isArchived {
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
                }

                ShoeProgress(shoe: shoe)

                if shoe.isArchived {
                    HStack(spacing: 16) {
                        Image(systemName: "archivebox.fill")
                            .foregroundStyle(.gray)

                        Text("This shoe has been archived.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                } else {
                    if shoe.hasExpired {
                        HStack(spacing: 16) {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundStyle(.red)

                            Text(
                                "This shoe has reached its mileage limit. Consider archiving it or looking for a replacement."
                            )
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        }
                    }

                    if shoe.closeToExpiration {
                        HStack(spacing: 16) {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundStyle(.yellow)

                            Text(
                                "This shoe is about to reach its mileage limit. Consider looking for a replacement."
                            )
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        }
                    }
                }
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

            Section("Details") {
                if let color = shoe.color {
                    LabeledContent("Color", value: color)
                }

                LabeledContent("Purchased") {
                    Text("\(dateFormatter.string(from: shoe.purchased))")
                }

                if let age = shoe.age {
                    LabeledContent("Age") {
                        Text("^[\(age) day](inflect: true)")
                    }
                }
            }

            if !shoe.isArchived {
                Section {
                    Button {
                        showingWorkoutPicker = true
                    } label: {
                        Label(
                            "Assign Workouts",
                            systemImage: "plus.circle.fill"
                        )
                    }
                }
            }

            if !shoe.workouts.isEmpty {
                Section("Assigned Workouts") {
                    ForEach(shoe.workouts.sorted(by: { $0.date > $1.date })) {
                        workout in
                        WorkoutRow(workout: workout)
                    }
                }
            }
        }
        .contentMargins(.top, 16)
        .navigationTitle(shoe.name)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    viewModel?.toggleArchive()
                } label: {
                    Label(
                        shoe.isArchived ? "Unarchive Shoe" : "Archive Shoe",
                        systemImage: shoe.isArchived
                            ? "archivebox.fill" : "archivebox"
                    )
                }
            }

            ToolbarSpacer(placement: .topBarTrailing)

            ToolbarItem(placement: .topBarTrailing) {
                Button("Edit") {
                    showingEditSheet = true
                }
            }
        }
        .sheet(isPresented: $showingWorkoutPicker) {
            WorkoutPickerView(viewModel: viewModel)
        }
        .sheet(isPresented: $showingEditSheet) {
            ShoeFormView(existingShoe: shoe) {
                if let viewModel = viewModel {
                    viewModel.deleteShoe()
                    dismiss()
                }
            }
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
