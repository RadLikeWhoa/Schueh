import SwiftData
import SwiftUI

struct WorkoutsView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.editMode) private var editMode

    var shoe: Shoe

    private var groupedWorkouts: [(key: Date, value: [WorkoutRecord])] {
        let calendar = Calendar.current
        
        let grouped = Dictionary(grouping: shoe.workouts) { workout in
            let components = calendar.dateComponents([.year, .month], from: workout.date)
            return calendar.date(from: components) ?? workout.date
        }
        .mapValues { $0.sorted { $0.date > $1.date } }

        return grouped
            .sorted { $0.key > $1.key }
    }

    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "LLLL yyyy"
        return formatter
    }

    var body: some View {
        NavigationStack {
            List {
                ForEach(groupedWorkouts, id: \.key) { (monthStart, workouts) in
                    Section(header: Text(dateFormatter.string(from: monthStart))) {
                        ForEach(workouts, id: \.self) { workout in
                            WorkoutRow(workout: workout)
                        }
                        .onDelete { offsets in
                            deleteWorkout(at: offsets, in: workouts)
                        }
                    }
                }
            }
            .navigationTitle("Workouts")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(editMode?.wrappedValue.isEditing == true)
            .toolbar {
                EditButton()
            }
        }
    }

    private func deleteWorkout(at offsets: IndexSet, in workoutsInSection: [WorkoutRecord]) {
        for index in offsets {
            modelContext.delete(workoutsInSection[index])
        }
        
        try? modelContext.save()
    }
}
