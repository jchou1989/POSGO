import SwiftUI

@main
struct POSGOApp: App {
    @StateObject private var appState = AppState()
    @StateObject private var authManager = AuthenticationManager()
    @StateObject private var paymentManager = PaymentManager()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appState)
                .environmentObject(authManager)
                .environmentObject(paymentManager)
                .preferredColorScheme(.light) // POS apps typically use light mode
        }
        .windowStyle(.hiddenTitleBar) // Full-screen experience for iPad
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
        isLoading = true
        defer { isLoading = false }
        
        // Simulate authentication
        try? await Task.sleep(nanoseconds: 1_000_000_000)
        
        // For demo purposes, accept any login
        isAuthenticated = true
        currentUser = Employee(id: UUID(), name: username, role: .cashier)
        return true
    }
    
    func logout() {
        isAuthenticated = false
        currentUser = nil
    }
}

class PaymentManager: ObservableObject {
    @Published var isProcessing = false
    @Published var lastTransaction: PaymentTransaction?
    
    func processPayment(amount: Double, method: PaymentMethod) async -> PaymentResult {
        isProcessing = true
        defer { isProcessing = false }
        
        // Simulate payment processing
        try? await Task.sleep(nanoseconds: 2_000_000_000)
        
        let transaction = PaymentTransaction(
            id: UUID(),
            amount: amount,
            method: method,
            status: .success,
            timestamp: Date()
        )
        
        lastTransaction = transaction
        return PaymentResult.success(transaction)
    }
}

// MARK: - Supporting Models
struct Employee: Identifiable, Codable {
    let id: UUID
    let name: String
    let role: EmployeeRole
}

enum EmployeeRole: String, Codable, CaseIterable {
    case cashier = "Cashier"
    case manager = "Manager"
    case admin = "Admin"
}

enum PaymentMethod: String, CaseIterable {
    case cash = "Cash"
    case card = "Card"
    case mobile = "Mobile"
    case giftCard = "Gift Card"
}

struct PaymentTransaction: Identifiable {
    let id: UUID
    let amount: Double
    let method: PaymentMethod
    let status: PaymentStatus
    let timestamp: Date
}

enum PaymentStatus {
    case pending
    case success
    case failed
}

enum PaymentResult {
    case success(PaymentTransaction)
    case failure(String)
}
