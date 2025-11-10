import SwiftUI

struct ShoeProgress: View {
    var shoe: Shoe
    
    var color: Color {
        if shoe.isArchived {
            return .gray
        }
        
        if shoe.hasExpired {
            return .red
        }
        
        if shoe.closeToExpiration {
            return .yellow
        }
        
        return .green
    }

    private let capsule = Capsule()

    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            ZStack(alignment: .center) {
                capsule
                    .fill(.foreground.quaternary)
                    .overlay(alignment: .leading) {
                        GeometryReader { proxy in
                            capsule
                                .fill(color)
                                .frame(width: proxy.size.width * (shoe.progress / 100), height: 12)
                            
                        }
                    }
                    .frame(height: 12)
                    .clipShape(capsule)
                
                if shoe.isArchived || shoe.hasExpired || shoe.closeToExpiration {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(.background)
                        .frame(width: 32, height: 16)
                    
                    Image(systemName: shoe.isArchived ? "archivebox.fill" : "exclamationmark.triangle.fill")
                        .font(.system(size: 16))
                        .foregroundStyle(color)
                }
            }
            .frame(height: 16)
            
            Text("\(shoe.progress, specifier: "%.0f")%")
                .font(.subheadline)
                .foregroundStyle(color)
                .bold()
        }
        .alignmentGuide(.listRowSeparatorLeading) {
            $0[.leading]
        }
    }
}

#Preview {
    List {
        ShoeProgress(shoe: Shoe(
            name: "Test",
            targetDistance: 500,
            color: "White",
            purchased: .now
        ))
    }
}
