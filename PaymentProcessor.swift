import Foundation
import Combine

// MARK: - Payment Models
enum PaymentMethod: String, CaseIterable {
    case card = "card"
    case cash = "cash"
    case contactless = "contactless"
    
    var displayName: String {
        switch self {
        case .card: return "Credit/Debit Card"
        case .cash: return "Cash"
        case .contactless: return "Contactless"
        }
    }
    
    var icon: String {
        switch self {
        case .card: return "creditcard.fill"
        case .cash: return "dollarsign.circle.fill"
        case .contactless: return "wave.3.right"
        }
    }
}

enum PaymentStatus: String {
    case pending = "pending"
    case processing = "processing"
    case completed = "completed"
    case failed = "failed"
    case cancelled = "cancelled"
}

struct PaymentRequest {
    let id: UUID
    let amount: Double
    let currency: String
    let method: PaymentMethod
    let description: String
    let metadata: [String: Any]
    
    init(amount: Double, method: PaymentMethod, description: String, metadata: [String: Any] = [:]) {
        self.id = UUID()
        self.amount = amount
        self.currency = "USD"
        self.method = method
        self.description = description
        self.metadata = metadata
    }
}

struct PaymentResult {
    let id: UUID
    let paymentId: String
    let status: PaymentStatus
    let amount: Double
    let method: PaymentMethod
    let timestamp: Date
    let receiptNumber: String
    let errorMessage: String?
    
    init(id: UUID, paymentId: String, status: PaymentStatus, amount: Double, method: PaymentMethod, errorMessage: String? = nil) {
        self.id = id
        self.paymentId = paymentId
        self.status = status
        self.amount = amount
        self.method = method
        self.timestamp = Date()
        self.receiptNumber = "RCP-\(Int.random(in: 100000...999999))"
        self.errorMessage = errorMessage
    }
}

// MARK: - Payment Processor
@MainActor
class PaymentProcessor: ObservableObject {
    @Published var isProcessing = false
    @Published var currentPayment: PaymentRequest?
    @Published var lastResult: PaymentResult?
    
    // Simulated payment processing - replace with actual payment SDK
    func processPayment(_ request: PaymentRequest) async -> PaymentResult {
        isProcessing = true
        currentPayment = request
        
        // Simulate processing delay
        try? await Task.sleep(nanoseconds: 2_000_000_000) // 2 seconds
        
        let result: PaymentResult
        
        switch request.method {
        case .cash:
            // Cash payments are always successful
            result = PaymentResult(
                id: request.id,
                paymentId: "CASH-\(UUID().uuidString.prefix(8))",
                status: .completed,
                amount: request.amount,
                method: request.method
            )
            
        case .card, .contactless:
            // Simulate 95% success rate for card payments
            let isSuccessful = Double.random(in: 0...1) < 0.95
            
            if isSuccessful {
                result = PaymentResult(
                    id: request.id,
                    paymentId: "TXN-\(UUID().uuidString.prefix(8))",
                    status: .completed,
                    amount: request.amount,
                    method: request.method
                )
            } else {
                result = PaymentResult(
                    id: request.id,
                    paymentId: "FAIL-\(UUID().uuidString.prefix(8))",
                    status: .failed,
                    amount: request.amount,
                    method: request.method,
                    errorMessage: "Card declined. Please try another payment method."
                )
            }
        }
        
        isProcessing = false
        currentPayment = nil
        lastResult = result
        
        return result
    }
    
    func cancelPayment() {
        isProcessing = false
        currentPayment = nil
    }
}

// MARK: - Receipt Generator
struct ReceiptGenerator {
    static func generateReceipt(for order: [OrderItem], paymentResult: PaymentResult, customerName: String? = nil, customerPhone: String? = nil) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .short
        
        let subtotal = order.reduce(0) { $0 + $1.price }
        let tax = subtotal * 0.08875
        let total = subtotal + tax
        
        var receipt = """
        ========================================
        CHAGEE - MODERN TEA CULTURE
        ========================================
        
        Date: \(dateFormatter.string(from: paymentResult.timestamp))
        Receipt #: \(paymentResult.receiptNumber)
        Transaction ID: \(paymentResult.paymentId)
        
        """
        
        if let name = customerName, !name.isEmpty {
            receipt += "Customer: \(name)\n"
        }
        
        if let phone = customerPhone, !phone.isEmpty {
            receipt += "Phone: \(phone)\n"
        }
        
        receipt += "\n----------------------------------------\nITEMS:\n----------------------------------------\n"
        
        for item in order {
            receipt += "\n\(item.name)\n"
            
            if !item.size.isEmpty {
                receipt += "  Size: \(item.size)\n"
            }
            
            if !item.sugar.isEmpty && item.sugar != "Normal" {
                receipt += "  Sugar: \(item.sugar)\n"
            }
            
            if !item.ice.isEmpty && item.ice != "Normal Ice" {
                receipt += "  Ice: \(item.ice)\n"
            }
            
            if !item.toppings.isEmpty {
                receipt += "  Toppings: \(item.toppings.joined(separator: ", "))\n"
            }
            
            receipt += "  $\(String(format: "%.2f", item.price))\n"
        }
        
        receipt += """
        
        ----------------------------------------
        SUMMARY:
        ----------------------------------------
        Subtotal:        $\(String(format: "%.2f", subtotal))
        Tax (8.875%):    $\(String(format: "%.2f", tax))
        ----------------------------------------
        TOTAL:           $\(String(format: "%.2f", total))
        
        Payment Method: \(paymentResult.method.displayName)
        Status: \(paymentResult.status.rawValue.capitalized)
        
        ========================================
        Thank you for choosing CHAGEE!
        Visit us again soon!
        ========================================
        """
        
        return receipt
    }
}

// MARK: - Mock Payment SDK Integration
// This would be replaced with actual payment provider SDKs like:
// - Square SDK
// - Stripe Terminal
// - PayPal Here
// - Clover SDK

class MockCardReader: ObservableObject {
    @Published var isConnected = false
    @Published var batteryLevel = 85
    @Published var isReady = true
    
    func connect() async {
        // Simulate connection delay
        try? await Task.sleep(nanoseconds: 1_000_000_000)
        isConnected = true
    }
    
    func disconnect() {
        isConnected = false
    }
    
    func readCard() async -> Bool {
        // Simulate card reading
        try? await Task.sleep(nanoseconds: 2_000_000_000)
        return Double.random(in: 0...1) > 0.1 // 90% success rate
    }
}