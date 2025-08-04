import Foundation

struct MenuCategory: Identifiable, Codable, Hashable {
    let id: UUID
    var name: String
}

struct MenuItem: Identifiable, Codable, Hashable {
    let id: UUID
    var name: String
    var price: Double
    var imageURL: String?
    var category_id: UUID
}

struct SizeOption: Identifiable, Codable, Hashable {
    let id: UUID
    var label: String
    var price: Double
}

// Sugar & Ice Levels are simple options with no backend IDs
struct ModifierOption: Identifiable, Hashable {
    let id = UUID()
    var label: String
}

// ADD THIS NEW EXTENSION:
extension SizeOption {
    var formattedPrice: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        return formatter.string(from: NSNumber(value: price)) ?? "+$\(String(format: "%.2f", price))"
    }
}
