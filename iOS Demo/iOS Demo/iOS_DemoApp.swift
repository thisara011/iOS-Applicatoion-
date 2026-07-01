import SwiftUI
import SwiftData

@main
struct iOS_DemoApp: App {
    var body: some Scene {
        WindowGroup {
            HomeScreenView()
                .modelContainer(for: Item.self)
        }
    }
}
