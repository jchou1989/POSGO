import SwiftUI

struct MainView: View {
    @EnvironmentObject var appState: AppState
    @State private var categories: [MenuCategory] = []
    @State private var menuItems: [MenuItem] = []
    @State private var selectedCategory: MenuCategory?
    @State private var editingCategory: MenuCategory?
    @State private var editingItem: MenuItem?
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var isAdminMode = false
    @State private var selectedMenuItem: MenuItem?
    @State private var showCart = false
    
    private let gridColumns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        NavigationView {
            HStack(spacing: 0) {
                // Left Sidebar - Categories & Admin
                VStack(spacing: 0) {
                    // Header
                    VStack(spacing: 16) {
                        Text("CHAGEE")
                            .font(.system(size: 28, weight: .bold, design: .serif))
                            .foregroundColor(.teaGold)
                        
                        Text("MODERN TEA CULTURE")
                            .font(.caption)
                            .foregroundColor(.teaBrown.opacity(0.7))
                            .letterSpacing(1.5)
                    }
                    .padding(.top, 24)
                    .padding(.bottom, 32)
                    
                    // Categories
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(categories) { category in
                                CategoryCard(
                                    category: category,
                                    isSelected: selectedCategory?.id == category.id
                                ) {
                                    selectedCategory = category
                                    Task {
                                        await loadItems()
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, 16)
                    }
                    
                    Spacer()
                    
                    // Admin Toggle
                    VStack(spacing: 16) {
                        Toggle("Admin Mode", isOn: $isAdminMode)
                            .tint(.teaGold)
                            .padding(.horizontal, 16)
                        
                        if isAdminMode {
                            Button("Manage Menu") {
                                // Navigate to admin panel
                            }
                            .buttonStyle(SecondaryButtonStyle())
                            .padding(.horizontal, 16)
                        }
                    }
                    .padding(.bottom, 24)
                }
                .frame(width: 280)
                .background(Color.teaCream)
                
                // Main Content Area
                VStack(spacing: 0) {
                    // Top Bar
                    HStack {
                        VStack(alignment: .leading) {
                            Text(selectedCategory?.name ?? "Select Category")
                                .font(.title2.bold())
                                .foregroundColor(.teaBrown)
                            
                            Text("\(menuItems.count) items available")
                                .font(.caption)
                                .foregroundColor(.teaBrown.opacity(0.6))
                        }
                        
                        Spacer()
                        
                        // Cart Button
                        Button(action: { showCart = true }) {
                            HStack(spacing: 8) {
                                Image(systemName: "cart.fill")
                                Text("\(appState.cart.count)")
                                    .fontWeight(.semibold)
                            }
                            .foregroundColor(.white)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 12)
                            .background(Color.teaGold)
                            .cornerRadius(25)
                        }
                    }
                    .padding(.horizontal, 32)
                    .padding(.vertical, 20)
                    .background(Color.white)
                    
                    // Menu Items Grid
                    ScrollView {
                        LazyVGrid(columns: gridColumns, spacing: 24) {
                            ForEach(menuItems) { item in
                                MenuItemCard(item: item) {
                                    selectedMenuItem = item
                                }
                            }
                        }
                        .padding(32)
                    }
                    .background(Color.softWhite)
                }
            }
        }
        .navigationBarHidden(true)
        .sheet(item: $selectedMenuItem) { item in
            CustomizeView(menuItem: item) { orderItem in
                appState.cart.append(orderItem)
            }
        }
        .sheet(isPresented: $showCart) {
            CartView(cart: $appState.cart)
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
            if selectedCategory == nil {
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

// MARK: - Category Card
struct CategoryCard: View {
    let category: MenuCategory
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: iconForCategory(category.name))
                    .font(.title2)
                    .foregroundColor(isSelected ? .white : .teaBrown)
                
                Text(category.name)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(isSelected ? .white : .teaBrown)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 20)
            .background(isSelected ? Color.teaGold : Color.white)
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.08), radius: 4, x: 0, y: 2)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private func iconForCategory(_ name: String) -> String {
        switch name.lowercased() {
        case let n where n.contains("latte"): return "cup.and.saucer.fill"
        case let n where n.contains("tea"): return "leaf.fill"
        case let n where n.contains("coffee"): return "mug.fill"
        case let n where n.contains("smoothie"): return "drop.fill"
        case let n where n.contains("dessert"): return "birthday.cake.fill"
        default: return "circle.fill"
        }
    }
}

// MARK: - Menu Item Card
struct MenuItemCard: View {
    let item: MenuItem
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 12) {
                // Image placeholder
                RoundedRectangle(cornerRadius: 12)
                    .fill(LinearGradient(
                        colors: [Color.teaGold.opacity(0.3), Color.teaBrown.opacity(0.1)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ))
                    .frame(height: 140)
                    .overlay(
                        Image(systemName: "cup.and.saucer.fill")
                            .font(.system(size: 32))
                            .foregroundColor(.teaBrown.opacity(0.5))
                    )
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(item.name)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.teaBrown)
                        .lineLimit(2)
                    
                    Text("Starting from $\(String(format: "%.2f", item.price))")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.teaGold)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(16)
            .background(Color.white)
            .cornerRadius(16)
            .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 4)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Button Styles
struct SecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 14, weight: .medium))
            .foregroundColor(.teaBrown)
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(Color.white)
            .cornerRadius(8)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

// MARK: - Color Extensions
extension Color {
    static let teaGold = Color(red: 0.8, green: 0.6, blue: 0.2)
    static let teaBrown = Color(red: 0.4, green: 0.3, blue: 0.2)
    static let teaCream = Color(red: 0.98, green: 0.96, blue: 0.92)
    static let softWhite = Color(red: 0.99, green: 0.99, blue: 0.97)
}

#Preview {
    MainView()
        .environmentObject(AppState())
}
