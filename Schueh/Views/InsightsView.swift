import Charts
import SwiftUI

struct InsightsView: View {
    @StateObject private var viewModel: InsightsViewModel

    @State private var currentMonth = Date()

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
                            y: .value("Cumulative Km", point.total)
                        )
                        .symbol {
                            Circle()
                                .fill(.tint)
                                .frame(height: 5)
                        }
                        
                        RuleMark(y: .value("Target", viewModel.shoe.targetDistance))
                            .foregroundStyle(.gray)
                            .lineStyle(StrokeStyle(lineWidth: 2, dash: [5, 5]))
                            .annotation(position: .top, alignment: .trailing) {
                                Text("Target: \(viewModel.shoe.targetDistance) km")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                    }
                }
                .frame(height: 180)
                
                LabeledContent("Total Distance") {
                    Text("\(viewModel.shoe.totalKilometers, specifier: "%.2f") km")
                }
            }

            Section("Distance per Week") {
                Chart {
                    ForEach(viewModel.mileagePerWeek, id: \.week) { entry in
                        LineMark(
                            x: .value("Week", entry.week),
                            y: .value("Km", entry.total)
                        )
                        .symbol {
                            Circle()
                                .fill(.tint)
                                .frame(height: 5)
                        }
                    }
                }
                .frame(height: 180)
                
                LabeledContent("Avg. per Week") {
                    Text("\(viewModel.shoe.averageKmPerWeek, specifier: "%.2f") km")
                }
            }
            
            if let totalElevationGain = viewModel.shoe.totalElevationGain {
                Section("Total Elevation Gain") {
                    Chart {
                        ForEach(viewModel.cumulativeElevationGain, id: \.date) { point in
                            LineMark(
                                x: .value("Date", point.date),
                                y: .value("Cumulative Elevation Gain", point.total)
                            )
                            .symbol {
                                Circle()
                                    .fill(.tint)
                                    .frame(height: 5)
                            }
                        }
                    }
                    .frame(height: 180)
                    
                    LabeledContent("Total Elevaion Gain") {
                        Text("\(totalElevationGain, specifier: "%.2f") m")
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
