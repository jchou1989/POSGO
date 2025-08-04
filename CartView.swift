import SwiftUI

struct CartView: View {
    @StateObject private var viewModel = CartViewModel()
    @Binding var cart: [OrderItem]
    @Environment(\.dismiss) private var dismiss
    
    private var subtotal: Double {
        cart.reduce(0) { $0 + $1.price }
    }
    
    private var tax: Double {
        subtotal * 0.08875 // NYC tax rate
    }
    
    private var total: Double {
        subtotal + tax
    }
    
    var body: some View {
        NavigationView {
            HStack(spacing: 0) {
                // Left Panel - Cart Items
                VStack(spacing: 0) {
                    // Header
                    VStack(spacing: 8) {
                        Text("Your Order")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.teaBrown)
                        
                        Text("\(cart.count) item\(cart.count == 1 ? "" : "s")")
                            .font(.subheadline)
                            .foregroundColor(.teaBrown.opacity(0.6))
                    }
                    .padding(.top, 24)
                    .padding(.bottom, 16)
                    
                    if cart.isEmpty {
                        // Empty State
                        Spacer()
                        EmptyCartView()
                        Spacer()
                    } else {
                        // Cart Items
                        ScrollView {
                            LazyVStack(spacing: 16) {
                                ForEach(cart.indices, id: \.self) { index in
                                    CartItemCard(item: cart[index]) {
                                        cart.remove(at: index)
                                    }
                                }
                            }
                            .padding(.horizontal, 24)
                            .padding(.vertical, 16)
                        }
                    }
                }
                .frame(maxWidth: 480)
                .background(Color.teaCream)
                
                // Right Panel - Order Summary & Checkout
                VStack(spacing: 0) {
                    // Order Summary Header
                    VStack(spacing: 16) {
                        Text("Order Summary")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(.teaBrown)
                        
                        Divider()
                            .background(Color.teaBrown.opacity(0.2))
                    }
                    .padding(.top, 24)
                    .padding(.horizontal, 32)
                    
                    if !cart.isEmpty {
                        // Summary Details
                        VStack(spacing: 20) {
                            VStack(spacing: 12) {
                                HStack {
                                    Text("Subtotal")
                                        .foregroundColor(.teaBrown.opacity(0.7))
                                    Spacer()
                                    Text("$\(String(format: "%.2f", subtotal))")
                                        .foregroundColor(.teaBrown)
                                }
                                
                                HStack {
                                    Text("Tax")
                                        .foregroundColor(.teaBrown.opacity(0.7))
                                    Spacer()
                                    Text("$\(String(format: "%.2f", tax))")
                                        .foregroundColor(.teaBrown)
                                }
                                
                                Divider()
                                    .background(Color.teaBrown.opacity(0.2))
                                
                                HStack {
                                    Text("Total")
                                        .font(.system(size: 18, weight: .bold))
                                        .foregroundColor(.teaBrown)
                                    Spacer()
                                    Text("$\(String(format: "%.2f", total))")
                                        .font(.system(size: 20, weight: .bold))
                                        .foregroundColor(.teaGold)
                                }
                            }
                            .font(.system(size: 16))
                            
                            // Payment Method Selection
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Payment Method")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.teaBrown)
                                
                                HStack(spacing: 12) {
                                    PaymentMethodCard(icon: "creditcard.fill", title: "Card", isSelected: true) { }
                                    PaymentMethodCard(icon: "dollarsign.circle.fill", title: "Cash", isSelected: false) { }
                                }
                            }
                            
                            // Customer Info
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Customer Information")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.teaBrown)
                                
                                VStack(spacing: 8) {
                                    TextField("Customer Name (Optional)", text: .constant(""))
                                        .textFieldStyle(CustomTextFieldStyle())
                                    
                                    TextField("Phone Number (Optional)", text: .constant(""))
                                        .textFieldStyle(CustomTextFieldStyle())
                                }
                            }
                        }
                        .padding(.horizontal, 32)
                        .padding(.top, 24)
                        
                        Spacer()
                        
                        // Action Buttons
                        VStack(spacing: 16) {
                            Button("Process Payment") {
                                processOrder()
                            }
                            .buttonStyle(PrimaryActionButtonStyle())
                            .disabled(viewModel.isSubmitting)
                            
                            Button("Clear Cart") {
                                cart.removeAll()
                            }
                            .buttonStyle(SecondaryActionButtonStyle())
                        }
                        .padding(.horizontal, 32)
                        .padding(.bottom, 32)
                    } else {
                        Spacer()
                        
                        VStack(spacing: 16) {
                            Image(systemName: "cart.badge.plus")
                                .font(.system(size: 48))
                                .foregroundColor(.teaBrown.opacity(0.3))
                            
                            Text("Add items to continue")
                                .font(.headline)
                                .foregroundColor(.teaBrown.opacity(0.6))
                        }
                        
                        Spacer()
                    }
                }
                .background(Color.softWhite)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Continue Shopping") {
                        dismiss()
                    }
                    .foregroundColor(.teaBrown)
                }
            }
        }
        .alert("Order Submitted!", isPresented: $viewModel.showSuccess) {
            Button("OK") {
                cart.removeAll()
                dismiss()
            }
        } message: {
            Text("Your order has been successfully processed!")
        }
        .alert("Error", isPresented: $viewModel.showError) {
            Button("OK") { }
        } message: {
            Text(viewModel.errorMessage)
        }
    }
    
    private func processOrder() {
        Task {
            await viewModel.submitOrder(cart: cart)
        }
    }
}

// MARK: - Cart Item Card
struct CartItemCard: View {
    let item: OrderItem
    let onRemove: () -> Void
    
    var body: some View {
        HStack(spacing: 16) {
            // Item Image
            RoundedRectangle(cornerRadius: 12)
                .fill(LinearGradient(
                    colors: [Color.teaGold.opacity(0.2), Color.teaBrown.opacity(0.1)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ))
                .frame(width: 80, height: 80)
                .overlay(
                    Image(systemName: "cup.and.saucer.fill")
                        .font(.title2)
                        .foregroundColor(.teaBrown.opacity(0.5))
                )
            
            // Item Details
            VStack(alignment: .leading, spacing: 6) {
                Text(item.name)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.teaBrown)
                    .lineLimit(2)
                
                if !item.size.isEmpty {
                    Label(item.size, systemImage: "cup.and.saucer")
                        .font(.caption)
                        .foregroundColor(.teaBrown.opacity(0.6))
                }
                
                HStack(spacing: 16) {
                    if !item.sugar.isEmpty {
                        Label(item.sugar, systemImage: "cube.fill")
                            .font(.caption)
                            .foregroundColor(.teaBrown.opacity(0.6))
                    }
                    
                    if !item.ice.isEmpty {
                        Label(item.ice, systemImage: "snowflake")
                            .font(.caption)
                            .foregroundColor(.teaBrown.opacity(0.6))
                    }
                }
                
                if !item.toppings.isEmpty {
                    Text("+ \(item.toppings.joined(separator: ", "))")
                        .font(.caption)
                        .foregroundColor(.teaGold)
                        .lineLimit(2)
                }
            }
            
            Spacer()
            
            // Price and Remove
            VStack(spacing: 8) {
                Text(item.formattedPrice)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.teaGold)
                
                Button(action: onRemove) {
                    Image(systemName: "trash.fill")
                        .font(.system(size: 14))
                        .foregroundColor(.red.opacity(0.7))
                }
            }
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
}

// MARK: - Payment Method Card
struct PaymentMethodCard: View {
    let icon: String
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(isSelected ? .white : .teaBrown)
                
                Text(title)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(isSelected ? .white : .teaBrown)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(isSelected ? Color.teaGold : Color.white)
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(isSelected ? Color.clear : Color.teaBrown.opacity(0.2), lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Custom Text Field Style
struct CustomTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(Color.white)
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.teaBrown.opacity(0.2), lineWidth: 1)
            )
    }
}

// MARK: - Button Styles
struct PrimaryActionButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 18, weight: .semibold))
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(Color.teaGold)
            .cornerRadius(12)
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

struct SecondaryActionButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 16, weight: .medium))
            .foregroundColor(.teaBrown)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(Color.white)
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.teaBrown.opacity(0.3), lineWidth: 1)
            )
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

// MARK: - Empty Cart View
private struct EmptyCartView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "cart.badge.questionmark")
                .font(.system(size: 64))
                .foregroundColor(.teaBrown.opacity(0.3))
            
            VStack(spacing: 8) {
                Text("Your Cart is Empty")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.teaBrown)
                
                Text("Add some delicious drinks to get started")
                    .font(.subheadline)
                    .foregroundColor(.teaBrown.opacity(0.6))
                    .multilineTextAlignment(.center)
            }
        }
        .padding(40)
    }
}

#Preview {
    CartView(
        cart: .constant([
            OrderItem(
                id: UUID(),
                name: "Premium Jasmine Tea Latte",
                size: "Large",
                sugar: "50%",
                ice: "Normal Ice",
                toppings: ["Pearls", "Brown Sugar"],
                sizePrice: 1.50,
                toppingPrices: [0.75, 0.50],
                price: 6.25
            ),
            OrderItem(
                id: UUID(),
                name: "Classic Milk Tea",
                size: "Medium",
                sugar: "75%",
                ice: "Less Ice",
                toppings: ["Grass Jelly"],
                sizePrice: 0.50,
                toppingPrices: [0.50],
                price: 4.50
            )
        ])
    )
}
