import SwiftUI

struct ShoeProgress: View {
    let shoe: Shoe

    var body: some View {
        ProgressView(value: shoe.progress)
    }
}
