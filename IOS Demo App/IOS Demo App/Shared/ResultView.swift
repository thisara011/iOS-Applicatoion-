import SwiftUI

struct ResultView: View {
    let title: String
    let subtitle: String?

    var body: some View {
        VStack(spacing: 12) {
            Text(title)
                .font(.largeTitle)
                .fontWeight(.bold)
            if let subtitle {
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
    }
}

#if DEBUG
#Preview {
    ResultView(title: "Finished", subtitle: "Great job!")
}
#endif
