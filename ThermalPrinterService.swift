import Foundation
import UIKit
import CoreImage

// MARK: - HPRT XT100 Thermal Printer Service
class ThermalPrinterService: ObservableObject {
    static let shared = ThermalPrinterService()
    
    @Published var isConnected = false
    @Published var isPrinting = false
    @Published var lastError: String?
    
    private init() {}
    
    // MARK: - Print QR Code Label for Single Drink
    func printQRCodeLabel(for orderItem: OrderItem, orderId: String) async -> Bool {
        await MainActor.run {
            isPrinting = true
            lastError = nil
        }
        
        defer {
            Task { @MainActor in
                isPrinting = false
            }
        }
        
        do {
            // Generate QR code data
            let beverageConfig = QRCodeGenerator.createBeverageConfig(
                from: orderItem, 
                orderId: orderId, 
                machineId: "HPRT001"
            )
            
            // Generate QR code image
            guard let qrCodeImage = QRCodeGenerator.generateQRCode(for: beverageConfig, size: 200) else {
                await MainActor.run {
                    lastError = "Failed to generate QR code"
                }
                return false
            }
            
            // Create label content
            let labelContent = createLabelContent(for: orderItem, qrData: beverageConfig.qrData)
            
            // Print to HPRT XT100
            return await printToHPRTXT100(labelContent: labelContent, qrCodeImage: qrCodeImage)
        }
        // Note: No catch block needed as the operation is simulated and doesn't throw
    }
    
    // MARK: - Print Multiple QR Code Labels
    func printMultipleQRLabels(for order: Order) async -> Bool {
        await MainActor.run {
            isPrinting = true
            lastError = nil
        }
        
        defer {
            Task { @MainActor in
                isPrinting = false
            }
        }
        
        var successCount = 0
        
        for (index, item) in order.items.enumerated() {
            let orderId = "\(order.id.uuidString.prefix(8))-\(index + 1)"
            
            if await printQRCodeLabel(for: item, orderId: orderId) {
                successCount += 1
            }
            
            // Small delay between prints
            try? await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
        }
        
        let finalSuccessCount = successCount
        let totalItems = order.items.count
        
        await MainActor.run {
            if finalSuccessCount == totalItems {
                lastError = nil
            } else {
                lastError = "Printed \(finalSuccessCount)/\(totalItems) labels successfully"
            }
        }
        
        return successCount > 0
    }
    
    // MARK: - Create Label Content
    private func createLabelContent(for orderItem: OrderItem, qrData: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy HH:mm"
        let timestamp = dateFormatter.string(from: Date())
        
        return """
        ========================================
                    DRINK LABEL
        ========================================
        Item: \(orderItem.name)
        Size: \(orderItem.size)
        Sugar: \(orderItem.sugarLevel ?? "Recommende")
        Ice: \(orderItem.iceLevel ?? "Normal")
        
        QR Data: \(qrData)
        Time: \(timestamp)
        ========================================
        """
    }
    
    // MARK: - HPRT XT100 Printer Communication
    private func printToHPRTXT100(labelContent: String, qrCodeImage: UIImage) async -> Bool {
        // HPRT XT100 ESC/POS Commands
        var printData = Data()
        
        // Initialize printer
        printData.append(contentsOf: [0x1B, 0x40]) // ESC @ - Initialize printer
        
        // Set alignment to center
        printData.append(contentsOf: [0x1B, 0x61, 0x01]) // ESC a 1 - Center alignment
        
        // Set font size (double height and width)
        printData.append(contentsOf: [0x1B, 0x21, 0x30]) // ESC ! 48 - Double height and width
        
        // Print title
        printData.append("DRINK LABEL\n".data(using: .utf8) ?? Data())
        
        // Reset font size
        printData.append(contentsOf: [0x1B, 0x21, 0x00]) // ESC ! 0 - Normal size
        
        // Set alignment to left
        printData.append(contentsOf: [0x1B, 0x61, 0x00]) // ESC a 0 - Left alignment
        
        // Print label content
        printData.append(labelContent.data(using: .utf8) ?? Data())
        
        // Add QR code image
        if let qrImageData = addQRCodeToPrintData(qrCodeImage) {
            printData.append(qrImageData)
        }
        
        // Feed paper and cut
        printData.append(contentsOf: [0x0A, 0x0A, 0x0A]) // Line feeds
        printData.append(contentsOf: [0x1D, 0x56, 0x00]) // GS V 0 - Full cut
        
        // Send to printer (simulated for now)
        return await sendToPrinter(printData)
    }
    
    // MARK: - Add QR Code to Print Data
    private func addQRCodeToPrintData(_ qrImage: UIImage) -> Data? {
        var printData = Data()
        
        // Set alignment to center for QR code
        printData.append(contentsOf: [0x1B, 0x61, 0x01]) // ESC a 1 - Center alignment
        
        // Convert QR image to bitmap data
        guard let cgImage = qrImage.cgImage,
              let colorSpace = CGColorSpace(name: CGColorSpace.genericGrayGamma2_2),
              let context = CGContext(data: nil,
                                    width: cgImage.width,
                                    height: cgImage.height,
                                    bitsPerComponent: 8,
                                    bytesPerRow: cgImage.width,
                                    space: colorSpace,
                                    bitmapInfo: CGImageAlphaInfo.none.rawValue) else {
            return nil
        }
        
        context.draw(cgImage, in: CGRect(x: 0, y: 0, width: cgImage.width, height: cgImage.height))
        
        guard let imageData = context.data else { return nil }
        
        // Convert to printer bitmap format
        let bitmapData = convertToPrinterBitmap(imageData: imageData, width: cgImage.width, height: cgImage.height)
        
        // Add bitmap print command
        printData.append(contentsOf: [0x1D, 0x76, 0x30, 0x00]) // GS v 0 - Print bitmap
        printData.append(contentsOf: [UInt8(bitmapData.count & 0xFF), UInt8((bitmapData.count >> 8) & 0xFF)])
        printData.append(contentsOf: [UInt8(cgImage.width & 0xFF), UInt8((cgImage.width >> 8) & 0xFF)])
        printData.append(contentsOf: [UInt8(cgImage.height & 0xFF), UInt8((cgImage.height >> 8) & 0xFF)])
        printData.append(bitmapData)
        
        return printData
    }
    
    // MARK: - Convert Image to Printer Bitmap
    private func convertToPrinterBitmap(imageData: UnsafeMutableRawPointer, width: Int, height: Int) -> Data {
        var bitmapData = Data()
        let bytesPerRow = width
        
        for y in 0..<height {
            for x in stride(from: 0, to: width, by: 8) {
                var byte: UInt8 = 0
                
                for bit in 0..<8 {
                    let pixelX = x + bit
                    if pixelX < width {
                        let pixelIndex = y * bytesPerRow + pixelX
                        let pixelValue = imageData.load(fromByteOffset: pixelIndex, as: UInt8.self)
                        
                        // Convert grayscale to black/white (threshold 128)
                        if pixelValue < 128 {
                            byte |= (1 << (7 - bit))
                        }
                    }
                }
                
                bitmapData.append(byte)
            }
        }
        
        return bitmapData
    }
    
    // MARK: - Send Data to Printer (Simulated)
    private func sendToPrinter(_ printData: Data) async -> Bool {
        // Simulate printer communication
        // In a real implementation, this would use:
        // - Network printing (TCP/IP)
        // - Bluetooth printing
        // - USB printing
        // - AirPrint
        
        // Simulate print delay
        try? await Task.sleep(nanoseconds: 2_000_000_000) // 2 seconds
        
        // For now, just save to file for testing
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let printFile = documentsPath.appendingPathComponent("print_data_\(Date().timeIntervalSince1970).prn")
        
        do {
            try printData.write(to: printFile)
            print("📄 Print data saved to: \(printFile.path)")
            return true
        } catch {
            print("❌ Failed to save print data: \(error)")
            return false
        }
    }
    
    // MARK: - Connect to Printer
    func connectToPrinter() async -> Bool {
        // Simulate connection
        try? await Task.sleep(nanoseconds: 1_000_000_000) // 1 second
        
        await MainActor.run {
            isConnected = true
            lastError = nil
        }
        
        return true
    }
    
    // MARK: - Disconnect from Printer
    func disconnectFromPrinter() {
        Task { @MainActor in
            isConnected = false
            lastError = nil
        }
    }
} 