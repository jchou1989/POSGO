import Foundation

class CartViewModel: ObservableObject {
    @Published var isSubmitting = false
    @Published var showError = false
    @Published var showSuccess = false
    @Published var errorMessage = ""
    
    var formattedTotal: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        return formatter.string(from: 0) ?? "$0.00" // Replace with actual calculation
    }
    
    func submitOrder(cart: [OrderItem]) async -> Bool {
        isSubmitting = true
        defer { isSubmitting = false }
        
        do {
            try await SupabaseService.submitOrder(order: Order(items: cart, total: 0)) // Replace with actual total
            showSuccess = true
            return true
        } catch {
            errorMessage = error.localizedDescription
            showError = true
            return false
        }
    }
}
