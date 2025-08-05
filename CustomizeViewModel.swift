import SwiftUI

class CustomizeViewModel: ObservableObject {
    @Published var sizes: [SizeOption] = []
    @Published var toppings: [ToppingOption] = []
    @Published var selectedSize: SizeOption?
    @Published var selectedSugarLevel: String = "Recommende"
    @Published var selectedIceLevel: String = "Normal"
    @Published var selectedToppings = Set<UUID>()
    @Published var quantity = 1
    @Published var isLoading = false
    
    private var basePrice: Double = 0.0
    
    func setBasePrice(_ price: Double) {
        basePrice = price
    }
    
    var totalPrice: Double {
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
