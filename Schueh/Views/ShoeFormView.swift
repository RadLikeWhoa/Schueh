import SwiftData
import SwiftUI

struct ShoeFormView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var name = ""
    @State private var color = ""
    @State private var targetDistance: Int?
    @State private var purchased = Date()
    @State private var archived: Date?
    @State private var showingDeleteAlert = false

    var existingShoe: Shoe?
    var onDelete: (() -> Void)?

    private let formatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter
    }()

    @AppStorage("unitPreference") private var unitPreferenceRaw: String =
        UnitOption.system.rawValue

    private var unitPreference: UnitOption {
        UnitOption(rawValue: unitPreferenceRaw) ?? .system
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Details") {
                    TextField("Name", text: $name)

                    TextField("Color", text: $color)

                    DatePicker(
                        "Purchased",
                        selection: $purchased,
                        in: Date.distantPast...Date(),
                        displayedComponents: [.date]
                    )

                    if archived != nil {
                        DatePicker(
                            "Archived",
                            selection: Binding<Date>(
                                get: { self.archived ?? Date() },
                                set: { self.archived = $0 }
                            ),
                            in: purchased...Date(),
                            displayedComponents: [.date]
                        )
                    }
                }

                Section("Target Mileage") {
                    HStack(spacing: 16) {
                        TextField(
                            "Distance",
                            value: $targetDistance,
                            formatter: self.formatter
                        )
                        .keyboardType(.numberPad)
                        .alignmentGuide(.listRowSeparatorLeading) {
                            $0[.leading]
                        }

                        Text(unitPreference.distanceUnit)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }

                    Text(
                        "Enter your target mileage for this shoe. As a rule of thumb, most running shoes aim for around 500 - 800 km."
                    )
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
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
                    .disabled(
                        name.isEmpty || targetDistance == nil
                            || targetDistance! <= 0
                    )
                }

                if existingShoe != nil {
                    ToolbarItem(placement: .bottomBar) {
                        Button("Delete Shoe", role: .destructive) {
                            showingDeleteAlert = true
                        }
                        .foregroundStyle(.red)
                    }
                }
            }
            .alert("Delete Shoe", isPresented: $showingDeleteAlert) {
                Button("Cancel", role: .cancel) {}

                Button("Delete", role: .destructive) {
                    do {
                        try delete()
                        dismiss()
                        onDelete?()
                    } catch {}
                }
            } message: {
                Text(
                    "Are you sure you want to delete this shoe? This will also unassign all workouts from this shoe."
                )
            }
            .onAppear {
                if let shoe = existingShoe {
                    name = shoe.name
                    color = shoe.color ?? ""

                    targetDistance = Int(
                        unitPreference.convertDistanceToKilometers(
                            distance: Double(shoe.targetDistance)
                        )
                    )

                    purchased = shoe.purchased
                    archived = shoe.archived
                }
            }
        }
    }

    private func delete() throws {
        guard let shoe = existingShoe else { return }

        modelContext.delete(shoe)
        try modelContext.save()
    }

    private func saveShoe() {
        if let existingShoe = existingShoe {
            existingShoe.name = name

            existingShoe.targetDistance = Int(
                unitPreference.convertDistanceToKilometers(
                    distance: Double(targetDistance ?? 0)
                )
            )

            existingShoe.color = color.isEmpty ? nil : color
            existingShoe.purchased = purchased
            existingShoe.archived = archived
        } else {
            let shoe = Shoe(
                name: name,
                targetDistance: Int(
                    unitPreference.convertDistanceToKilometers(
                        distance: Double(targetDistance ?? 0)
                    )
                ),
                archived: nil,
                color: color.isEmpty ? nil : color,
                purchased: purchased
            )
            modelContext.insert(shoe)
        }

        try? modelContext.save()
        dismiss()
    }
}
