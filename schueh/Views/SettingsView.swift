import SwiftData
import SwiftUI

struct SettingsView: View {
    @AppStorage("appearance") private var appearanceSelection: Int = 0

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
        }
        .contentMargins(.top, 16)
        .navigationTitle("Settings")
    }
}
