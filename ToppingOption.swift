import Foundation

struct ToppingOption: Identifiable, Codable, Equatable {
    var id: UUID
    var label: String
    var price: Double
    
    // Required for SwiftUI to differentiate instances
    static func == (lhs: ToppingOption, rhs: ToppingOption) -> Bool {
        return lhs.id == rhs.id
    }
}

// ADD THIS NEW EXTENSION:
extension ToppingOption {
    var formattedPrice: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        return formatter.string(from: NSNumber(value: price)) ?? "+$\(String(format: "%.2f", price))"
    }
}
