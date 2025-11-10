import SwiftData
import SwiftUI

struct ShoeDetailView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) private var modelContext

    let shoe: Shoe

    enum ActiveSheet: Identifiable {
        case workoutPicker, editSheet

        var id: Int {
            switch self {
            case .workoutPicker: return 0
            case .editSheet: return 1
            }
        }
    }

    @State private var activeSheet: ActiveSheet?

    private var recentWorkouts: ArraySlice<WorkoutRecord> {
        shoe.workouts.sorted(by: { $0.date > $1.date }).prefix(3)
    }

    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter
    }()

    @AppStorage("unitPreference") private var unitPreferenceRaw: String =
        UnitOption.system.rawValue

    private var unitPreference: UnitOption {
        UnitOption(rawValue: unitPreferenceRaw) ?? .system
    }
    
    init(shoe: Shoe) {
        self.shoe = shoe
    }

    private var formattedDuration: LocalizedStringKey {
        var seconds = Int(shoe.totalDuration)

        let days = seconds / (24 * 3600)
        seconds %= 24 * 3600

        let hours = seconds / 3600
        seconds %= 3600

        let minutes = seconds / 60
        seconds %= 60
        
        if days > 0 {
            if hours > 0 {
                return "^[\(days) day](inflect: true) ^[\(hours) hour](inflect: true)"
            }
            
            return "^[\(days) day](inflect: true)"
        }
        
        if hours > 0 {
            if minutes > 0 {
                return "^[\(hours) hour](inflect: true) ^[\(minutes) minute](inflect: true)"
            }
            
            return "^[\(hours) hour](inflect: true)"
        }
        
        return "^[\(minutes) minute](inflect: true)"
    }

    var body: some View {
        List {
            Section {
                LabeledContent("Target Distance") {
                    Text(
                        unitPreference.formatDistance(
                            Double(shoe.targetDistance),
                            fractionDigits: 0
                        )
                    )
                }
                
                LabeledContent("Total Distance") {
                    Text(unitPreference.formatDistance(shoe.totalKilometers))
                }

                if !shoe.isArchived {
                    if shoe.remainder > 0 {
                        LabeledContent("Distance Remaining") {
                            Text(
                                "\(unitPreference.formatDistance(shoe.remainder))"
                            )
                        }
                    }

                    if let daysRemaining = shoe.daysRemaining, daysRemaining > 0 {
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

                    if shoe.closeToExpiration && !shoe.hasExpired {
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
                    
                    LabeledContent("Time in Shoe") {
                        Text(formattedDuration)
                    }

                    if let averageKmPerRun = shoe.averageKmPerRun {
                        LabeledContent("Avg. Distance per Run") {
                            Text(
                                unitPreference.formatDistance(averageKmPerRun)
                            )
                        }
                    }

                    if let averageKmPerWeek = shoe.averageKmPerWeek {
                        LabeledContent("Avg. Distance per Week") {
                            Text(
                                unitPreference.formatDistance(averageKmPerWeek)
                            )
                        }
                    }

                    if let maximumDistance = shoe.maximumDistance {
                        LabeledContent("Longest Run") {
                            Text(unitPreference.formatDistance(maximumDistance))
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
                            destination: WorkoutsView(shoe: shoe)
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
                    toggleArchive()
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
    
    private func toggleArchive() {
        let repository = ShoeRepository(modelContext: modelContext)
        try? repository.toggleArchive(shoe)
    }
}

