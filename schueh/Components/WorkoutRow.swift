import SwiftUI

struct WorkoutRow: View {
    let workout: WorkoutRecord

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(workout.date, style: .date)
                .font(.headline)

            HStack {
                Label(
                    "\(workout.distanceKm, specifier: "%.2f") km",
                    systemImage: "figure.run"
                )
                Spacer()
                Label(
                    formatDuration(workout.duration),
                    systemImage: "clock"
                )
            }
            .font(.caption)
            .foregroundStyle(.secondary)
        }
        .padding(.vertical, 2)
    }

    private func formatDuration(_ duration: TimeInterval) -> String {
        let hours = Int(duration) / 3600
        let minutes = (Int(duration) % 3600) / 60

        if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else {
            return "\(minutes)m"
        }
    }
}
