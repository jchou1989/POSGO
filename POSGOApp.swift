import SwiftUI

@main
struct POSGOApp: App {
    @StateObject private var appState = AppState()
    
    var body: some Scene {
        WindowGroup {
            MainView()
                .environmentObject(appState)
        }
    }
}

class AppState: ObservableObject {
    @Published var cart: [OrderItem] = []
    @Published var categories: [MenuCategory] = []
}
