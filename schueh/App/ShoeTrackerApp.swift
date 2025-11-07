import SwiftData
import SwiftUI

@main
struct ShoeTrackerApp: App {
    @AppStorage("appearance") private var appearance: Int = 0

    var appearanceSwitch: ColorScheme? {
        switch appearance {
        case 1:
            return .light
        case 2:
            return .dark
        default:
            return .none
        }
    }

    var body: some Scene {
        WindowGroup {
            NavigationStack {
                ShoeListView()
                    .navigationBarTitleDisplayMode(.inline)
            }
            .preferredColorScheme(appearanceSwitch)
        }
        .modelContainer(for: [Shoe.self, WorkoutRecord.self])
    }
}
