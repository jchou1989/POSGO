import SwiftUI

struct CategoryEditorView: View {
    @Binding var categories: [MenuCategory]
    @Binding var selectedCategory: MenuCategory?
    @Binding var editingCategory: MenuCategory?
    var onCategoryUpdated: () -> Void

    var body: some View {
        VStack {
            List(selection: $selectedCategory) {
                ForEach(categories) { category in
                    Text(category.name)
                        .tag(category)
                }
            }

            HStack {
                Button("Edit") {
                    if let selected = selectedCategory {
                        editingCategory = selected
                    }
                }

                Button("Add") {
                    editingCategory = MenuCategory(id: UUID(), name: "New Category")
                }
            }
            .padding()
        }
        .sheet(item: $editingCategory) { category in
            CategoryEditSheet(
                category: Binding<MenuCategory>(
                    get: { category },
                    set: { newVal in
                        if let index = categories.firstIndex(where: { $0.id == newVal.id }) {
                            categories[index] = newVal
                        } else {
                            categories.append(newVal)
                        }
                    }
                ),
                isPresented: Binding<Bool>(
                    get: { editingCategory != nil },
                    set: { if !$0 { editingCategory = nil } }
                ),
                onSave: {
                    onCategoryUpdated()
                }
            )
        }

    }
}
