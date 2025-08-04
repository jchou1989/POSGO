import SwiftUI

struct MenuItemEditorView: View {
    @Binding var selectedCategory: MenuCategory?
    @Binding var menuItems: [MenuItem]
    @Binding var editingItem: MenuItem?
    var onItemUpdated: () -> Void

    var body: some View {
        VStack {
            List {
                ForEach(menuItems) { item in
                    VStack(alignment: .leading) {
                        Text(item.name)
                            .font(.headline)
                        Text("$\(String(format: "%.2f", item.price))")
                            .font(.subheadline)
                    }
                    .onTapGesture {
                        editingItem = item
                    }
                }
            }

            Button("Add Item") {
                if let category = selectedCategory {
                    editingItem = MenuItem(id: UUID(), name: "New Item", price: 0.0, category_id: category.id)
                }
            }
            .padding()
        }
    }
}
