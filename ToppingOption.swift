import Foundation

struct ToppingOption: Identifiable, Codable, Hashable {
    let id: UUID
    var label: String
    var price: Double
    
    var formattedPrice: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        return formatter.string(from: NSNumber(value: price)) ?? "+$\(String(format: "%.2f", price))"
    }
}
