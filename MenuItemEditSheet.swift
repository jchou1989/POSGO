import SwiftUI

struct MenuItemEditorView: View {
    @Binding var selectedCategory: MenuCategory?
    @Binding var menuItems: [MenuItem]
    @Binding var editingItem: MenuItem?
    let onItemUpdated: () -> Void
    
    @Environment(\.dismiss) private var dismiss
    @State private var itemName: String = ""
    @State private var itemPrice: String = ""
    @State private var selectedCategoryId: UUID = UUID()
    @State private var isNewItem: Bool = false
    @State private var categories: [MenuCategory] = []
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Header
                VStack(spacing: 8) {
                    Text(isNewItem ? "Add Menu Item" : "Edit Menu Item")
                        .font(.title2.bold())
                    
                    Text("Enter the item details below")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.top)
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Item Name
                        VStack(alignment: .leading, spacing: 8) {
                            Text("ITEM NAME")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .padding(.horizontal)
                            
                            TextField("Enter item name", text: $itemName)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .padding(.horizontal)
                        }
                        
                        // Item Price
                        VStack(alignment: .leading, spacing: 8) {
                            Text("PRICE (QAR)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .padding(.horizontal)
                            
                            TextField("0.00", text: $itemPrice)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .keyboardType(.decimalPad)
                                .padding(.horizontal)
                        }
                        
                        // Category Selection
                        VStack(alignment: .leading, spacing: 8) {
                            Text("CATEGORY")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .padding(.horizontal)
                            
                            Picker("Category", selection: $selectedCategoryId) {
                                ForEach(categories) { category in
                                    Text(category.name).tag(category.id)
                                }
                            }
                            .pickerStyle(MenuPickerStyle())
                            .padding(.horizontal)
                        }
                    }
                }
                
                // Action Buttons
                VStack(spacing: 12) {
                    Button(action: saveItem) {
                        HStack {
                            Image(systemName: "checkmark")
                            Text("Save Item")
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(canSave ? Color.blue : Color.gray)
                        .cornerRadius(12)
                    }
                    .disabled(!canSave)
                    
                    Button(action: { dismiss() }) {
                        Text("Cancel")
                            .foregroundColor(.secondary)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color(.systemGray5))
                            .cornerRadius(12)
                    }
                }
                .padding()
            }
            .navigationBarHidden(true)
        }
        .onAppear {
            loadCategories()
            if let editingItem = editingItem {
                itemName = editingItem.name
                itemPrice = String(format: "%.2f", editingItem.price)
                selectedCategoryId = editingItem.category_id
                isNewItem = false
            } else {
                itemName = ""
                itemPrice = ""
                selectedCategoryId = selectedCategory?.id ?? UUID()
                isNewItem = true
            }
        }
    }
    
    private var canSave: Bool {
        !itemName.isEmpty && !itemPrice.isEmpty && Double(itemPrice) != nil
    }
    
    private func loadCategories() {
        Task {
            do {
                categories = try await SupabaseService.fetchCategories()
            } catch {
                print("Failed to load categories: \(error)")
                categories = ProductionData.defaultCategories
            }
        }
    }
    
    private func saveItem() {
        guard let price = Double(itemPrice) else { return }
        
        if isNewItem {
            // Add new item
            let newItem = MenuItem(
                id: UUID(),
                name: itemName.trimmingCharacters(in: .whitespacesAndNewlines),
                price: price,
                imageURL: "default-item",
                category_id: selectedCategoryId
            )
            menuItems.append(newItem)
        } else if let editingItem = editingItem {
            // Update existing item
            if let index = menuItems.firstIndex(where: { $0.id == editingItem.id }) {
                menuItems[index].name = itemName.trimmingCharacters(in: .whitespacesAndNewlines)
                menuItems[index].price = price
                menuItems[index].category_id = selectedCategoryId
            }
        }
        
        onItemUpdated()
        dismiss()
    }
}

// MARK: - Preview
#Preview {
    MenuItemEditorView(
        selectedCategory: .constant(nil),
        menuItems: .constant([]),
        editingItem: .constant(nil),
        onItemUpdated: {}
    )
}
