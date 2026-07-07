import SwiftUI

struct HomeTab: View {
    var body: some View {
        NavigationStack {
            HomeScreenView()
                .toolbar(.hidden, for: .navigationBar)
        }
    }
}

#if DEBUG
#Preview {
    HomeTab()
        .environmentObject(SessionStore())
}
#endif
