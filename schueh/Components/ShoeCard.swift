import SwiftUI

struct ShoeCard: View {
    let shoe: Shoe

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(shoe.name)
                .font(.headline)
            
            if let color = shoe.color {
                Text(color)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            HStack {
                Text(
                    "\(shoe.totalKilometers, specifier: "%.1f") km"
                )
                
                Text("•")
                
                Text(
                    "\(shoe.progress, specifier: "%.1f")%"
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
