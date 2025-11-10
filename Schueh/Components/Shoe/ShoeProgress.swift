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

    var icon: String {
        if shoe.isArchived {
            return "archivebox.fill"
        }

        if shoe.hasExpired || shoe.closeToExpiration {
            return "exclamationmark.triangle.fill"
        }

        return "checkmark"
    }

    private let capsule = Capsule()
    private let pillHeight = CGFloat(18)
    private let progressHeight = CGFloat(12)
    private let pillWidth = CGFloat(32)

    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            GeometryReader { proxy in
                ZStack(alignment: .center) {
                    capsule
                        .fill(.foreground.quaternary)
                        .overlay(alignment: .leading) {
                            capsule
                                .fill(color)
                                .frame(
                                    width: proxy.size.width * (shoe.progress / 100),
                                    height: progressHeight
                                )
                        }
                        .frame(height: progressHeight)
                        .clipShape(capsule)

                    ZStack(alignment: .center) {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(color)
                            .frame(width: 32, height: pillHeight)

                        Image(systemName: icon)
                            .font(.system(size: 12, weight: .bold))
                            .foregroundStyle(.white)
                    }
                    .position(
                        x: min(
                            max(
                                pillWidth / 2,
                                proxy.size.width * (shoe.progress / 100)
                            ),
                            proxy.size.width - (pillWidth / 2)
                        ),
                        y: pillHeight / 2
                    )
                }
            }
            .frame(height: pillHeight)

            Text("\(shoe.progress, specifier: "%.0f")%")
                .font(.subheadline)
                .foregroundStyle(color)
                .bold()
                .frame(width: 45, alignment: .trailing)
        }
        .alignmentGuide(.listRowSeparatorLeading) {
            $0[.leading]
        }
    }
}

#Preview {
    List {
        ShoeProgress(
            shoe: Shoe(
                name: "Test",
                targetDistance: 500,
                color: "White",
                purchased: .now
            )
        )
    }
}
