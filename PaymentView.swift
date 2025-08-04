import SwiftUI

struct PaymentView: View {
    let orderItems: [OrderItem]
    let subtotal: Double
    let tax: Double
    let total: Double
    let onComplete: (PaymentMethod) -> Void
    let onCancel: () -> Void
    
    @State private var selectedPaymentMethod: PaymentMethod?
    @State private var cashReceived: String = ""
    @State private var showingCashPad = false
    
    enum PaymentMethod: String, CaseIterable {
        case cash = "Cash"
        case card = "Credit/Debit"
        case applePay = "Apple Pay"
        case wechat = "WeChat Pay"
        case alipay = "Alipay"
        
        var icon: String {
            switch self {
            case .cash: return "dollarsign.circle.fill"
            case .card: return "creditcard.fill"
            case .applePay: return "applelogo"
            case .wechat: return "message.fill"
            case .alipay: return "ant.fill"
            }
        }
    }
    
    var body: some View {
        GeometryReader { geometry in
            HStack(spacing: 0) {
                // Left side - Order Summary
                orderSummarySection
                    .frame(width: geometry.size.width * 0.4)
                    .background(ChageeTheme.Colors.surface)
                
                // Right side - Payment Options
                paymentOptionsSection
                    .frame(width: geometry.size.width * 0.6)
                    .background(ChageeTheme.Colors.background)
            }
        }
        .sheet(isPresented: $showingCashPad) {
            CashPaymentView(
                total: total,
                onComplete: { _ in
                    showingCashPad = false
                    onComplete(.cash)
                },
                onCancel: { showingCashPad = false }
            )
        }
    }
    
    // MARK: - Order Summary
    private var orderSummarySection: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("Order Summary")
                    .font(ChageeTheme.Typography.headline)
                    .foregroundColor(ChageeTheme.Colors.text)
                
                Spacer()
                
                Text("#\(String(format: "%04d", Int.random(in: 1...9999)))")
                    .font(ChageeTheme.Typography.callout)
                    .foregroundColor(ChageeTheme.Colors.textSecondary)
            }
            .padding(ChageeTheme.Spacing.lg)
            
            Divider()
                .background(ChageeTheme.Colors.divider)
            
            // Items list
            ScrollView {
                VStack(spacing: ChageeTheme.Spacing.sm) {
                    ForEach(orderItems) { item in
                        PaymentItemRow(item: item)
                    }
                }
                .padding(ChageeTheme.Spacing.lg)
            }
            
            Divider()
                .background(ChageeTheme.Colors.divider)
            
            // Totals
            VStack(spacing: ChageeTheme.Spacing.md) {
                HStack {
                    Text("Subtotal")
                        .font(ChageeTheme.Typography.body)
                        .foregroundColor(ChageeTheme.Colors.textSecondary)
                    Spacer()
                    Text(formatCurrency(subtotal))
                        .font(ChageeTheme.Typography.body)
                        .foregroundColor(ChageeTheme.Colors.text)
                }
                
                HStack {
                    Text("Tax")
                        .font(ChageeTheme.Typography.body)
                        .foregroundColor(ChageeTheme.Colors.textSecondary)
                    Spacer()
                    Text(formatCurrency(tax))
                        .font(ChageeTheme.Typography.body)
                        .foregroundColor(ChageeTheme.Colors.text)
                }
                
                Divider()
                    .background(ChageeTheme.Colors.divider)
                
                HStack {
                    Text("Total")
                        .font(ChageeTheme.Typography.title)
                        .foregroundColor(ChageeTheme.Colors.text)
                    Spacer()
                    Text(formatCurrency(total))
                        .font(ChageeTheme.Typography.price)
                        .foregroundColor(ChageeTheme.Colors.primaryGreen)
                }
            }
            .padding(ChageeTheme.Spacing.lg)
            .background(ChageeTheme.Colors.cream)
        }
    }
    
    // MARK: - Payment Options
    private var paymentOptionsSection: some View {
        VStack(spacing: ChageeTheme.Spacing.lg) {
            // Header
            HStack {
                Text("Select Payment Method")
                    .font(ChageeTheme.Typography.title)
                    .foregroundColor(ChageeTheme.Colors.text)
                
                Spacer()
                
                Button(action: onCancel) {
                    Text("Cancel")
                        .font(ChageeTheme.Typography.callout)
                        .foregroundColor(ChageeTheme.Colors.error)
                }
            }
            .padding(.horizontal, ChageeTheme.Spacing.xl)
            .padding(.top, ChageeTheme.Spacing.xl)
            
            // Payment method grid
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: ChageeTheme.Spacing.lg) {
                ForEach(PaymentMethod.allCases, id: \.self) { method in
                    PaymentMethodButton(
                        method: method,
                        isSelected: selectedPaymentMethod == method,
                        action: {
                            selectedPaymentMethod = method
                            handlePaymentSelection(method)
                        }
                    )
                }
            }
            .padding(.horizontal, ChageeTheme.Spacing.xl)
            
            Spacer()
            
            // Quick amount buttons for cash
            if selectedPaymentMethod == .cash {
                quickAmountButtons
            }
        }
    }
    
    private var quickAmountButtons: some View {
        VStack(spacing: ChageeTheme.Spacing.md) {
            Text("Quick Amount")
                .font(ChageeTheme.Typography.headline)
                .foregroundColor(ChageeTheme.Colors.text)
            
            HStack(spacing: ChageeTheme.Spacing.md) {
                ForEach([10, 20, 50, 100], id: \.self) { amount in
                    Button(action: {
                        showingCashPad = true
                    }) {
                        Text("$\(amount)")
                            .font(ChageeTheme.Typography.headline)
                            .foregroundColor(ChageeTheme.Colors.primaryGreen)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, ChageeTheme.Spacing.md)
                            .background(ChageeTheme.Colors.surface)
                            .cornerRadius(ChageeTheme.Radius.md)
                            .overlay(
                                RoundedRectangle(cornerRadius: ChageeTheme.Radius.md)
                                    .stroke(ChageeTheme.Colors.primaryGreen, lineWidth: 1.5)
                            )
                    }
                }
            }
            .padding(.horizontal, ChageeTheme.Spacing.xl)
            
            Text("Or enter custom amount")
                .font(ChageeTheme.Typography.caption)
                .foregroundColor(ChageeTheme.Colors.textSecondary)
                .onTapGesture {
                    showingCashPad = true
                }
        }
        .padding(.bottom, ChageeTheme.Spacing.xl)
    }
    
    // MARK: - Helper Methods
    private func handlePaymentSelection(_ method: PaymentMethod) {
        switch method {
        case .cash:
            showingCashPad = true
        case .card, .applePay, .wechat, .alipay:
            // In production, integrate with payment processor
            // For now, simulate processing
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                onComplete(method)
            }
        }
    }
    
    private func formatCurrency(_ amount: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        return formatter.string(from: NSNumber(value: amount)) ?? "$\(String(format: "%.2f", amount))"
    }
}

// MARK: - Supporting Views
struct PaymentItemRow: View {
    let item: OrderItem
    
    var body: some View {
        VStack(alignment: .leading, spacing: ChageeTheme.Spacing.xs) {
            HStack {
                Text(item.name)
                    .font(ChageeTheme.Typography.callout)
                    .foregroundColor(ChageeTheme.Colors.text)
                
                Spacer()
                
                Text(item.formattedPrice)
                    .font(ChageeTheme.Typography.callout)
                    .foregroundColor(ChageeTheme.Colors.text)
            }
            
            Text("\(item.size) • \(item.sugar) • \(item.ice)")
                .font(ChageeTheme.Typography.caption)
                .foregroundColor(ChageeTheme.Colors.textSecondary)
            
            if !item.toppings.isEmpty {
                Text("+ \(item.toppings.joined(separator: ", "))")
                    .font(ChageeTheme.Typography.caption)
                    .foregroundColor(ChageeTheme.Colors.textSecondary)
            }
        }
        .padding(.vertical, ChageeTheme.Spacing.sm)
    }
}

struct PaymentMethodButton: View {
    let method: PaymentView.PaymentMethod
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: ChageeTheme.Spacing.md) {
                Image(systemName: method.icon)
                    .font(.system(size: 36))
                    .foregroundColor(isSelected ? ChageeTheme.Colors.primaryGreen : ChageeTheme.Colors.textSecondary)
                
                Text(method.rawValue)
                    .font(ChageeTheme.Typography.callout)
                    .foregroundColor(isSelected ? ChageeTheme.Colors.primaryGreen : ChageeTheme.Colors.text)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 120)
            .background(isSelected ? ChageeTheme.Colors.primaryGreen.opacity(0.1) : ChageeTheme.Colors.surface)
            .cornerRadius(ChageeTheme.Radius.md)
            .overlay(
                RoundedRectangle(cornerRadius: ChageeTheme.Radius.md)
                    .stroke(isSelected ? ChageeTheme.Colors.primaryGreen : ChageeTheme.Colors.divider, lineWidth: 1.5)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Cash Payment View
struct CashPaymentView: View {
    let total: Double
    let onComplete: (Double) -> Void
    let onCancel: () -> Void
    
    @State private var amountReceived: String = ""
    @FocusState private var isInputFocused: Bool
    
    var receivedAmount: Double {
        Double(amountReceived) ?? 0
    }
    
    var change: Double {
        max(0, receivedAmount - total)
    }
    
    var body: some View {
        VStack(spacing: ChageeTheme.Spacing.xl) {
            // Header
            HStack {
                Text("Cash Payment")
                    .font(ChageeTheme.Typography.title)
                    .foregroundColor(ChageeTheme.Colors.text)
                
                Spacer()
                
                Button(action: onCancel) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title2)
                        .foregroundColor(ChageeTheme.Colors.textSecondary.opacity(0.5))
                }
            }
            
            // Amount display
            VStack(spacing: ChageeTheme.Spacing.lg) {
                VStack(spacing: ChageeTheme.Spacing.sm) {
                    Text("Total Due")
                        .font(ChageeTheme.Typography.body)
                        .foregroundColor(ChageeTheme.Colors.textSecondary)
                    
                    Text(formatCurrency(total))
                        .font(ChageeTheme.Typography.largeTitle)
                        .foregroundColor(ChageeTheme.Colors.primaryGreen)
                }
                
                Divider()
                
                VStack(spacing: ChageeTheme.Spacing.sm) {
                    Text("Amount Received")
                        .font(ChageeTheme.Typography.body)
                        .foregroundColor(ChageeTheme.Colors.textSecondary)
                    
                    TextField("0.00", text: $amountReceived)
                        .font(ChageeTheme.Typography.largeTitle)
                        .multilineTextAlignment(.center)
                        .keyboardType(.decimalPad)
                        .focused($isInputFocused)
                        .onAppear { isInputFocused = true }
                }
                
                if receivedAmount > 0 {
                    Divider()
                    
                    VStack(spacing: ChageeTheme.Spacing.sm) {
                        Text("Change")
                            .font(ChageeTheme.Typography.body)
                            .foregroundColor(ChageeTheme.Colors.textSecondary)
                        
                        Text(formatCurrency(change))
                            .font(ChageeTheme.Typography.title)
                            .foregroundColor(ChageeTheme.Colors.warning)
                    }
                }
            }
            .padding(ChageeTheme.Spacing.xl)
            .chageeCard()
            
            Spacer()
            
            // Action buttons
            HStack(spacing: ChageeTheme.Spacing.md) {
                Button("Cancel") {
                    onCancel()
                }
                .chageeSecondaryButton()
                
                Button("Complete Payment") {
                    onComplete(receivedAmount)
                }
                .chageePrimaryButton()
                .disabled(receivedAmount < total)
            }
        }
        .padding(ChageeTheme.Spacing.xl)
        .frame(width: 500, height: 600)
        .background(ChageeTheme.Colors.background)
    }
    
    private func formatCurrency(_ amount: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        return formatter.string(from: NSNumber(value: amount)) ?? "$\(String(format: "%.2f", amount))"
    }
}