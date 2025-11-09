import SwiftData
import SwiftUI

struct ShoeDetailView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) private var modelContext

    let shoe: Shoe

    @State private var viewModel: ShoeDetailViewModel

    enum ActiveSheet: Identifiable {
        case workoutPicker, editSheet

        var id: Int {
            switch self {
            case .workoutPicker:
                return 0

            case .editSheet:
                return 1
            }
        }
    }

    @State private var activeSheet: ActiveSheet?

    private var recentWorkouts: ArraySlice<WorkoutRecord> {
        shoe.workouts.sorted(by: { $0.date > $1.date }).prefix(
            3
        )
    }

    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter
    }()

    init(shoe: Shoe, modelContext: ModelContext) {
        self.shoe = shoe

        _viewModel = State(
            initialValue: ShoeDetailViewModel(
                shoe: shoe,
                repository: ShoeRepository(modelContext: modelContext)
            )
        )
    }

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
                    if let archived = shoe.archived {
                        HStack(spacing: 16) {
                            Image(systemName: "archivebox.fill")
                                .foregroundStyle(.gray)

                            Text(
                                "This shoe was archived on \(dateFormatter.string(from: archived))."
                            )
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        }
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

            if shoe.numberOfRuns > 0 {
                Section("Statistics") {
                    LabeledContent("Runs", value: "\(shoe.numberOfRuns)")

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

                    NavigationLink(destination: InsightsView(shoe: shoe)) {
                        Text("View More Insights")
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

            if !shoe.workouts.isEmpty {
                Section("Workouts") {
                    ForEach(recentWorkouts) { workout in
                        WorkoutRow(workout: workout)
                    }

                    if shoe.workouts.count > recentWorkouts.count {
                        NavigationLink(
                            destination:
                                WorkoutsView(shoe: shoe)
                        ) {
                            Text("Show All Workouts")
                        }
                    }
                }
            }
        }
        .contentMargins(.top, 16)
        .navigationTitle(shoe.name)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    viewModel.toggleArchive()
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
                    activeSheet = .editSheet
                }
            }

            if !shoe.isArchived {
                ToolbarItem(placement: .bottomBar) {
                    Button("Assign Workouts") {
                        activeSheet = .workoutPicker
                    }
                }
            }
        }
        .sheet(item: $activeSheet) { item in
            switch item {
            case .workoutPicker:
                WorkoutPickerView(shoe: shoe, modelContext: modelContext)

            case .editSheet:
                ShoeFormView(existingShoe: shoe) {
                    dismiss()
                }
            }
        }
    }
}
