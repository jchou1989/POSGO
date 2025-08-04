import SwiftUI

struct CustomizeView: View {
    @StateObject private var viewModel = CustomizeViewModel()
    @Environment(\.dismiss) private var dismiss
    let menuItem: MenuItem
    var onAddToCart: (OrderItem) -> Void
    
    var body: some View {
        NavigationStack {
            Form {
                // Size Selection
                Section(header: Text("Size")) {
                    ForEach(viewModel.sizes) { size in
                        HStack {
                            Text(size.label)
                            Spacer()
                            Text(size.formattedPrice)
                            if viewModel.selectedSize?.id == size.id {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.blue)
                            }
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            viewModel.selectedSize = size
                        }
                    }
                }
                
                // Toppings Selection
                Section(header: Text("Toppings")) {
                    ForEach(viewModel.toppings) { topping in
                        Toggle(isOn: Binding(
                            get: { viewModel.selectedToppings.contains(topping.id) },
                            set: { isOn in
                                if isOn {
                                    viewModel.selectedToppings.insert(topping.id)
                                } else {
                                    viewModel.selectedToppings.remove(topping.id)
                                }
                            }
                        )) {
                            HStack {
                                Text(topping.label)
                                Spacer()
                                Text(topping.formattedPrice)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                }
                
                // Quantity
                Section(header: Text("Quantity")) {
                    Stepper(value: $viewModel.quantity, in: 1...10) {
                        Text("\(viewModel.quantity)")
                            .frame(width: 20, alignment: .center)
                    }
                }
                
                // Total
                Section(header: Text("Total")) {
                    HStack {
                        Spacer()
                        Text(viewModel.totalPrice.formatted(.currency(code: "USD")))
                            .font(.title2.bold())
                        Spacer()
                    }
                }
            }
            .navigationTitle("Customize \(menuItem.name)")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add to Cart") {
                        let orderItem = OrderItem(
                            id: UUID(),
                            name: menuItem.name,
                            size: viewModel.selectedSize?.label ?? "",
                            sugar: "Normal",
                            ice: "Normal",
                            toppings: viewModel.selectedToppings.compactMap { id in
                                viewModel.toppings.first { $0.id == id }?.label
                            },
                            sizePrice: viewModel.selectedSize?.price ?? 0,
                            toppingPrices: viewModel.selectedToppings.compactMap { id in
                                viewModel.toppings.first { $0.id == id }?.price
                            },
                            price: viewModel.totalPrice
                        )
                        onAddToCart(orderItem)
                        dismiss()
                    }
                    .disabled(viewModel.selectedSize == nil)
                    .bold()
                }
            }
            .task {
                await viewModel.loadModifiers()
            }
            .overlay {
                if viewModel.isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color(.systemBackground).opacity(0.8))
                }
            }
        }
    }
}

// Preview Provider
struct CustomizeView_Previews: PreviewProvider {
    static var previews: some View {
        CustomizeView(
            menuItem: MenuItem(
                id: UUID(),
                name: "Iced Latte",
                price: 4.99,
                category_id: UUID()
            ),
            onAddToCart: { _ in }
        )
    }
}
