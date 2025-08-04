import Foundation

struct OrderItem: Identifiable, Codable {
    var id = UUID()
    var name: String
    var size: String
    var sugar: String
    var ice: String
    var toppings: [String]
    var sizePrice: Double
    var toppingPrices: [Double]
    var price: Double
    
    // ADD THIS NEW COMPUTED PROPERTY:
    var formattedPrice: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        return formatter.string(from: NSNumber(value: price)) ?? "$\(String(format: "%.2f", price))"
    }
}
