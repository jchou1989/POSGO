import Foundation

@MainActor
class CustomizeViewModel: ObservableObject {
    @Published var sizes: [SizeOption] = []
    @Published var toppings: [ToppingOption] = []
    @Published var selectedSize: SizeOption?
    @Published var selectedToppings: Set<UUID> = []
    @Published var selectedSugar: String = "50%"
    @Published var selectedIce: String = "Normal Ice"
    @Published var quantity: Int = 1
    @Published var isLoading = false
    
    var totalPrice: Double {
        let basePrice = selectedSize?.price ?? 0
        let toppingsPrice = selectedToppings.compactMap { id in
            toppings.first { $0.id == id }?.price
        }.reduce(0, +)
        
        return (basePrice + toppingsPrice) * Double(quantity)
    }
    
    var toppingsTotal: Double {
        selectedToppings.compactMap { id in
            toppings.first { $0.id == id }?.price
        }.reduce(0, +)
    }
    
    func loadModifiers() async {
        isLoading = true
        
        do {
            async let sizesTask = SupabaseService.fetchSizeOptions()
            async let toppingsTask = SupabaseService.fetchToppingOptions()
            
            sizes = try await sizesTask
            toppings = try await toppingsTask
            
            // Set default size to the first one if available
            if selectedSize == nil {
                selectedSize = sizes.first
            }
        } catch {
            print("Failed to load modifiers: \(error)")
        }
        
        isLoading = false
    }
}
