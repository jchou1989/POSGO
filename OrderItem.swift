import Foundation

struct OrderItem: Identifiable, Codable {
    var id = UUID()
    var name: String
    var size: String
    var sugarLevel: String?
    var iceLevel: String?
    var selectedToppings: [String]
    var sizePrice: Double
    var toppingPrices: [Double]
    var price: Double
    
    // MARK: - Computed Properties
    // Note: qarFormattedPrice is defined in ProductionData.swift extension
    
    // MARK: - Sugar Level Alias for backward compatibility
    var sugar: String {
        get { sugarLevel ?? "Recommende" }
        set { sugarLevel = newValue }
    }
    
    // MARK: - Ice Level Alias for backward compatibility
    var ice: String {
        get { iceLevel ?? "Normal" }
        set { iceLevel = newValue }
    }
    
    // MARK: - Toppings Alias for backward compatibility
    var toppings: [String] {
        get { selectedToppings }
        set { selectedToppings = newValue }
    }
}
