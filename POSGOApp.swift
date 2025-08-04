import SwiftUI

@main
struct POSGOApp: App {
    @StateObject private var appState = AppState()
    
    var body: some Scene {
        WindowGroup {
            ChageePOSView()
                .environmentObject(appState)
                .statusBar(hidden: true) // Hide status bar for full-screen POS experience
        }
        .windowStyle(.hiddenTitleBar) // For macOS
    }
}

class AppState: ObservableObject {
    @Published var cart: [OrderItem] = []
    @Published var categories: [MenuCategory] = []
}
