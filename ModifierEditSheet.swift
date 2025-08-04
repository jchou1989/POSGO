import SwiftUI

struct ModifierEditSheet: View {
    @Environment(\.dismiss) var dismiss
    @State var label: String
    @State var price: Double
    @State private var showError = false
    
    var onSave: (String, Double) throws -> Void
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Label")) {
                    TextField("Label", text: $label)
                }
                Section(header: Text("Price")) {
                    TextField("Price", value: $price, format: .number)
                        .keyboardType(.decimalPad)
                }
            }
            .navigationTitle("Edit Modifier")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        do {
                            try onSave(label, price)
                            dismiss()
                        } catch {
                            showError = true
                        }
                    }
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
            .alert("Error", isPresented: $showError) {
                Button("OK") { }
            }
        }
    }
}
