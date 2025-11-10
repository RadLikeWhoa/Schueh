import HealthKit
import SwiftUI

struct WorkoutPickerRow: View {
    let workout: HKWorkout

    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }()

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            if let distance = workout.totalDistance {
                Text(
                    "\(distance.doubleValue(for: .meterUnit(with: .kilo)), specifier: "%.2f") km"
                )
                .font(.body)
            }

            Text(dateFormatter.string(from: workout.startDate))
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }
}
