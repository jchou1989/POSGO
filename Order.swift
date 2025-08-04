import Foundation

struct Order: Codable {
    let items: [OrderItem]
    let total: Double
}
