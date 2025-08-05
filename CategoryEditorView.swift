import SwiftUI

struct CategoryEditorView: View {
    @Binding var categories: [MenuCategory]
    @Binding var selectedCategory: MenuCategory?
    @Binding var editingCategory: MenuCategory?
    let onCategoryUpdated: () -> Void
    
    @Environment(\.dismiss) private var dismiss
    @State private var categoryName: String = ""
    @State private var isNewCategory: Bool = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Header
                VStack(spacing: 8) {
                    Text(isNewCategory ? "Add Category" : "Edit Category")
                        .font(.title2.bold())
                    
                    Text("Enter the category name below")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.top)
                
                // Category Name Input
                VStack(alignment: .leading, spacing: 8) {
                    Text("CATEGORY NAME")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.horizontal)
                    
                    TextField("Enter category name", text: $categoryName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.horizontal)
                }
                
                Spacer()
                
                // Action Buttons
                VStack(spacing: 12) {
                    Button(action: saveCategory) {
                        HStack {
                            Image(systemName: "checkmark")
                            Text("Save Category")
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(categoryName.isEmpty ? Color.gray : Color.blue)
                        .cornerRadius(12)
                    }
                    .disabled(categoryName.isEmpty)
                    
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
            if let editingCategory = editingCategory {
                categoryName = editingCategory.name
                isNewCategory = false
            } else {
                categoryName = ""
                isNewCategory = true
            }
        }
    }
    
    private func saveCategory() {
        if isNewCategory {
            // Add new category
            let newCategory = MenuCategory(
                id: UUID(),
                name: categoryName.trimmingCharacters(in: .whitespacesAndNewlines)
            )
            categories.append(newCategory)
        } else if let editingCategory = editingCategory {
            // Update existing category
            if let index = categories.firstIndex(where: { $0.id == editingCategory.id }) {
                categories[index].name = categoryName.trimmingCharacters(in: .whitespacesAndNewlines)
            }
        }
        
        onCategoryUpdated()
        dismiss()
    }
}

// MARK: - Preview
#Preview {
    CategoryEditorView(
        categories: .constant([]),
        selectedCategory: .constant(nil),
        editingCategory: .constant(nil),
        onCategoryUpdated: {}
    )
}
