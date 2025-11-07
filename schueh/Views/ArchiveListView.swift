import SwiftData
import SwiftUI

struct ArchiveListView: View {
    @Environment(\.modelContext) private var modelContext

    @Query(
        filter: #Predicate<Shoe> { $0.archived },
        sort: [SortDescriptor(\Shoe.created, order: .reverse)]
    )
    private var shoes: [Shoe]

    @AppStorage("sortOption") private var storedSortOption: String =
        ArchiveSortOption.age.rawValue

    @State private var sortOption: ArchiveSortOption = .age
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
            result.sort { shoe1, shoe2 in
                guard let date1 = shoe1.purchased else { return false }
                guard let date2 = shoe2.purchased else { return true }
                return date1 < date2
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
            if sortedShoes.isEmpty {
                ContentUnavailableView(
                    "No Shoes",
                    systemImage: "shoe.fill",
                    description: Text("You do not have any archived shoes.")
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
                    }
                }
                .searchable(
                    text: $searchQuery,
                    placement: .automatic,
                    prompt: "Search shoes"
                )
                .textInputAutocapitalization(.never)
                .contentMargins(.top, 16)
            }
        }
        .navigationTitle("Archive")
        .toolbar {
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
                        ForEach(ArchiveSortOption.allCases) { option in
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
        .onChange(of: searchQuery) {
            searchResults = shoes.filter { shoe in
                shoe.name.lowercased().contains(searchQuery.lowercased())
            }
        }
        .onAppear {
            sortOption = ArchiveSortOption(rawValue: storedSortOption) ?? .age
        }
    }
}
