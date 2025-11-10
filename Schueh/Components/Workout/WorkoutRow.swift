import SwiftUI

struct WorkoutRow: View {
    let workout: WorkoutRecord

    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }()

    private var unitPreference: UnitOption { .current }

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(unitPreference.formatDistance(workout.distanceKm))
                .font(.body)

            Text(dateFormatter.string(from: workout.date))
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }
}

#Preview {
    List {
        WorkoutRow(
            workout: WorkoutRecord(
                healthKitId: UUID(),
                date: .now,
                distanceKm: 8.75,
                duration: 100
            )
        )
    }
}
