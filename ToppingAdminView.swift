import SwiftUI

struct ToppingAdminView: View {
    @State private var toppings: [ToppingOption] = []
    @State private var newLabel: String = ""
    @State private var newPrice: String = ""
    @State private var isLoading = false
    @State private var showError = false
    @State private var errorMessage = ""

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Existing Toppings")) {
                    if toppings.isEmpty {
                        Text("No toppings found.")
                    } else {
                        ForEach(toppings) { topping in
                            HStack {
                                VStack(alignment: .leading) {
                                    Text(topping.label)
                                    Text("QR \(String(format: "%.2f", topping.price))")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                }
                                Spacer()
                                Button("Delete", role: .destructive) {
                                    Task {
                                        await deleteTopping(topping.id)
                                    }
                                }
                            }
                        }
                    }
                }

                Section(header: Text("Add New Topping")) {
                    TextField("Label", text: $newLabel)
                    TextField("Price", text: $newPrice)
                        .keyboardType(.decimalPad)
                    Button("Add Topping") {
                        Task {
                            await addNewTopping()
                        }
                    }
                    .disabled(newLabel.isEmpty || Double(newPrice) == nil)
                }
            }
            .navigationTitle("Topping Admin")
            .alert("Error", isPresented: $showError) {
                Button("OK") { }
            } message: {
                Text(errorMessage)
            }
            .task {
                await loadToppings()
            }
            .overlay {
                if isLoading {
                    ProgressView()
                }
            }
        }
    }

    // MARK: - Load
    func loadToppings() async {
        isLoading = true
        do {
            toppings = try await SupabaseService.fetchToppingOptions()
        } catch {
            errorMessage = error.localizedDescription
            showError = true
        }
        isLoading = false
    }

    // MARK: - Add
    func addNewTopping() async {
        guard let price = Double(newPrice) else {
            errorMessage = "Invalid price format"
            showError = true
            return
        }
        
        isLoading = true
        do {
            try await SupabaseService.addToppingOption(label: newLabel, price: price)
            newLabel = ""
            newPrice = ""
            await loadToppings()
        } catch {
            errorMessage = error.localizedDescription
            showError = true
        }
        isLoading = false
    }

    // MARK: - Delete
    func deleteTopping(_ id: UUID) async {
        isLoading = true
        do {
            try await SupabaseService.deleteToppingOption(id: id)
            await loadToppings()
        } catch {
            errorMessage = error.localizedDescription
            showError = true
        }
        isLoading = false
    }
}
