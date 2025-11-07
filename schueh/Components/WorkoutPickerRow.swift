import HealthKit
import SwiftUI

struct WorkoutPickerRow: View {
    let workout: HKWorkout
    let isAssigned: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(workout.startDate, style: .date)
                        .font(.headline)

                    HStack {
                        if let distance = workout.totalDistance {
                            Label(
                                "\(distance.doubleValue(for: .meterUnit(with: .kilo)), specifier: "%.2f") km",
                                systemImage: "figure.run"
                            )
                        }

                        Spacer()

                        Label(
                            formatDuration(workout.duration),
                            systemImage: "clock"
                        )
                    }
                    .font(.caption)
                    .foregroundStyle(.secondary)
                }

                Spacer()

                if isAssigned {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(.green)
                }
            }
        }
        .disabled(isAssigned)
        .opacity(isAssigned ? 0.5 : 1.0)
    }

    private func formatDuration(_ duration: TimeInterval) -> String {
        let hours = Int(duration) / 3600
        let minutes = (Int(duration) % 3600) / 60
        let seconds = Int(duration) % 60

        if hours > 0 {
            return String(format: "%d:%02d:%02d", hours, minutes, seconds)
        } else {
            return String(format: "%d:%02d", minutes, seconds)
        }
    }
}
