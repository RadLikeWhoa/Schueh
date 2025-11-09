import SwiftData
import SwiftUI

struct SettingsView: View {
    @AppStorage("appearance") private var appearanceSelection: Int = 0

    @AppStorage("timeRange") private var timeRangeSelection: String =
        TimeRangeOption.days30.rawValue

    var body: some View {
        Form {
            Picker(selection: $appearanceSelection) {
                Text("System")
                    .tag(0)
                Text("Light")
                    .tag(1)
                Text("Dark")
                    .tag(2)
            } label: {
                Text("Appearance")
            }
            .pickerStyle(.menu)

            Picker(selection: $timeRangeSelection) {
                ForEach(TimeRangeOption.allCases) { option in
                    Text(option.rawValue)
                        .tag(option)
                }
            } label: {
                Text("Limit Workouts")
            }
            .pickerStyle(.menu)
        }
        .contentMargins(.top, 16)
        .navigationTitle("Settings")
    }
}
