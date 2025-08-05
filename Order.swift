import Foundation

struct Order: Identifiable, Codable {
    let id: UUID
    let items: [OrderItem]
    let total: Double
    let status: OrderStatus
    let paymentMethod: PaymentMethod?
    let paymentStatus: PaymentStatus?
    let timestamp: Date
    
    init(items: [OrderItem], total: Double, status: OrderStatus = .pending, paymentMethod: PaymentMethod? = nil, paymentStatus: PaymentStatus? = nil) {
        self.id = UUID()
        self.items = items
        self.total = total
        self.status = status
        self.paymentMethod = paymentMethod
        self.paymentStatus = paymentStatus
        self.timestamp = Date()
    }
}
