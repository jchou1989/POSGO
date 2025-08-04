import SwiftUI

struct ModifierAdminView: View {
    @StateObject private var viewModel = ModifierAdminViewModel()
    @State private var showError = false
    
    var body: some View {
        NavigationStack {
            List {
                // Sizes Section
                Section(header: Text("Sizes")) {
                    ForEach(viewModel.sizes) { size in
                        HStack {
                            Text(size.label)
                            Spacer()
                            Text(size.formattedPrice)
                            Button(action: {
                                viewModel.editingSize = size
                            }) {
                                Image(systemName: "pencil")
                            }
                            .buttonStyle(.borderless)
                            Button(action: {
                                Task {
                                    do {
                                        try await viewModel.deleteSize(id: size.id)
                                    } catch {
                                        viewModel.errorMessage = error.localizedDescription
                                        showError = true
                                    }
                                }
                            }) {
                                Image(systemName: "trash")
                                    .foregroundColor(.red)
                            }
                            .buttonStyle(.borderless)
                        }
                    }
                    
                    HStack {
                        TextField("Label", text: $viewModel.newSizeLabel)
                        TextField("Price", text: $viewModel.newSizePrice)
                            .keyboardType(.decimalPad)
                        Button("Add") {
                            Task {
                                do {
                                    try await viewModel.addSize()
                                } catch {
                                    viewModel.errorMessage = error.localizedDescription
                                    showError = true
                                }
                            }
                        }
                        .disabled(viewModel.newSizeLabel.isEmpty || viewModel.newSizePrice.isEmpty)
                    }
                }
                
                // Toppings Section
                Section(header: Text("Toppings")) {
                    ForEach(viewModel.toppings) { topping in
                        HStack {
                            Text(topping.label)
                            Spacer()
                            Text(topping.formattedPrice)
                            Button(action: {
                                viewModel.editingTopping = topping
                            }) {
                                Image(systemName: "pencil")
                            }
                            .buttonStyle(.borderless)
                            Button(action: {
                                Task {
                                    do {
                                        try await viewModel.deleteTopping(id: topping.id)
                                    } catch {
                                        viewModel.errorMessage = error.localizedDescription
                                        showError = true
                                    }
                                }
                            }) {
                                Image(systemName: "trash")
                                    .foregroundColor(.red)
                            }
                            .buttonStyle(.borderless)
                        }
                    }
                    
                    HStack {
                        TextField("Label", text: $viewModel.newToppingLabel)
                        TextField("Price", text: $viewModel.newToppingPrice)
                            .keyboardType(.decimalPad)
                        Button("Add") {
                            Task {
                                do {
                                    try await viewModel.addTopping()
                                } catch {
                                    viewModel.errorMessage = error.localizedDescription
                                    showError = true
                                }
                            }
                        }
                        .disabled(viewModel.newToppingLabel.isEmpty || viewModel.newToppingPrice.isEmpty)
                    }
                }
            }
            .navigationTitle("🛠️ Modifiers")
            .alert("Error", isPresented: $showError) {
                Button("OK") { }
            } message: {
                Text(viewModel.errorMessage)
            }
            .sheet(item: $viewModel.editingSize) { size in
                ModifierEditSheet(
                    label: size.label,
                    price: size.price,
                    onSave: { newLabel, newPrice in
                        Task {
                            do {
                                try await viewModel.updateSize(
                                    id: size.id,
                                    label: newLabel,
                                    price: newPrice
                                )
                            } catch {
                                viewModel.errorMessage = error.localizedDescription
                                showError = true
                            }
                        }
                    }
                )
            }
            .sheet(item: $viewModel.editingTopping) { topping in
                ModifierEditSheet(
                    label: topping.label,
                    price: topping.price,
                    onSave: { newLabel, newPrice in
                        Task {
                            do {
                                try await viewModel.updateTopping(
                                    id: topping.id,
                                    label: newLabel,
                                    price: newPrice
                                )
                            } catch {
                                viewModel.errorMessage = error.localizedDescription
                                showError = true
                            }
                        }
                    }
                )
            }
            .task {
                await viewModel.loadModifiers()
            }
        }
    }
}

// MARK: - Preview
#Preview {
    ModifierAdminView()
}
