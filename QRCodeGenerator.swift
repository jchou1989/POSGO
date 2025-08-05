import Foundation
import CoreImage
import UIKit

// MARK: - QR Code Generator for Beverage Machine
class QRCodeGenerator {
    
    // MARK: - Beverage Configuration Structure
    struct BeverageConfig: Codable {
        let orderId: String
        let itemName: String
        let basePrice: Double
        let size: String
        let sugarLevel: String
        let iceLevel: String
        let toppings: [String]
        let totalPrice: Double
        let timestamp: Date
        let machineId: String
        
        // Beverage Machine QR Format: Beverage ID|Cup Size ID,Ice Level ID,Sugar Level ID
        var qrData: String {
            let beverageId = getBeverageId(for: itemName)
            let cupSizeId = getCupSizeId(for: size)
            let iceLevelId = getIceLevelId(for: iceLevel)
            let sugarLevelId = getSugarLevelId(for: sugarLevel)
            
            // Format: {beverageId}|{cupSizeId},{iceLevelId},{sugarLevelId}
            return "\(beverageId)|\(cupSizeId),\(iceLevelId),\(sugarLevelId)"
        }
        
        // Beverage ID mapping based on your Excel data
        private func getBeverageId(for itemName: String) -> String {
            switch itemName {
            case "Fragrant Black Tea": return "BT001"
            case "Brown Sugar Pearl Milk Tea": return "BS001"
            case "Iced Lemon Tea": return "IL001"
            case "Black Tea Latte": return "BL001"
            case "Oolong Tea Latte": return "OL001"
            case "Oolong Tea": return "OT001"
            case "Pomegranate Green Tea": return "PG001"
            case "Passionfruit Green Tea": return "PS001"
            case "Green Milk Tea": return "GM001"
            case "Green Tea Latte": return "GL001"
            case "Green Tea": return "GT001"
            case "Matcha Milk Tea": return "MM001"
            case "Matcha Tea": return "MT001"
            case "Matcha Latte": return "ML001"
            case "Da Jia": return "DJ001"
            case "Angel Summer": return "AS001"
            case "Wintermelon Milk Tea": return "WM001"
            case "Wintermelon Tea": return "WT001"
            case "Wintermelon Tea With Sea Salt Foam": return "WF001"
            case "Black Bear": return "BB001"
            case "The Duke": return "DK001"
            case "Dalgona Coffee": return "DC001"
            default: return "UN001"
            }
        }
        
        // Cup Size ID mapping (from your admin interface: lg=Large, md=Medium, hp=Hot Cup)
        private func getCupSizeId(for size: String) -> String {
            switch size.lowercased() {
            case "large": return "lg"
            case "medium": return "md"
            case "hot": return "hp"
            default: return "md" // Default to Medium
            }
        }
        
        // Sugar Level ID mapping (from your admin interface: zs=Zero Sugar, ls=Less, rd=Recommended, ex=Extra)
        private func getSugarLevelId(for sugarLevel: String) -> String {
            switch sugarLevel.lowercased() {
            case "extra": return "ex"
            case "recommende": return "rd"
            case "less": return "ls"
            case "zero sugar": return "zs"
            default: return "rd" // Default to Recommended
            }
        }
        
        // Ice Level ID mapping (from your admin interface: nr=Normal, li=Less Ice, ni=No Ice, h=Hot)
        private func getIceLevelId(for iceLevel: String) -> String {
            switch iceLevel.lowercased() {
            case "normal": return "nr"
            case "less ice": return "li"
            case "no ice": return "ni"
            case "hot": return "h"
            default: return "nr" // Default to Normal
            }
        }
    }
    
    // MARK: - Generate QR Code
    static func generateQRCode(for config: BeverageConfig, size: CGFloat = 200) -> UIImage? {
        guard let data = config.qrData.data(using: .utf8) else { return nil }
        
        // Create QR code filter
        guard let qrFilter = CIFilter(name: "CIQRCodeGenerator") else { return nil }
        qrFilter.setValue(data, forKey: "inputMessage")
        qrFilter.setValue("H", forKey: "inputCorrectionLevel") // High error correction
        
        guard let qrImage = qrFilter.outputImage else { return nil }
        
        // Scale the QR code
        let transform = CGAffineTransform(scaleX: size / qrImage.extent.width, 
                                         y: size / qrImage.extent.height)
        let scaledQRImage = qrImage.transformed(by: transform)
        
        // Convert to UIImage
        let context = CIContext()
        guard let cgImage = context.createCGImage(scaledQRImage, from: scaledQRImage.extent) else { return nil }
        
        return UIImage(cgImage: cgImage)
    }
    
    // MARK: - Generate Beverage Config from Order Item
    static func createBeverageConfig(from orderItem: OrderItem, orderId: String, machineId: String = "BEV001") -> BeverageConfig {
        return BeverageConfig(
            orderId: orderId,
            itemName: orderItem.name,
            basePrice: orderItem.basePrice,
            size: orderItem.size,
            sugarLevel: orderItem.sugarLevel ?? "Recommende",
            iceLevel: orderItem.iceLevel ?? "Normal",
            toppings: orderItem.selectedToppings,
            totalPrice: orderItem.price,
            timestamp: Date(),
            machineId: machineId
        )
    }
    
    // MARK: - Generate Receipt with QR Code
    static func generateReceiptWithQRCode(order: Order, qrCodeImage: UIImage?) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .short
        
        var receipt = """
        ========================================
                    POS GO RECEIPT
        ========================================
        Order ID: \(order.id.uuidString.prefix(8))
        Date: \(dateFormatter.string(from: order.timestamp))
        ========================================
        
        """
        
        // Add items
        for item in order.items {
            receipt += """
            \(item.name)
            Size: \(item.size)
            Sugar: \(item.sugarLevel ?? "Regular")
            Ice: \(item.iceLevel ?? "Regular Ice")
            """
            
            if !item.selectedToppings.isEmpty {
                receipt += "Toppings: \(item.selectedToppings.joined(separator: ", "))\n"
            }
            
            receipt += "Price: \(item.qarFormattedPrice)\n\n"
        }
        
        receipt += """
        ========================================
        Total: \(NumberFormatter.qarFormatter.string(from: NSNumber(value: order.total)) ?? "QR \(String(format: "%.2f", order.total))")
        Payment: \(order.paymentMethod?.rawValue ?? "Pending")
        Status: \(order.paymentStatus?.displayName ?? "Pending")
        ========================================
        
        """
        
        if order.paymentMethod == .cash {
            receipt += "Thank you for your payment!\n"
        } else {
            receipt += "Payment processed successfully!\n"
        }
        
        receipt += """
        
        Scan QR code for beverage machine
        ========================================
        """
        
        return receipt
    }
}

// MARK: - Order Item Extensions for QR Code
extension OrderItem {
    var basePrice: Double {
        // Extract base price from total price by subtracting modifiers
        var base = price
        if size != "Small" {
            base -= 3.0 // Medium/Large upcharge
        }
        // Subtract topping prices (assuming 3 QR each)
        base -= Double(selectedToppings.count) * 3.0
        return max(base, 0)
    }
} 