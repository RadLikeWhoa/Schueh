import Foundation
import HealthKit
import SwiftData

@MainActor
@Observable
class ShoeDetailViewModel {
    private let repository: ShoeRepository

    let shoe: Shoe
    var errorMessage: String?

    init(
        shoe: Shoe,
        repository: ShoeRepository
    ) {
        self.shoe = shoe
        self.repository = repository
    }

    func toggleArchive() {
        do {
            try repository.toggleArchive(shoe)
        } catch {
            errorMessage =
                "Failed to archive shoe: \(error.localizedDescription)"
        }
    }
}
