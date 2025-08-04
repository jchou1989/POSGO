import SwiftUI

struct ChageePOSView: View {
    @StateObject private var viewModel = ChageePOSViewModel()
    @State private var selectedCategory: MenuCategory?
    @State private var showingCustomizeSheet = false
    @State private var selectedItem: MenuItem?
    
    var body: some View {
        GeometryReader { geometry in
            HStack(spacing: 0) {
                // Menu Section (Left)
                menuSection
                    .frame(width: geometry.size.width * 0.65)
                
                // Cart Section (Right)
                cartSection
                    .frame(width: geometry.size.width * 0.35)
                    .background(ChageeTheme.Colors.cream)
            }
        }
        .background(ChageeTheme.Colors.background)
        .sheet(isPresented: $showingCustomizeSheet) {
            if let item = selectedItem {
                CustomizeOrderView(
                    item: item,
                    onAddToCart: { orderItem in
                        viewModel.addToCart(orderItem)
                        showingCustomizeSheet = false
                        selectedItem = nil
                    }
                )
            }
        }
        .sheet(isPresented: $viewModel.showingPaymentView) {
            PaymentView(
                orderItems: viewModel.cart,
                subtotal: viewModel.subtotal,
                tax: viewModel.tax,
                total: viewModel.total,
                onComplete: { paymentMethod in
                    viewModel.completePayment(method: paymentMethod)
                },
                onCancel: {
                    viewModel.showingPaymentView = false
                }
            )
        }
        .task {
            await viewModel.loadData()
        }
    }
    
    // MARK: - Menu Section
    private var menuSection: some View {
        VStack(spacing: 0) {
            // Header
            headerView
            
            // Category Tabs
            categoryTabs
            
            // Menu Grid
            menuGrid
                .padding(ChageeTheme.Spacing.lg)
        }
    }
    
    private var headerView: some View {
        HStack {
            VStack(alignment: .leading, spacing: ChageeTheme.Spacing.xs) {
                Text("CHAGEE")
                    .font(ChageeTheme.Typography.largeTitle)
                    .foregroundColor(ChageeTheme.Colors.primaryGreen)
                
                Text("Premium Tea Experience")
                    .font(ChageeTheme.Typography.subheadline)
                    .foregroundColor(ChageeTheme.Colors.textSecondary)
            }
            
            Spacer()
            
            // Time and Store Info
            VStack(alignment: .trailing, spacing: ChageeTheme.Spacing.xs) {
                Text(Date(), style: .time)
                    .font(ChageeTheme.Typography.headline)
                    .foregroundColor(ChageeTheme.Colors.text)
                
                Text("Store #001")
                    .font(ChageeTheme.Typography.caption)
                    .foregroundColor(ChageeTheme.Colors.textSecondary)
            }
        }
        .padding(ChageeTheme.Spacing.lg)
        .background(ChageeTheme.Colors.surface)
    }
    
    private var categoryTabs: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: ChageeTheme.Spacing.md) {
                ForEach(viewModel.categories) { category in
                    CategoryTab(
                        category: category,
                        isSelected: selectedCategory?.id == category.id,
                        action: { selectedCategory = category }
                    )
                }
            }
            .padding(.horizontal, ChageeTheme.Spacing.lg)
            .padding(.vertical, ChageeTheme.Spacing.md)
        }
        .background(ChageeTheme.Colors.surface)
    }
    
    private var menuGrid: some View {
        ScrollView {
            LazyVGrid(columns: [
                GridItem(.flexible(), spacing: ChageeTheme.Spacing.md),
                GridItem(.flexible(), spacing: ChageeTheme.Spacing.md),
                GridItem(.flexible(), spacing: ChageeTheme.Spacing.md),
                GridItem(.flexible(), spacing: ChageeTheme.Spacing.md)
            ], spacing: ChageeTheme.Spacing.md) {
                ForEach(filteredMenuItems) { item in
                    MenuItemCard(item: item) {
                        selectedItem = item
                        showingCustomizeSheet = true
                    }
                }
            }
        }
    }
    
    private var filteredMenuItems: [MenuItem] {
        if let category = selectedCategory {
            return viewModel.menuItems.filter { $0.category_id == category.id }
        }
        return viewModel.menuItems
    }
    
    // MARK: - Cart Section
    private var cartSection: some View {
        VStack(spacing: 0) {
            // Cart Header
            cartHeader
            
            // Cart Items
            cartItemsList
            
            // Cart Summary
            cartSummary
        }
    }
    
    private var cartHeader: some View {
        HStack {
            Image(systemName: "cart.fill")
                .font(.title2)
                .foregroundColor(ChageeTheme.Colors.primaryGreen)
            
            Text("Current Order")
                .font(ChageeTheme.Typography.headline)
                .foregroundColor(ChageeTheme.Colors.text)
            
            Spacer()
            
            Text("#\(String(format: "%04d", viewModel.currentOrderNumber))")
                .font(ChageeTheme.Typography.callout)
                .foregroundColor(ChageeTheme.Colors.textSecondary)
        }
        .padding(ChageeTheme.Spacing.lg)
        .background(ChageeTheme.Colors.surface)
    }
    
    private var cartItemsList: some View {
        ScrollView {
            VStack(spacing: ChageeTheme.Spacing.sm) {
                if viewModel.cart.isEmpty {
                    emptyCartView
                } else {
                    ForEach(viewModel.cart.indices, id: \.self) { index in
                        CartItemRow(
                            item: viewModel.cart[index],
                            onRemove: { viewModel.removeFromCart(at: index) }
                        )
                    }
                }
            }
            .padding(ChageeTheme.Spacing.md)
        }
    }
    
    private var emptyCartView: some View {
        VStack(spacing: ChageeTheme.Spacing.md) {
            Image(systemName: "cup.and.saucer")
                .font(.system(size: 48))
                .foregroundColor(ChageeTheme.Colors.textSecondary.opacity(0.5))
            
            Text("No items in cart")
                .font(ChageeTheme.Typography.body)
                .foregroundColor(ChageeTheme.Colors.textSecondary)
            
            Text("Select items from the menu to begin")
                .font(ChageeTheme.Typography.caption)
                .foregroundColor(ChageeTheme.Colors.textSecondary.opacity(0.7))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.vertical, ChageeTheme.Spacing.xxl)
    }
    
    private var cartSummary: some View {
        VStack(spacing: ChageeTheme.Spacing.md) {
            // Subtotal
            HStack {
                Text("Subtotal")
                    .font(ChageeTheme.Typography.body)
                    .foregroundColor(ChageeTheme.Colors.textSecondary)
                Spacer()
                Text(viewModel.formattedSubtotal)
                    .font(ChageeTheme.Typography.callout)
                    .foregroundColor(ChageeTheme.Colors.text)
            }
            
            // Tax
            HStack {
                Text("Tax")
                    .font(ChageeTheme.Typography.body)
                    .foregroundColor(ChageeTheme.Colors.textSecondary)
                Spacer()
                Text(viewModel.formattedTax)
                    .font(ChageeTheme.Typography.callout)
                    .foregroundColor(ChageeTheme.Colors.text)
            }
            
            Divider()
                .background(ChageeTheme.Colors.divider)
            
            // Total
            HStack {
                Text("Total")
                    .font(ChageeTheme.Typography.headline)
                    .foregroundColor(ChageeTheme.Colors.text)
                Spacer()
                Text(viewModel.formattedTotal)
                    .font(ChageeTheme.Typography.price)
                    .foregroundColor(ChageeTheme.Colors.primaryGreen)
            }
            
            // Action Buttons
            HStack(spacing: ChageeTheme.Spacing.md) {
                Button("Clear") {
                    viewModel.clearCart()
                }
                .chageeSecondaryButton()
                
                Button("Checkout") {
                    viewModel.processCheckout()
                }
                .chageePrimaryButton()
                .disabled(viewModel.cart.isEmpty)
            }
            .padding(.top, ChageeTheme.Spacing.md)
        }
        .padding(ChageeTheme.Spacing.lg)
        .background(ChageeTheme.Colors.surface)
    }
}

// MARK: - Supporting Views
struct CategoryTab: View {
    let category: MenuCategory
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(category.name)
                .font(ChageeTheme.Typography.callout)
                .foregroundColor(isSelected ? .white : ChageeTheme.Colors.primaryGreen)
                .padding(.horizontal, ChageeTheme.Spacing.lg)
                .padding(.vertical, ChageeTheme.Spacing.sm)
                .background(
                    isSelected ? ChageeTheme.Colors.primaryGreen : Color.clear
                )
                .overlay(
                    RoundedRectangle(cornerRadius: ChageeTheme.Radius.full)
                        .stroke(ChageeTheme.Colors.primaryGreen, lineWidth: 1.5)
                )
                .cornerRadius(ChageeTheme.Radius.full)
        }
    }
}

struct MenuItemCard: View {
    let item: MenuItem
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: ChageeTheme.Spacing.sm) {
                // Item Image Placeholder
                RoundedRectangle(cornerRadius: ChageeTheme.Radius.md)
                    .fill(ChageeTheme.Colors.cream)
                    .frame(height: 120)
                    .overlay(
                        Image(systemName: "cup.and.saucer.fill")
                            .font(.system(size: 40))
                            .foregroundColor(ChageeTheme.Colors.primaryGreen.opacity(0.3))
                    )
                
                VStack(alignment: .leading, spacing: ChageeTheme.Spacing.xs) {
                    Text(item.name)
                        .font(ChageeTheme.Typography.callout)
                        .foregroundColor(ChageeTheme.Colors.text)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                    
                    Text(formatPrice(item.price))
                        .font(ChageeTheme.Typography.headline)
                        .foregroundColor(ChageeTheme.Colors.primaryGreen)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(ChageeTheme.Spacing.md)
            .chageeCard()
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private func formatPrice(_ price: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        return formatter.string(from: NSNumber(value: price)) ?? "$\(String(format: "%.2f", price))"
    }
}

struct CartItemRow: View {
    let item: OrderItem
    let onRemove: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: ChageeTheme.Spacing.sm) {
            HStack {
                Text(item.name)
                    .font(ChageeTheme.Typography.callout)
                    .foregroundColor(ChageeTheme.Colors.text)
                
                Spacer()
                
                Button(action: onRemove) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(ChageeTheme.Colors.textSecondary.opacity(0.5))
                }
            }
            
            // Customizations
            VStack(alignment: .leading, spacing: ChageeTheme.Spacing.xs) {
                Text("\(item.size) • \(item.sugar) • \(item.ice)")
                    .font(ChageeTheme.Typography.caption)
                    .foregroundColor(ChageeTheme.Colors.textSecondary)
                
                if !item.toppings.isEmpty {
                    Text("+ \(item.toppings.joined(separator: ", "))")
                        .font(ChageeTheme.Typography.caption)
                        .foregroundColor(ChageeTheme.Colors.textSecondary)
                }
            }
            
            HStack {
                Text("1x")
                    .font(ChageeTheme.Typography.caption)
                    .foregroundColor(ChageeTheme.Colors.textSecondary)
                
                Spacer()
                
                Text(item.formattedPrice)
                    .font(ChageeTheme.Typography.callout)
                    .foregroundColor(ChageeTheme.Colors.primaryGreen)
            }
        }
        .padding(ChageeTheme.Spacing.md)
        .background(ChageeTheme.Colors.surface)
        .cornerRadius(ChageeTheme.Radius.sm)
    }
}

// Preview
struct ChageePOSView_Previews: PreviewProvider {
    static var previews: some View {
        ChageePOSView()
            .previewInterfaceOrientation(.landscapeLeft)
    }
}