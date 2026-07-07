import SwiftUI

struct ScoreBadge: View {
    let score: Int

    var body: some View {
        Text("\(score)")
            .font(.headline)
            .padding(8)
            .background(Circle().fill(Color.blue))
            .foregroundStyle(.white)
    }
}

#if DEBUG
#Preview {
    ScoreBadge(score: 42)
}
#endif
