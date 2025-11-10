import SwiftData
import SwiftUI

struct ShoeListView: View {
    @Environment(\.modelContext) private var modelContext

    @Query(
        filter: #Predicate<Shoe> { $0.archived == nil },
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
    @State private var searchResults: [Shoe] = []
    @State private var searchQuery = ""

    var isSearching: Bool {
        return !searchQuery.isEmpty
    }

    private var sortedShoes: [Shoe] {
        var result = shoes

        switch sortOption {
        case .age:
            result.sort { $0.purchased < $1.purchased }

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
                    if isSearching {
                        ForEach(searchResults) { shoe in
                            NavigationLink(
                                destination:
                                    ShoeDetailView(shoe: shoe)
                            ) {
                                ShoeCard(shoe: shoe)
                            }
                        }
                    } else {
                        ForEach(sortedShoes) { shoe in
                            NavigationLink(
                                destination:
                                    ShoeDetailView(shoe: shoe)
                            ) {
                                ShoeCard(shoe: shoe)
                            }
                        }

                        if allShoes.count > sortedShoes.count {
                            NavigationLink(
                                destination: ArchiveListView()
                            ) {
                                Text("Archived Shoes")
                            }
                        }
                    }
                }
                .searchable(
                    text: $searchQuery,
                    placement: .automatic,
                    prompt: "Search"
                )
                .textInputAutocapitalization(.never)
                .contentMargins(.top, 16)
            }
        }
        .navigationTitle("Shoes")
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                NavigationLink(destination: SettingsView()) {
                    Label("Settings", systemImage: "gear")
                }
            }

            ToolbarItemGroup(placement: .topBarTrailing) {
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

                Button {
                    showingAddSheet = true
                } label: {
                    Label("Add Shoe", systemImage: "plus")
                }
            }
        }
        .overlay {
            if isSearching && searchResults.isEmpty {
                ContentUnavailableView(
                    "No Shoes Found",
                    systemImage: "shoe.fill",
                    description: Text(
                        "No shoes found for \"\(searchQuery)\"."
                    )
                )
            }
        }
        .sheet(isPresented: $showingAddSheet) {
            ShoeFormView()
        }
        .onChange(of: searchQuery) {
            searchResults = shoes.filter { shoe in
                shoe.name.lowercased().contains(searchQuery.lowercased())
            }
        }
        .onAppear {
            sortOption =
                ShoesSortOption(rawValue: storedSortOption) ?? .daysRemaining
        }
    }
}
