import SwiftUI

struct CartView: View {
    @StateObject private var viewModel = CartViewModel()
    @Binding var cart: [OrderItem]
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        List {
            // Cart Items Section
            Section {
                ForEach(cart) { item in
                    OrderItemRow(item: item)
                }
                .onDelete { indexSet in
                    cart.remove(atOffsets: indexSet)
                }
            }
            
            // Total Section
            if !cart.isEmpty {
                Section {
                    HStack {
                        Spacer()
                        VStack(alignment: .center) {
                            Text("Subtotal")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            Text(viewModel.formattedTotal(from: cart))
                                .font(.title2.bold())
                        }
                        Spacer()
                    }
                    .padding(.vertical, 8)
                }
            }
            
            // Empty State
            if cart.isEmpty {
                EmptyCartView()
            }
        }
        .navigationTitle("Your Order")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            // Edit Button
            ToolbarItem(placement: .navigationBarLeading) {
                if !cart.isEmpty {
                    EditButton()
                }
            }
            
            // Submit Button
            ToolbarItem(placement: .primaryAction) {
                if !cart.isEmpty {
                    Button(action: submitOrder) {
                        Label("Submit", systemImage: "checkmark.circle.fill")
                    }
                    .disabled(viewModel.isSubmitting)
                }
            }
        }
        .alert("Order Submitted!", isPresented: $viewModel.showSuccess) {
            Button("OK", role: .cancel) { }
        }
        .alert("Error", isPresented: $viewModel.showError) {
            Button("OK") { }
        } message: {
            Text(viewModel.errorMessage)
        }
    }
    
    private func submitOrder() {
        Task {
            if await viewModel.submitOrder(cart: cart) {
                cart.removeAll()
                dismiss()
            }
        }
    }
}

// MARK: - Subviews
private struct OrderItemRow: View {
    let item: OrderItem
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(item.name)
                    .font(.headline)
                Spacer()
                Text(item.qarFormattedPrice)
                    .font(.subheadline.bold())
            }
            
            if !item.size.isEmpty {
                HStack(spacing: 4) {
                    Image(systemName: "cup.and.saucer")
                    Text(item.size)
                }
                .font(.caption)
                .foregroundColor(.secondary)
            }
            
            if !item.selectedToppings.isEmpty {
                HStack(spacing: 4) {
                    Image(systemName: "plus.app")
                    Text(item.selectedToppings.joined(separator: ", "))
                }
                .font(.caption)
                .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 8)
    }
}

private struct EmptyCartView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "cart.badge.questionmark")
                .font(.system(size: 48))
                .foregroundColor(.gray.opacity(0.5))
            
            VStack(spacing: 4) {
                Text("Your Cart is Empty")
                    .font(.title3.bold())
                Text("Add items from the menu to get started")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(40)
        .listRowSeparator(.hidden)
    }
}

// MARK: - Preview
#Preview {
    NavigationStack {
        CartView(
            cart: .constant([
                OrderItem(
                    name: "Iced Coffee",
                    size: "Large",
                    sugarLevel: "50%",
                    iceLevel: "Regular",
                    selectedToppings: ["Whipped Cream", "Caramel"],
                    sizePrice: 1.50,
                    toppingPrices: [0.50, 0.75],
                    price: 4.75
                )
            ])
        )
    }
}
