import SwiftUI

class CustomizeViewModel: ObservableObject {
    @Published var sizes: [SizeOption] = []
    @Published var toppings: [ToppingOption] = []
    @Published var selectedSize: SizeOption?
    @Published var selectedToppings = Set<UUID>()
    @Published var quantity = 1
    @Published var isLoading = false
    
    var totalPrice: Double {
        let basePrice = 0.0 // Will be replaced with menuItem.price later
        let sizePrice = selectedSize?.price ?? 0
        let toppingsPrice = selectedToppings.reduce(0) { sum, id in
            sum + (toppings.first { $0.id == id }?.price ?? 0)
        }
        return (basePrice + sizePrice + toppingsPrice) * Double(quantity)
    }
    
    func loadModifiers() async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            async let fetchedSizes = SupabaseService.fetchSizeOptions()
            async let fetchedToppings = SupabaseService.fetchToppingOptions()
            sizes = try await fetchedSizes
            toppings = try await fetchedToppings
        } catch {
            print("Error loading modifiers: \(error)")
        }
    }
}
