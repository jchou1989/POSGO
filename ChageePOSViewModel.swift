import SwiftUI
import Combine

@MainActor
class ChageePOSViewModel: ObservableObject {
    @Published var categories: [MenuCategory] = []
    @Published var menuItems: [MenuItem] = []
    @Published var cart: [OrderItem] = []
    @Published var currentOrderNumber: Int = 1
    @Published var isProcessingOrder = false
    @Published var showingPaymentView = false
    
    private let taxRate: Double = 0.08 // 8% tax
    
    // MARK: - Computed Properties
    var subtotal: Double {
        cart.reduce(0) { $0 + $1.price }
    }
    
    var tax: Double {
        subtotal * taxRate
    }
    
    var total: Double {
        subtotal + tax
    }
    
    var formattedSubtotal: String {
        formatCurrency(subtotal)
    }
    
    var formattedTax: String {
        formatCurrency(tax)
    }
    
    var formattedTotal: String {
        formatCurrency(total)
    }
    
    // MARK: - Data Loading
    func loadData() async {
        do {
            // Load categories
            categories = try await SupabaseService.fetchCategories()
            
            // Load all menu items
            menuItems = try await SupabaseService.fetchAllMenuItems()
            
            // Set current order number based on today's orders
            currentOrderNumber = await getNextOrderNumber()
        } catch {
            print("Error loading data: \(error)")
            // In production, show error alert
        }
    }
    
    // MARK: - Cart Management
    func addToCart(_ item: OrderItem) {
        cart.append(item)
        
        // Play haptic feedback
        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
        impactFeedback.impactOccurred()
    }
    
    func removeFromCart(at index: Int) {
        guard index < cart.count else { return }
        cart.remove(at: index)
    }
    
    func clearCart() {
        cart.removeAll()
    }
    
    func updateQuantity(at index: Int, quantity: Int) {
        guard index < cart.count, quantity > 0 else { return }
        // In a real app, you'd update the quantity property
        // For now, we'll handle quantity through multiple items
    }
    
    // MARK: - Order Processing
    func processCheckout() {
        guard !cart.isEmpty else { return }
        
        // Show payment view instead of processing directly
        showingPaymentView = true
    }
    
    func completePayment(method: PaymentView.PaymentMethod) {
        isProcessingOrder = true
        
        Task {
            do {
                // Create order
                let order = Order(items: cart, total: total)
                
                // Submit to backend
                try await SupabaseService.submitOrder(order: order)
                
                // Success actions
                await MainActor.run {
                    // Play success sound/haptic
                    let notificationFeedback = UINotificationFeedbackGenerator()
                    notificationFeedback.notificationOccurred(.success)
                    
                    // Clear cart
                    clearCart()
                    
                    // Increment order number
                    currentOrderNumber += 1
                    
                    isProcessingOrder = false
                    showingPaymentView = false
                    
                    // In production: Print receipt, show success message
                }
            } catch {
                await MainActor.run {
                    isProcessingOrder = false
                    // Show error alert
                    print("Order failed: \(error)")
                }
            }
        }
    }
    
    // MARK: - Helper Methods
    private func formatCurrency(_ amount: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        return formatter.string(from: NSNumber(value: amount)) ?? "$\(String(format: "%.2f", amount))"
    }
    
    private func getNextOrderNumber() async -> Int {
        // In production, fetch from backend based on today's orders
        // For now, return a default
        return 1
    }
}

// MARK: - Extended Supabase Service
extension SupabaseService {
    static func fetchAllMenuItems() async throws -> [MenuItem] {
        // Fetch all menu items across all categories
        let items: [MenuItem] = try await supabase
            .from("menu_items")
            .select()
            .execute()
            .value
        
        return items
    }
}