import SwiftUI

struct MenuItemEditSheet: View {
    @Binding var item: MenuItem
    @Binding var isPresented: Bool
    @Binding var categories: [MenuCategory]
    var onSave: () -> Void

    @State private var selectedCategoryId: UUID = UUID()

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Item Details")) {
                    TextField("Name", text: $item.name)
                    TextField("Price", value: $item.price, formatter: NumberFormatter())
                        .keyboardType(.decimalPad)
                }

                Section(header: Text("Category")) {
                    Picker("Category", selection: $selectedCategoryId) {
                        ForEach(categories) { category in
                            Text(category.name).tag(category.id)
                        }
                    }
                }
            }
            .navigationTitle("Edit Item")
            .onAppear {
                selectedCategoryId = item.category_id
            }
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        item.category_id = selectedCategoryId
                        onSave()
                        isPresented = false
                    }
                }

                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        isPresented = false
                    }
                }
            }
        }
    }
}
