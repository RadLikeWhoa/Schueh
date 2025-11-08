import SwiftUI

struct WorkoutRow: View {
    let workout: WorkoutRecord
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }()

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("\(workout.distanceKm, specifier: "%.2f") km")
                .font(.headline)
            
            Text(dateFormatter.string(from: workout.date))
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }
}
