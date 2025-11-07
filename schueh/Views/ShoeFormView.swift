import SwiftData
import SwiftUI

struct ShoeFormView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var name = ""
    @State private var color = ""
    @State private var targetDistance: Int?
    @State private var purchased: Date?

    var existingShoe: Shoe?

    private let formatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter
    }()

    var body: some View {
        NavigationStack {
            Form {
                Section("Details") {
                    TextField("Name", text: $name)
                    TextField("Color", text: $color)
                    DatePicker(
                        "Purchased",
                        selection: Binding<Date>(
                            get: { self.purchased ?? Date() },
                            set: { self.purchased = $0 }
                        ),
                        in: Date.distantPast...Date(),
                        displayedComponents: [.date]
                    )
                }
                Section("Target Distance") {
                    TextField(
                        "Distance",
                        value: $targetDistance,
                        formatter: self.formatter
                    ).keyboardType(.numberPad)
                }
            }
            .navigationTitle(existingShoe == nil ? "Add Shoe" : "Edit Shoe")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", systemImage: "xmark") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save", systemImage: "checkmark") {
                        saveShoe()
                    }
                    .disabled(name.isEmpty || targetDistance == nil)
                }
            }
            .onAppear {
                if let shoe = existingShoe {
                    name = shoe.name
                    color = shoe.color ?? ""
                    targetDistance = shoe.targetDistance
                    purchased = shoe.purchased
                }
            }
        }
    }

    private func saveShoe() {
        if let existingShoe = existingShoe {
            existingShoe.name = name
            existingShoe.targetDistance = targetDistance ?? 0
            existingShoe.color = color.isEmpty ? nil : color
            existingShoe.purchased = purchased
        } else {
            let shoe = Shoe(
                name: name,
                targetDistance: targetDistance ?? 0,
                archived: false,
                color: color.isEmpty ? nil : color,
                purchased: purchased
            )
            modelContext.insert(shoe)
        }

        try? modelContext.save()
        dismiss()
    }
}
