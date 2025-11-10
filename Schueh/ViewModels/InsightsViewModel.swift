import Foundation
import Combine

@MainActor
final class InsightsViewModel: ObservableObject {
    @Published var shoe: Shoe

    init(shoe: Shoe) {
        self.shoe = shoe
    }

    var workoutsByDate: [Date: [WorkoutRecord]] {
        Dictionary(
            grouping: shoe.workouts,
            by: { Calendar.current.startOfDay(for: $0.date) }
        )
    }

    var sortedWorkouts: [WorkoutRecord] {
        shoe.workouts.sorted { $0.date < $1.date }
    }

    var purchaseDate: Date {
        Calendar.current.startOfDay(for: shoe.purchased)
    }

    var endDate: Date {
        Calendar.current.startOfDay(for: shoe.archived ?? Date())
    }

    var cumulativeMileage: [(date: Date, total: Double)] {
        var total: Double = 0
        var result: [(Date, Double)] = []

        for workout in sortedWorkouts {
            total += max(0, workout.distanceKm)
            
            result.append(
                (Calendar.current.startOfDay(for: workout.date), total)
            )
        }

        if let first = result.first, first.0 > purchaseDate {
            result.insert((date: purchaseDate, total: 0), at: 0)
        }

        if let last = result.last, last.0 < endDate {
            result.append((date: endDate, total: total))
        }

        return result
    }

    private struct Week: Hashable {
        var year: Int
        var weekOfYear: Int
    }

    var mileagePerWeek: [(week: Date, total: Double)] {
        let calendar = Calendar.current

        guard
            let weekStart = calendar.dateInterval(
                of: .weekOfYear,
                for: purchaseDate
            )?.start
        else {
            return []
        }

        let numberOfWeeks =
            calendar.dateComponents([.weekOfYear], from: weekStart, to: endDate)
            .weekOfYear ?? 0

        var byWeek: [Week: Double] = [:]

        for workout in shoe.workouts {
            let comps = calendar.dateComponents(
                [.yearForWeekOfYear, .weekOfYear],
                from: workout.date
            )

            let week = Week(
                year: comps.yearForWeekOfYear ?? 0,
                weekOfYear: comps.weekOfYear ?? 0
            )

            byWeek[week, default: 0] += workout.distanceKm
        }

        var result: [(week: Date, total: Double)] = []

        for weekOffset in 0...numberOfWeeks {
            guard
                let currentWeekStart = calendar.date(
                    byAdding: .weekOfYear,
                    value: weekOffset,
                    to: weekStart
                )
            else {
                continue
            }

            let comps = calendar.dateComponents(
                [.yearForWeekOfYear, .weekOfYear],
                from: currentWeekStart
            )

            let week = Week(
                year: comps.yearForWeekOfYear ?? 0,
                weekOfYear: comps.weekOfYear ?? 0
            )

            let total = byWeek[week] ?? 0.0

            result.append((week: currentWeekStart, total: total))
        }

        return result
    }

    var workoutDates: Set<Date> {
        Set(shoe.workouts.map { $0.date })
    }
}

