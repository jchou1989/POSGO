import SwiftUI

@main
struct POSGOApp: App {
    @StateObject private var appState = AppState()
    @StateObject private var authManager = AuthenticationManager()
    @StateObject private var paymentManager = PaymentManager()
    @StateObject private var errorHandler = ErrorHandler.shared
    @StateObject private var networkMonitor = NetworkMonitor.shared
    @StateObject private var offlineManager = OfflineManager.shared
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appState)
                .environmentObject(authManager)
                .environmentObject(paymentManager)
                .environmentObject(errorHandler)
                .environmentObject(networkMonitor)
                .environmentObject(offlineManager)
                .preferredColorScheme(.light) // POS apps typically use light mode
                .alert("Error", isPresented: $errorHandler.isShowingError) {
                    Button("OK") {
                        errorHandler.clearError()
                    }
                } message: {
                    if let error = errorHandler.currentError {
                        Text(error.errorDescription ?? "Unknown error")
                    }
                }
        }
    }
}

class AppState: ObservableObject {
    @Published var cart: [OrderItem] = []
    @Published var categories: [MenuCategory] = []
    @Published var currentOrder: Order?
    @Published var isOffline = false
    @Published var lastSyncTime: Date?
    
    // Cart management
    func addToCart(_ item: OrderItem) {
        cart.append(item)
        saveCartToLocal()
    }
    
    func removeFromCart(at indexSet: IndexSet) {
        cart.remove(atOffsets: indexSet)
        saveCartToLocal()
    }
    
    func clearCart() {
        cart.removeAll()
        saveCartToLocal()
    }
    
    private func saveCartToLocal() {
        // Save cart to UserDefaults for persistence
        if let encoded = try? JSONEncoder().encode(cart) {
            UserDefaults.standard.set(encoded, forKey: "savedCart")
        }
    }
    
    func loadCartFromLocal() {
        if let data = UserDefaults.standard.data(forKey: "savedCart"),
           let decoded = try? JSONDecoder().decode([OrderItem].self, from: data) {
            cart = decoded
        }
    }
}

class AuthenticationManager: ObservableObject {
    @Published var isAuthenticated = false
    @Published var currentUser: Employee?
    @Published var isLoading = false
    
    func login(username: String, password: String) async -> Bool {
        await MainActor.run {
            isLoading = true
        }
        
        // Simulate authentication delay
        try? await Task.sleep(nanoseconds: 1_000_000_000)
        
        // Check against production user credentials
        if let user = ProductionData.defaultUsers.first(where: { $0.name.lowercased() == username.lowercased() }) {
            // In production, you would validate password here
            // For now, accept any password for demo
            await MainActor.run {
                isAuthenticated = true
                currentUser = user
                isLoading = false
            }
            return true
        }
        
        // Fallback for demo: create a cashier with the entered name
        await MainActor.run {
            isAuthenticated = true
            currentUser = Employee(id: UUID(), name: username, role: .cashier)
            isLoading = false
        }
        return true
    }
    
    func logout() {
        Task { @MainActor in
            isAuthenticated = false
            currentUser = nil
        }
    }
}

class PaymentManager: ObservableObject {
    @Published var isProcessing = false
    @Published var lastTransaction: PaymentTransaction?
    
    func processPayment(amount: Double, method: PaymentMethod) async -> PaymentResult {
        await MainActor.run {
            isProcessing = true
        }
        
        // Simulate payment processing
        try? await Task.sleep(nanoseconds: 2_000_000_000)
        
        let transaction = PaymentTransaction(
            id: UUID(),
            amount: amount,
            method: method,
            status: .success,
            timestamp: Date()
        )
        
        await MainActor.run {
            lastTransaction = transaction
            isProcessing = false
        }
        return PaymentResult.success(transaction)
    }
}
