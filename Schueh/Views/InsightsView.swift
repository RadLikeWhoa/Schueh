import Charts
import SwiftUI

struct InsightsView: View {
    @StateObject private var viewModel: InsightsViewModel

    @State private var currentMonth = Date()

    @AppStorage("unitPreference") private var unitPreferenceRaw: String =
        UnitOption.system.rawValue

    @AppStorage("showTargetLine") private var showTargetLine: Bool = true

    private var unitPreference: UnitOption {
        UnitOption(rawValue: unitPreferenceRaw) ?? .system
    }

    init(shoe: Shoe) {
        _viewModel = StateObject(wrappedValue: InsightsViewModel(shoe: shoe))
    }

    var body: some View {
        List {
            Section("Total Distance") {
                Chart {
                    ForEach(viewModel.cumulativeMileage, id: \.date) { point in
                        LineMark(
                            x: .value("Date", point.date),
                            y: .value(
                                "Cumulative \(unitPreference.distanceUnit)",
                                unitPreference.convertDistance(
                                    kilometers: point.total
                                )
                            )
                        )
                        .symbol {
                            Circle()
                                .fill(.tint)
                                .frame(height: 5)
                        }

                        if showTargetLine {
                            RuleMark(
                                y: .value(
                                    "Target",
                                    Int(
                                        unitPreference.convertDistance(
                                            kilometers: Double(
                                                viewModel.shoe.targetDistance
                                            )
                                        )
                                    )
                                )
                            )
                            .foregroundStyle(.gray)
                            .lineStyle(StrokeStyle(lineWidth: 2, dash: [5, 5]))
                            .annotation(position: .top, alignment: .trailing) {
                                Text(
                                    "Target: \(unitPreference.formatDistance(Double(viewModel.shoe.targetDistance), fractionDigits: 0))"
                                )
                                .font(.caption)
                                .foregroundColor(.gray)
                            }
                        }
                    }
                }
                .frame(height: 180)

                LabeledContent("Total Distance") {
                    Text(
                        unitPreference.formatDistance(
                            viewModel.shoe.totalKilometers
                        )
                    )
                }

                Toggle("Show Target", isOn: $showTargetLine)
            }

            Section("Distance per Week") {
                Chart {
                    ForEach(viewModel.mileagePerWeek, id: \.week) { entry in
                        LineMark(
                            x: .value("Week", entry.week),
                            y: .value(
                                unitPreference.distanceUnit,
                                unitPreference.convertDistance(
                                    kilometers: entry.total
                                )
                            )
                        )
                        .symbol {
                            Circle()
                                .fill(.tint)
                                .frame(height: 5)
                        }
                    }
                }
                .frame(height: 180)

                if let averageKmPerWeek = viewModel.shoe.averageKmPerWeek {
                    LabeledContent("Avg. per Week") {
                        Text(
                            unitPreference.formatDistance(averageKmPerWeek)
                        )
                    }
                }
            }

            Section("Workouts") {
                CalendarView(
                    month: currentMonth,
                    highlightedDates: viewModel.workoutDates
                )
            }
        }
        .navigationTitle("Insights")
    }
}
