import SwiftUI

struct PaymentView: View {
    let cart: [OrderItem]
    let onPaymentComplete: (Bool) -> Void
    
    @EnvironmentObject var paymentManager: PaymentManager
    @Environment(\.dismiss) private var dismiss
    @State private var selectedPaymentMethod: PaymentMethod = .card
    @State private var cashAmount: String = ""
    @State private var showingReceipt = false
    @State private var currentTransaction: PaymentTransaction?
    
    private var total: Double {
        cart.reduce(0) { $0 + $1.price }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header
                PaymentHeaderView(total: total)
                
                // Payment Methods
                PaymentMethodsView(
                    selectedMethod: $selectedPaymentMethod,
                    total: total
                )
                
                // Payment Processing
                if selectedPaymentMethod == .cash {
                    CashPaymentView(
                        total: total,
                        cashAmount: $cashAmount
                    )
                }
                
                Spacer()
                
                // Action Buttons
                PaymentActionButtons(
                    selectedMethod: selectedPaymentMethod,
                    total: total,
                    cashAmount: cashAmount,
                    isProcessing: paymentManager.isProcessing,
                    onProcessPayment: processPayment,
                    onCancel: { dismiss() }
                )
            }
            .navigationTitle("Payment")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
        .sheet(isPresented: $showingReceipt) {
            if let transaction = currentTransaction {
                ReceiptView(
                    transaction: transaction,
                    cart: cart,
                    onDismiss: {
                        showingReceipt = false
                        dismiss()
                    }
                )
            }
        }
    }
    
    private func processPayment() {
        Task {
            let result = await paymentManager.processPayment(
                amount: total,
                method: selectedPaymentMethod
            )
            
            switch result {
            case .success(let transaction):
                currentTransaction = transaction
                showingReceipt = true
                onPaymentComplete(true)
            case .failure(let error):
                // Handle payment failure
                print("Payment failed: \(error)")
                onPaymentComplete(false)
            }
        }
    }
}

// MARK: - Payment Header
struct PaymentHeaderView: View {
    let total: Double
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Total Amount")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    Text("QR \(String(format: "%.2f", total))")
                        .font(.largeTitle.bold())
                        .foregroundColor(.primary)
                }
                Spacer()
                
                Image(systemName: "creditcard.fill")
                    .font(.system(size: 40))
                    .foregroundColor(.blue)
            }
            
            Divider()
        }
        .padding()
        .background(Color(.systemBackground))
    }
}

// MARK: - Payment Methods
struct PaymentMethodsView: View {
    @Binding var selectedMethod: PaymentMethod
    let total: Double
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Payment Method")
                .font(.title2.bold())
                .padding(.horizontal)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
                ForEach(PaymentMethod.allCases, id: \.self) { method in
                    PaymentMethodCard(
                        method: method,
                        isSelected: selectedMethod == method,
                        onTap: { selectedMethod = method }
                    )
                }
            }
            .padding(.horizontal)
        }
    }
}

struct PaymentMethodCard: View {
    let method: PaymentMethod
    let isSelected: Bool
    let onTap: () -> Void
    
    private var iconName: String {
        switch method {
        case .cash: return "banknote.fill"
        case .card: return "creditcard.fill"
        case .mobile: return "iphone"
        case .giftCard: return "gift.fill"
        case .qlub: return "q.square.fill"
        }
    }
    
    private var color: Color {
        switch method {
        case .cash: return .green
        case .card: return .blue
        case .mobile: return .purple
        case .giftCard: return .orange
        case .qlub: return .red
        }
    }
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 12) {
                Image(systemName: iconName)
                    .font(.system(size: 30))
                    .foregroundColor(isSelected ? .white : color)
                
                Text(method.rawValue)
                    .font(.headline)
                    .foregroundColor(isSelected ? .white : .primary)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? color : Color(.systemGray6))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? color : Color.clear, lineWidth: 2)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Cash Payment
struct CashPaymentView: View {
    let total: Double
    @Binding var cashAmount: String
    
    private var change: Double {
        guard let amount = Double(cashAmount) else { return 0 }
        return amount - total
    }
    
    var body: some View {
        VStack(spacing: 20) {
            VStack(spacing: 12) {
                Text("Cash Amount")
                    .font(.headline)
                
                TextField("Enter amount", text: $cashAmount)
                    .keyboardType(.decimalPad)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .font(.title2)
                    .multilineTextAlignment(.center)
            }
            
            if !cashAmount.isEmpty, let amount = Double(cashAmount) {
                VStack(spacing: 8) {
                    HStack {
                        Text("Total:")
                        Spacer()
                        Text("QR \(String(format: "%.2f", total))")
                    }
                    
                    HStack {
                        Text("Cash:")
                        Spacer()
                        Text("QR \(String(format: "%.2f", amount))")
                    }
                    
                    Divider()
                    
                    HStack {
                        Text("Change:")
                            .font(.headline)
                        Spacer()
                        Text("QR \(String(format: "%.2f", change))")
                            .font(.headline)
                            .foregroundColor(change >= 0 ? .green : .red)
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(8)
            }
        }
        .padding()
    }
}

// MARK: - Action Buttons
struct PaymentActionButtons: View {
    let selectedMethod: PaymentMethod
    let total: Double
    let cashAmount: String
    let isProcessing: Bool
    let onProcessPayment: () -> Void
    let onCancel: () -> Void
    
    private var canProcessPayment: Bool {
        if selectedMethod == .cash {
            guard let amount = Double(cashAmount) else { return false }
            return amount >= total
        }
        return true
    }
    
    var body: some View {
        VStack(spacing: 12) {
            Button(action: onProcessPayment) {
                HStack {
                    if isProcessing {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .scaleEffect(0.8)
                    } else {
                        Image(systemName: "checkmark.circle.fill")
                    }
                    Text(isProcessing ? "Processing..." : "Complete Payment")
                        .font(.headline)
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(canProcessPayment ? Color.blue : Color.gray)
                .cornerRadius(12)
            }
            .disabled(!canProcessPayment || isProcessing)
            
            Button(action: onCancel) {
                Text("Cancel")
                    .font(.headline)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(.systemGray5))
                    .cornerRadius(12)
            }
            .disabled(isProcessing)
        }
        .padding()
        .background(Color(.systemBackground))
    }
}

// MARK: - Receipt View with QR Code
struct ReceiptView: View {
    let transaction: PaymentTransaction
    let cart: [OrderItem]
    let onDismiss: () -> Void
    
    @State private var qrCodeImages: [UIImage] = []
    @State private var isLoadingQR = false
    @StateObject private var thermalPrinter = ThermalPrinterService.shared
    
    private var total: Double {
        cart.reduce(0) { $0 + $1.price }
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Receipt Header
                    VStack(spacing: 8) {
                        Text("POS GO")
                            .font(.title.bold())
                        Text("Receipt")
                            .font(.headline)
                        Text(transaction.timestamp.formatted(date: .abbreviated, time: .shortened))
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Divider()
                    
                    // Items with QR Codes
                    VStack(spacing: 16) {
                        ForEach(Array(cart.enumerated()), id: \.element.id) { index, item in
                            VStack(spacing: 8) {
                                HStack {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(item.name)
                                            .font(.subheadline.bold())
                                        
                                        Text("Size: \(item.size)")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                        
                                        if let sugarLevel = item.sugarLevel {
                                            Text("Sugar: \(sugarLevel)")
                                                .font(.caption)
                                                .foregroundColor(.secondary)
                                        }
                                        
                                        if let iceLevel = item.iceLevel {
                                            Text("Ice: \(iceLevel)")
                                                .font(.caption)
                                                .foregroundColor(.secondary)
                                        }
                                        
                                        if !item.selectedToppings.isEmpty {
                                            Text("Toppings: \(item.selectedToppings.joined(separator: ", "))")
                                                .font(.caption)
                                                .foregroundColor(.secondary)
                                        }
                                    }
                                    
                                    Spacer()
                                    
                                    Text(item.qarFormattedPrice)
                                        .font(.subheadline.bold())
                                }
                                
                                // QR Code for beverage machine
                                if index < qrCodeImages.count {
                                    VStack(spacing: 4) {
                                        Image(uiImage: qrCodeImages[index])
                                            .resizable()
                                            .frame(width: 120, height: 120)
                                            .cornerRadius(8)
                                        
                                        Text("Scan for Beverage Machine")
                                            .font(.caption2)
                                            .foregroundColor(.secondary)
                                    }
                                } else if isLoadingQR {
                                    ProgressView()
                                        .scaleEffect(0.8)
                                }
                            }
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(12)
                        }
                    }
                    
                    Divider()
                    
                    // Total
                    HStack {
                        Text("Total")
                            .font(.headline.bold())
                        Spacer()
                        Text(NumberFormatter.qarFormatter.string(from: NSNumber(value: total)) ?? "QR \(String(format: "%.2f", total))")
                            .font(.headline.bold())
                    }
                    
                    // Payment Info
                    VStack(spacing: 8) {
                        HStack {
                            Text("Payment Method:")
                            Spacer()
                            Text(transaction.method.rawValue)
                        }
                        
                        HStack {
                            Text("Transaction ID:")
                            Spacer()
                            Text(transaction.id.uuidString.prefix(8))
                                .font(.caption)
                        }
                        
                        HStack {
                            Text("Status:")
                            Spacer()
                            Text(transaction.status.displayName)
                                .foregroundColor(transaction.status.color)
                        }
                    }
                    .font(.caption)
                    .foregroundColor(.secondary)
                    
                    // Action Buttons
                    VStack(spacing: 12) {
                        Button(action: {
                            Task {
                                let order = Order(
                                    items: cart,
                                    total: total,
                                    paymentMethod: transaction.method,
                                    paymentStatus: transaction.status
                                )
                                let success = await thermalPrinter.printMultipleQRLabels(for: order)
                                if !success {
                                    print("⚠️ Failed to print QR code labels")
                                }
                            }
                        }) {
                            HStack {
                                Image(systemName: "printer")
                                Text(thermalPrinter.isPrinting ? "Printing..." : "Print Labels")
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(thermalPrinter.isPrinting ? Color.gray : Color.blue)
                            .cornerRadius(12)
                        }
                        .disabled(thermalPrinter.isPrinting)
                        
                        Button(action: shareReceipt) {
                            HStack {
                                Image(systemName: "square.and.arrow.up")
                                Text("Share Receipt")
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.green)
                            .cornerRadius(12)
                        }
                        
                        Button(action: onDismiss) {
                            Text("Done")
                                .font(.headline)
                                .foregroundColor(.secondary)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color(.systemGray5))
                                .cornerRadius(12)
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Receipt")
            .navigationBarTitleDisplayMode(.inline)
        }
        .onAppear {
            generateQRCodes()
        }
    }
    
    private func generateQRCodes() {
        isLoadingQR = true
        
        DispatchQueue.global(qos: .userInitiated).async {
            var qrImages: [UIImage] = []
            
            for item in cart {
                let config = QRCodeGenerator.createBeverageConfig(
                    from: item,
                    orderId: transaction.id.uuidString,
                    machineId: "BEV001"
                )
                
                if let qrCode = QRCodeGenerator.generateQRCode(for: config) {
                    qrImages.append(qrCode)
                }
            }
            
            DispatchQueue.main.async {
                self.qrCodeImages = qrImages
                self.isLoadingQR = false
            }
        }
    }
    
    private func printReceipt() {
        // Generate receipt text
        let order = Order(
            items: cart,
            total: total,
            paymentMethod: transaction.method,
            paymentStatus: transaction.status
        )
        
        let receiptText = QRCodeGenerator.generateReceiptWithQRCode(order: order, qrCodeImage: nil)
        print("📄 Printing receipt:\n\(receiptText)")
        
        // In a real app, you would send this to a printer
        // For now, we'll just log it
    }
    
    private func shareReceipt() {
        // Generate receipt text for sharing
        let order = Order(
            items: cart,
            total: total,
            paymentMethod: transaction.method,
            paymentStatus: transaction.status
        )
        
        let receiptText = QRCodeGenerator.generateReceiptWithQRCode(order: order, qrCodeImage: nil)
        
        // In a real app, you would share this text
        print("📤 Sharing receipt:\n\(receiptText)")
    }
}

#Preview {
    PaymentView(
        cart: [
            OrderItem(
                name: "Iced Coffee",
                size: "Large",
                sugarLevel: "50%",
                iceLevel: "Regular",
                selectedToppings: ["Whipped Cream"],
                sizePrice: 1.50,
                toppingPrices: [0.50],
                price: 4.25
            )
        ],
        onPaymentComplete: { _ in }
    )
    .environmentObject(PaymentManager())
}
