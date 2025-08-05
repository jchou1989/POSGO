import Foundation

class CartViewModel: ObservableObject {
    @Published var isSubmitting = false
    @Published var showError = false
    @Published var showSuccess = false
    @Published var errorMessage = ""
    
    func calculateTotal(from cart: [OrderItem]) -> Double {
        return cart.reduce(0) { $0 + $1.price }
    }
    
    func formattedTotal(from cart: [OrderItem]) -> String {
        let total = calculateTotal(from: cart)
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        return formatter.string(from: NSNumber(value: total)) ?? "$\(String(format: "%.2f", total))"
    }
    
    func submitOrder(cart: [OrderItem]) async -> Bool {
        await MainActor.run {
            isSubmitting = true
        }
        
        do {
            let total = calculateTotal(from: cart)
            try await SupabaseService.submitOrder(order: Order(items: cart, total: total))
            
            await MainActor.run {
                showSuccess = true
                isSubmitting = false
            }
            return true
        } catch {
            await MainActor.run {
                errorMessage = error.localizedDescription
                showError = true
                isSubmitting = false
            }
            return false
        }
    }
}
