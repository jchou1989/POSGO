import Foundation
import SwiftUI

// MARK: - Payment Models
enum PaymentMethod: String, CaseIterable, Codable {
    case cash = "Cash"
    case card = "Card"
    case qlub = "Qlub"
    case mobile = "Mobile"
    case giftCard = "Gift Card"
}

enum PaymentStatus: Codable {
    case pending
    case success
    case failed
    
    var displayName: String {
        switch self {
        case .pending: return "Pending"
        case .success: return "Success"
        case .failed: return "Failed"
        }
    }
    
    var color: Color {
        switch self {
        case .pending: return .orange
        case .success: return .green
        case .failed: return .red
        }
    }
}

enum PaymentResult: Codable {
    case success(PaymentTransaction)
    case failure(String)
}

struct PaymentTransaction: Identifiable, Codable {
    let id: UUID
    let amount: Double
    let method: PaymentMethod
    let status: PaymentStatus
    let timestamp: Date
}

// MARK: - Employee Models
struct Employee: Identifiable, Codable {
    let id: UUID
    let name: String
    let role: EmployeeRole
}

enum EmployeeRole: String, Codable, CaseIterable {
    case cashier = "Cashier"
    case manager = "Manager"
    case admin = "Admin"
}

// MARK: - Order Types
enum OrderType: String, Codable, CaseIterable {
    case walkIn = "walk_in"
    case talabat = "talabat"
    case deliveroo = "deliveroo"
    case uberEats = "uber_eats"
    case phone = "phone"
    case online = "online"
    
    var displayName: String {
        switch self {
        case .walkIn: return "Walk-in"
        case .talabat: return "Talabat"
        case .deliveroo: return "Deliveroo"
        case .uberEats: return "Uber Eats"
        case .phone: return "Phone"
        case .online: return "Online"
        }
    }
    
    var icon: String {
        switch self {
        case .walkIn: return "person.fill"
        case .talabat: return "car.fill"
        case .deliveroo: return "bicycle"
        case .uberEats: return "car.fill"
        case .phone: return "phone.fill"
        case .online: return "globe"
        }
    }
    
    var color: Color {
        switch self {
        case .walkIn: return .blue
        case .talabat: return .orange
        case .deliveroo: return .green
        case .uberEats: return .black
        case .phone: return .purple
        case .online: return .cyan
        }
    }
}

// MARK: - Order Status
enum OrderStatus: String, Codable, CaseIterable {
    case pending = "pending"
    case inProgress = "in_progress"
    case completed = "completed"
    case cancelled = "cancelled"
    case ready = "ready"
    case outForDelivery = "out_for_delivery"
    
    var displayName: String {
        switch self {
        case .pending: return "Pending"
        case .inProgress: return "In Progress"
        case .completed: return "Completed"
        case .cancelled: return "Cancelled"
        case .ready: return "Ready"
        case .outForDelivery: return "Out for Delivery"
        }
    }
    
    var color: Color {
        switch self {
        case .pending: return .orange
        case .inProgress: return .blue
        case .completed: return .green
        case .cancelled: return .red
        case .ready: return .yellow
        case .outForDelivery: return .purple
        }
    }
} 