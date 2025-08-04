import SwiftUI

struct MainView: View {
    @State private var categories: [MenuCategory] = []
    @State private var menuItems: [MenuItem] = []
    @State private var selectedCategory: MenuCategory?
    @State private var editingCategory: MenuCategory?
    @State private var editingItem: MenuItem?
    @State private var showError = false
    @State private var errorMessage = ""

    var body: some View {
        VStack {
            CategoryEditorView(
                categories: $categories,
                selectedCategory: $selectedCategory,
                editingCategory: $editingCategory,
                onCategoryUpdated: {
                    Task {
                        await loadCategories()
                        await loadItems()
                    }
                }
            )

            List(menuItems) { item in
                Text(item.name)
                    .onTapGesture {
                        editingItem = item
                    }
            }
        }
        .sheet(item: $editingItem) { item in
            if selectedCategory != nil {
                MenuItemEditSheet(
                    item: Binding(
                        get: { item },
                        set: { newVal in editingItem = newVal }
                    ),
                    isPresented: .constant(true),
                    categories: $categories,
                    onSave: {
                        Task {
                            await loadItems()
                            editingItem = nil
                        }
                    }
                )
            }
        }
        .task {
            await loadCategories()
        }
        .alert("Error", isPresented: $showError) {
            Button("OK") { }
        } message: {
            Text(errorMessage)
        }
    }

    func loadCategories() async {
        do {
            categories = try await SupabaseService.fetchCategories()
            if let selected = selectedCategory {
                selectedCategory = categories.first(where: { $0.id == selected.id })
            } else {
                selectedCategory = categories.first
            }
            await loadItems()
        } catch {
            errorMessage = "Failed to load categories: \(error.localizedDescription)"
            showError = true
        }
    }

    func loadItems() async {
        do {
            if let category = selectedCategory {
                menuItems = try await SupabaseService.fetchMenuItems(for: category.id)
            } else {
                menuItems = []
            }
        } catch {
            errorMessage = "Failed to load menu items: \(error.localizedDescription)"
            showError = true
        }
    }
}
