import SwiftUI

struct POSView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var authManager: AuthenticationManager
    @State private var categories: [MenuCategory] = []
    @State private var menuItems: [MenuItem] = []
    @State private var selectedCategory: MenuCategory?
    @State private var showingCart = false
    @State private var showingPayment = false
    @State private var showingCustomize = false
    @State private var selectedMenuItem: MenuItem?
    @State private var showingAdmin = false
    @State private var isLoading = false
    @State private var errorMessage = ""
    @State private var showError = false
    
    var body: some View {
        NavigationView {
            // Left side - Menu (70% width)
            VStack(spacing: 0) {
                // Header
                POSHeaderView(
                    onAdminTap: {
                        showingAdmin = true
                    }
                )
                
                // Categories
                CategoryGridView(
                    categories: categories,
                    selectedCategory: $selectedCategory,
                    onCategorySelected: { category in
                        selectedCategory = category
                        Task {
                            await loadMenuItems(for: category.id)
                        }
                    }
                )
                
                // Menu Items Grid
                MenuItemsGridView(
                    items: menuItems,
                    onItemSelected: { item in
                        selectedMenuItem = item
                        showingCustomize = true
                    }
                )
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(.systemGray6))
            
            // Right side - Cart (30% width)
            CartSidebarView(
                cart: $appState.cart,
                onCheckout: {
                    showingPayment = true
                }
            )
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .sheet(isPresented: $showingPayment) {
            PaymentView(
                cart: appState.cart,
                onPaymentComplete: { success in
                    if success {
                        appState.clearCart()
                        showingPayment = false
                    }
                }
            )
        }
        .sheet(isPresented: $showingCustomize) {
            if let menuItem = selectedMenuItem {
                CustomizeView(
                    menuItem: menuItem,
                    onAddToCart: { orderItem in
                        appState.addToCart(orderItem)
                        showingCustomize = false
                    }
                )
            }
        }
        .sheet(isPresented: $showingAdmin) {
            AdminView()
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
    
    private func loadCategories() async {
        await MainActor.run {
            isLoading = true
        }
        
        do {
            let fetchedCategories = try await SupabaseService.fetchCategories()
            await MainActor.run {
                categories = fetchedCategories
                if let firstCategory = categories.first {
                    selectedCategory = firstCategory
                }
            }
            
            if let firstCategory = categories.first {
                await loadMenuItems(for: firstCategory.id)
            }
        } catch {
            await MainActor.run {
                errorMessage = "Failed to load categories: \(error.localizedDescription)"
                showError = true
            }
        }
        
        await MainActor.run {
            isLoading = false
        }
    }
    
    private func loadMenuItems(for categoryId: UUID) async {
        do {
            let fetchedItems = try await SupabaseService.fetchMenuItems(for: categoryId)
            await MainActor.run {
                menuItems = fetchedItems
            }
        } catch {
            await MainActor.run {
                errorMessage = "Failed to load menu items: \(error.localizedDescription)"
                showError = true
            }
        }
    }
    
    // CustomizeView is now handled by the sheet presentation
}

// MARK: - Header View
struct POSHeaderView: View {
    @EnvironmentObject var authManager: AuthenticationManager
    let onAdminTap: () -> Void
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("POS GO")
                    .font(.title2.bold())
                    .foregroundColor(.primary)
                Text("Point of Sale")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            HStack(spacing: 16) {
                // Admin button for managers and admins
                if authManager.currentUser?.role == .manager || authManager.currentUser?.role == .admin {
                    Button(action: onAdminTap) {
                        HStack(spacing: 4) {
                            Image(systemName: "gearshape.fill")
                                .font(.caption)
                            Text("Admin")
                                .font(.caption.bold())
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.blue)
                        .cornerRadius(8)
                    }
                }
                
                // Demo admin button (for testing)
                Button(action: onAdminTap) {
                    HStack(spacing: 4) {
                        Image(systemName: "gearshape.fill")
                            .font(.caption)
                        Text("Admin")
                            .font(.caption.bold())
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.orange)
                    .cornerRadius(8)
                }
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text(authManager.currentUser?.name ?? "User")
                        .font(.subheadline.bold())
                    Text(authManager.currentUser?.role.rawValue ?? "Cashier")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .shadow(color: .black.opacity(0.1), radius: 2, y: 1)
    }
}

// MARK: - Category Grid
struct CategoryGridView: View {
    let categories: [MenuCategory]
    @Binding var selectedCategory: MenuCategory?
    let onCategorySelected: (MenuCategory) -> Void
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(categories) { category in
                    CategoryButton(
                        category: category,
                        isSelected: selectedCategory?.id == category.id,
                        onTap: {
                            selectedCategory = category
                            onCategorySelected(category)
                        }
                    )
                }
            }
            .padding(.horizontal)
        }
        .padding(.vertical, 8)
        .background(Color(.systemBackground))
    }
}

struct CategoryButton: View {
    let category: MenuCategory
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            Text(category.name)
                .font(.headline)
                .foregroundColor(isSelected ? .white : .primary)
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 25)
                        .fill(isSelected ? Color.blue : Color(.systemGray5))
                )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Menu Items Grid
struct MenuItemsGridView: View {
    let items: [MenuItem]
    let onItemSelected: (MenuItem) -> Void
    
    private let columns = [
        GridItem(.adaptive(minimum: 200, maximum: 300), spacing: 16)
    ]
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 16) {
                ForEach(items) { item in
                    MenuItemCard(item: item, onTap: onItemSelected)
                }
            }
            .padding()
        }
    }
}

struct MenuItemCard: View {
    let item: MenuItem
    let onTap: (MenuItem) -> Void
    
    var body: some View {
        Button(action: { onTap(item) }) {
            VStack(spacing: 12) {
                // Item image placeholder
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.systemGray4))
                    .frame(height: 120)
                    .overlay(
                        Image(systemName: "cup.and.saucer")
                            .font(.system(size: 40))
                            .foregroundColor(.gray)
                    )
                
                VStack(spacing: 8) {
                    Text(item.name)
                        .font(.headline)
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.center)
                    
                    Text(item.qarFormattedPrice)
                        .font(.title3.bold())
                        .foregroundColor(.blue)
                }
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(16)
            .shadow(color: .black.opacity(0.1), radius: 4, y: 2)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Cart Sidebar
struct CartSidebarView: View {
    @Binding var cart: [OrderItem]
    let onCheckout: () -> Void
    
    private var total: Double {
        cart.reduce(0) { $0 + $1.price }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Cart header
            HStack {
                Text("Current Order")
                    .font(.title2.bold())
                Spacer()
                Text("\(cart.count) items")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .padding()
            .background(Color(.systemBackground))
            
            // Cart items
            ScrollView {
                if cart.isEmpty {
                    VStack(spacing: 20) {
                        Image(systemName: "cart")
                            .font(.system(size: 60))
                            .foregroundColor(.gray.opacity(0.5))
                        
                        Text("Your cart is empty")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        
                        Text("Select items from the menu to get started")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding()
                } else {
                    LazyVStack(spacing: 12) {
                        ForEach(cart) { item in
                            CartItemRow(item: item)
                        }
                    }
                    .padding()
                }
            }
            
            // Checkout section
            VStack(spacing: 16) {
                Divider()
                
                VStack(spacing: 8) {
                    HStack {
                        Text("Total")
                            .font(.title2.bold())
                        Spacer()
                        Text("QR \(String(format: "%.2f", total))")
                            .font(.title2.bold())
                            .foregroundColor(.blue)
                    }
                    
                    Button(action: onCheckout) {
                        HStack {
                            Image(systemName: "creditcard.fill")
                            Text("Checkout")
                                .font(.headline)
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(cart.isEmpty ? Color.gray : Color.blue)
                        .cornerRadius(12)
                    }
                    .disabled(cart.isEmpty)
                }
                .padding()
            }
            .background(Color(.systemBackground))
        }
        .frame(minWidth: 400, maxWidth: .infinity)
        .background(Color(.systemBackground))
        .shadow(color: .black.opacity(0.1), radius: 4, x: -2)
    }
}

struct CartItemRow: View {
    let item: OrderItem
    
    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(item.name)
                    .font(.headline)
                
                if !item.size.isEmpty {
                    Text(item.size)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                if !item.selectedToppings.isEmpty {
                    Text(item.selectedToppings.joined(separator: ", "))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
                                Text(item.qarFormattedPrice)
                .font(.subheadline.bold())
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(8)
    }
}

struct POSEmptyCartView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "cart.badge.questionmark")
                .font(.system(size: 60))
                .foregroundColor(.gray.opacity(0.5))
            
            VStack(spacing: 8) {
                Text("Cart is Empty")
                    .font(.title3.bold())
                Text("Select items from the menu to get started")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Extensions
// Note: formattedPrice is defined in ProductionData.swift extension

#Preview {
    POSView()
        .environmentObject(AppState())
        .environmentObject(AuthenticationManager())
        .environmentObject(PaymentManager())
}