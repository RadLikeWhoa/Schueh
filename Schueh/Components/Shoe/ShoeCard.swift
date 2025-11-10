import SwiftUI

struct ShoeCard: View {
    let shoe: Shoe
    
    @AppStorage("unitPreference") private var unitPreferenceRaw: String =
    UnitOption.system.rawValue
    
    private var unitPreference: UnitOption {
        UnitOption(rawValue: unitPreferenceRaw) ?? .system
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(shoe.name)
                .font(.headline)
            
            if let color = shoe.color {
                Text(color)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
            
            HStack {
                Text(
                    unitPreference.formatDistance(
                        shoe.totalKilometers,
                        fractionDigits: 2
                    )
                )
                
                if !shoe.isArchived {
                    if let daysRemaining = shoe.daysRemaining {
                        Text("•")
                        
                        Text("^[\(daysRemaining) day](inflect: true) remaining")
                    }
                }
            }
            .font(.subheadline)
            .foregroundStyle(.secondary)
            
            ShoeProgress(shoe: shoe)
                .padding(.top, 4)
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    List {
        ShoeCard(shoe: Shoe(
            name: "Test",
            targetDistance: 500,
            color: "White",
            purchased: .now
        ))
    }
}
