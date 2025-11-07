import SwiftData
import SwiftUI

struct ShoeListView: View {
    @Environment(\.modelContext) private var modelContext

    @Query(
        filter: #Predicate<Shoe> { !$0.archived },
        sort: [SortDescriptor(\Shoe.created, order: .reverse)]
    )
    private var shoes: [Shoe]
    
    @Query()
    private var allShoes: [Shoe]

    @AppStorage("sortOption") private var storedSortOption: String =
        ShoesSortOption.daysRemaining.rawValue

    @State private var sortOption: ShoesSortOption = .daysRemaining
    @State private var showingAddSheet = false
    @State private var showingSortOptions = false

    private var sortedShoes: [Shoe] {
        var result = shoes

        switch sortOption {
        case .age:
            result.sort { shoe1, shoe2 in
                guard let date1 = shoe1.purchased else { return false }
                guard let date2 = shoe2.purchased else { return true }
                return date1 < date2
            }

        case .recentlyUsed:
            result.sort { shoe1, shoe2 in
                guard let date1 = shoe1.lastWorkoutDate else { return false }
                guard let date2 = shoe2.lastWorkoutDate else { return true }
                return date1 > date2
            }

        case .daysRemaining:
            result.sort { shoe1, shoe2 in
                guard let daysRemaining1 = shoe1.daysRemaining else {
                    return false
                }
                guard let daysRemaining2 = shoe2.daysRemaining else {
                    return true
                }
                return daysRemaining1 < daysRemaining2
            }

        case .name:
            result.sort { $0.name < $1.name }

        case .totalDistance:
            result.sort { $0.totalKilometers > $1.totalKilometers }
        }

        return result
    }

    var body: some View {
        Group {
            if allShoes.isEmpty {
                ContentUnavailableView(
                    "No Shoes",
                    systemImage: "shoe.fill",
                    description: Text(
                        "Add your first running shoe to start tracking mileage"
                    )
                )
            } else {
                List {
                    ForEach(sortedShoes) { shoe in
                        NavigationLink(
                            destination:
                                ShoeDetailView(shoe: shoe)
                        ) {
                            ShoeCard(shoe: shoe)
                        }
                    }

                    NavigationLink(
                        destination: ArchiveListView()
                    ) {
                        Text("Archived Shoes")
                    }
                }
                .contentMargins(.top, 16)
            }
        }
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                NavigationLink(destination: SettingsView()) {
                    Label("Settings", systemImage: "gear")
                }
            }

            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    Picker(
                        "Sort By",
                        selection: Binding(
                            get: { sortOption },
                            set: {
                                sortOption = $0
                                storedSortOption = $0.rawValue
                            }
                        )
                    ) {
                        ForEach(ShoesSortOption.allCases) { option in
                            Label(
                                option.rawValue,
                                systemImage: option.systemImage
                            )
                            .tag(option)
                        }
                    }
                } label: {
                    Label("Sort", systemImage: "arrow.up.arrow.down")
                }
            }

            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showingAddSheet = true
                } label: {
                    Label("Add Shoe", systemImage: "plus")
                }
            }
        }
        .sheet(isPresented: $showingAddSheet) {
            ShoeFormView()
        }
        .onAppear {
            sortOption =
                ShoesSortOption(rawValue: storedSortOption) ?? .daysRemaining
        }
    }
}
