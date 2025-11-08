import SwiftData
import SwiftUI

struct WorkoutsView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.editMode) private var editMode

    var shoe: Shoe

    var body: some View {
        NavigationStack {
            List {
                ForEach(
                    shoe.workouts.sorted(by: { $0.date > $1.date }),
                    id: \.self
                ) { workout in
                    WorkoutRow(workout: workout)
                }
                .onDelete(perform: deleteWorkout)
            }
            .contentMargins(.top, 16)
            .navigationTitle("Workouts")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(editMode?.wrappedValue.isEditing == true)
            .toolbar {
                EditButton()
            }
        }
    }

    private func deleteWorkout(at offsets: IndexSet) {
        let sortedWorkouts = shoe.workouts.sorted(by: { $0.date > $1.date })
        
        for index in offsets {
            modelContext.delete(sortedWorkouts[index])
        }
        
        try? modelContext.save()
    }
}
