import SwiftUI

struct CustomizeOrderView: View {
    let item: MenuItem
    let onAddToCart: (OrderItem) -> Void
    
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = CustomizeOrderViewModel()
    
    // Selection states
    @State private var selectedSize: SizeOption?
    @State private var selectedSugar = "Regular"
    @State private var selectedIce = "Regular"
    @State private var selectedToppings: Set<ToppingOption> = []
    
    private let sugarLevels = ["0%", "30%", "50%", "70%", "100%", "120%"]
    private let iceLevels = ["No Ice", "Less Ice", "Regular", "Extra Ice"]
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header with item info
                itemHeader
                
                ScrollView {
                    VStack(spacing: ChageeTheme.Spacing.lg) {
                        // Size Selection
                        sizeSection
                        
                        // Sugar Level
                        sugarSection
                        
                        // Ice Level
                        iceSection
                        
                        // Toppings
                        toppingsSection
                    }
                    .padding(ChageeTheme.Spacing.lg)
                }
                
                // Bottom bar with price and add button
                bottomBar
            }
            .background(ChageeTheme.Colors.background)
            .navigationBarHidden(true)
        }
        .task {
            await viewModel.loadOptions()
            // Set default size
            selectedSize = viewModel.sizes.first
        }
    }
    
    // MARK: - Header
    private var itemHeader: some View {
        VStack(spacing: 0) {
            // Close button
            HStack {
                Spacer()
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title2)
                        .foregroundColor(ChageeTheme.Colors.textSecondary.opacity(0.5))
                }
            }
            .padding(ChageeTheme.Spacing.md)
            
            // Item image and info
            VStack(spacing: ChageeTheme.Spacing.md) {
                // Image placeholder
                RoundedRectangle(cornerRadius: ChageeTheme.Radius.lg)
                    .fill(ChageeTheme.Colors.cream)
                    .frame(width: 200, height: 200)
                    .overlay(
                        Image(systemName: "cup.and.saucer.fill")
                            .font(.system(size: 60))
                            .foregroundColor(ChageeTheme.Colors.primaryGreen.opacity(0.3))
                    )
                
                Text(item.name)
                    .font(ChageeTheme.Typography.title)
                    .foregroundColor(ChageeTheme.Colors.text)
                
                Text(formatPrice(item.price))
                    .font(ChageeTheme.Typography.headline)
                    .foregroundColor(ChageeTheme.Colors.textSecondary)
            }
            .padding(.bottom, ChageeTheme.Spacing.lg)
        }
        .background(ChageeTheme.Colors.surface)
    }
    
    // MARK: - Size Section
    private var sizeSection: some View {
        VStack(alignment: .leading, spacing: ChageeTheme.Spacing.md) {
            Text("Size")
                .font(ChageeTheme.Typography.headline)
                .foregroundColor(ChageeTheme.Colors.text)
            
            HStack(spacing: ChageeTheme.Spacing.md) {
                ForEach(viewModel.sizes) { size in
                    SizeOptionButton(
                        size: size,
                        isSelected: selectedSize?.id == size.id,
                        action: { selectedSize = size }
                    )
                }
            }
        }
    }
    
    // MARK: - Sugar Section
    private var sugarSection: some View {
        VStack(alignment: .leading, spacing: ChageeTheme.Spacing.md) {
            Text("Sugar Level")
                .font(ChageeTheme.Typography.headline)
                .foregroundColor(ChageeTheme.Colors.text)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: ChageeTheme.Spacing.sm) {
                    ForEach(sugarLevels, id: \.self) { level in
                        CustomizationChip(
                            label: level,
                            isSelected: selectedSugar == level,
                            action: { selectedSugar = level }
                        )
                    }
                }
            }
        }
    }
    
    // MARK: - Ice Section
    private var iceSection: some View {
        VStack(alignment: .leading, spacing: ChageeTheme.Spacing.md) {
            Text("Ice Level")
                .font(ChageeTheme.Typography.headline)
                .foregroundColor(ChageeTheme.Colors.text)
            
            HStack(spacing: ChageeTheme.Spacing.sm) {
                ForEach(iceLevels, id: \.self) { level in
                    CustomizationChip(
                        label: level,
                        isSelected: selectedIce == level,
                        action: { selectedIce = level }
                    )
                }
            }
        }
    }
    
    // MARK: - Toppings Section
    private var toppingsSection: some View {
        VStack(alignment: .leading, spacing: ChageeTheme.Spacing.md) {
            HStack {
                Text("Add-ons")
                    .font(ChageeTheme.Typography.headline)
                    .foregroundColor(ChageeTheme.Colors.text)
                
                Spacer()
                
                Text("Optional")
                    .font(ChageeTheme.Typography.caption)
                    .foregroundColor(ChageeTheme.Colors.textSecondary)
            }
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: ChageeTheme.Spacing.md) {
                ForEach(viewModel.toppings) { topping in
                    ToppingOptionButton(
                        topping: topping,
                        isSelected: selectedToppings.contains(topping),
                        action: {
                            if selectedToppings.contains(topping) {
                                selectedToppings.remove(topping)
                            } else {
                                selectedToppings.insert(topping)
                            }
                        }
                    )
                }
            }
        }
    }
    
    // MARK: - Bottom Bar
    private var bottomBar: some View {
        VStack(spacing: 0) {
            Divider()
                .background(ChageeTheme.Colors.divider)
            
            HStack {
                // Total price
                VStack(alignment: .leading, spacing: ChageeTheme.Spacing.xs) {
                    Text("Total")
                        .font(ChageeTheme.Typography.caption)
                        .foregroundColor(ChageeTheme.Colors.textSecondary)
                    
                    Text(formatPrice(calculateTotal()))
                        .font(ChageeTheme.Typography.price)
                        .foregroundColor(ChageeTheme.Colors.primaryGreen)
                }
                
                Spacer()
                
                // Add to cart button
                Button(action: addToCart) {
                    HStack {
                        Image(systemName: "cart.badge.plus")
                        Text("Add to Cart")
                    }
                    .font(ChageeTheme.Typography.callout)
                    .foregroundColor(.white)
                    .padding(.horizontal, ChageeTheme.Spacing.xl)
                    .padding(.vertical, ChageeTheme.Spacing.md)
                    .background(ChageeTheme.Colors.primaryGreen)
                    .cornerRadius(ChageeTheme.Radius.full)
                }
            }
            .padding(ChageeTheme.Spacing.lg)
        }
        .background(ChageeTheme.Colors.surface)
    }
    
    // MARK: - Helper Methods
    private func calculateTotal() -> Double {
        var total = item.price
        
        // Add size price
        if let size = selectedSize {
            total += size.price
        }
        
        // Add toppings prices
        for topping in selectedToppings {
            total += topping.price
        }
        
        return total
    }
    
    private func formatPrice(_ price: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        return formatter.string(from: NSNumber(value: price)) ?? "$\(String(format: "%.2f", price))"
    }
    
    private func addToCart() {
        let orderItem = OrderItem(
            id: UUID(),
            name: item.name,
            size: selectedSize?.label ?? "Regular",
            sugar: selectedSugar,
            ice: selectedIce,
            toppings: Array(selectedToppings).map { $0.label },
            sizePrice: selectedSize?.price ?? 0,
            toppingPrices: Array(selectedToppings).map { $0.price },
            price: calculateTotal()
        )
        
        onAddToCart(orderItem)
    }
}

// MARK: - Supporting Views
struct SizeOptionButton: View {
    let size: SizeOption
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: ChageeTheme.Spacing.sm) {
                Image(systemName: isSelected ? "cup.and.saucer.fill" : "cup.and.saucer")
                    .font(.system(size: 32))
                    .foregroundColor(isSelected ? ChageeTheme.Colors.primaryGreen : ChageeTheme.Colors.textSecondary)
                
                Text(size.label)
                    .font(ChageeTheme.Typography.callout)
                    .foregroundColor(isSelected ? ChageeTheme.Colors.primaryGreen : ChageeTheme.Colors.text)
                
                Text(size.formattedPrice)
                    .font(ChageeTheme.Typography.caption)
                    .foregroundColor(ChageeTheme.Colors.textSecondary)
            }
            .frame(maxWidth: .infinity)
            .padding(ChageeTheme.Spacing.md)
            .background(isSelected ? ChageeTheme.Colors.primaryGreen.opacity(0.1) : ChageeTheme.Colors.surface)
            .cornerRadius(ChageeTheme.Radius.md)
            .overlay(
                RoundedRectangle(cornerRadius: ChageeTheme.Radius.md)
                    .stroke(isSelected ? ChageeTheme.Colors.primaryGreen : ChageeTheme.Colors.divider, lineWidth: 1.5)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct CustomizationChip: View {
    let label: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(label)
                .font(ChageeTheme.Typography.callout)
                .foregroundColor(isSelected ? .white : ChageeTheme.Colors.text)
                .padding(.horizontal, ChageeTheme.Spacing.md)
                .padding(.vertical, ChageeTheme.Spacing.sm)
                .background(isSelected ? ChageeTheme.Colors.primaryGreen : ChageeTheme.Colors.surface)
                .cornerRadius(ChageeTheme.Radius.full)
                .overlay(
                    RoundedRectangle(cornerRadius: ChageeTheme.Radius.full)
                        .stroke(isSelected ? ChageeTheme.Colors.primaryGreen : ChageeTheme.Colors.divider, lineWidth: 1)
                )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct ToppingOptionButton: View {
    let topping: ToppingOption
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                VStack(alignment: .leading, spacing: ChageeTheme.Spacing.xs) {
                    Text(topping.label)
                        .font(ChageeTheme.Typography.callout)
                        .foregroundColor(ChageeTheme.Colors.text)
                    
                    Text(topping.formattedPrice)
                        .font(ChageeTheme.Typography.caption)
                        .foregroundColor(ChageeTheme.Colors.textSecondary)
                }
                
                Spacer()
                
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(isSelected ? ChageeTheme.Colors.primaryGreen : ChageeTheme.Colors.divider)
            }
            .padding(ChageeTheme.Spacing.md)
            .background(isSelected ? ChageeTheme.Colors.primaryGreen.opacity(0.05) : ChageeTheme.Colors.surface)
            .cornerRadius(ChageeTheme.Radius.sm)
            .overlay(
                RoundedRectangle(cornerRadius: ChageeTheme.Radius.sm)
                    .stroke(isSelected ? ChageeTheme.Colors.primaryGreen : ChageeTheme.Colors.divider, lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - View Model
@MainActor
class CustomizeOrderViewModel: ObservableObject {
    @Published var sizes: [SizeOption] = []
    @Published var toppings: [ToppingOption] = []
    
    func loadOptions() async {
        do {
            // Load sizes
            sizes = try await SupabaseService.fetchSizes()
            
            // Load toppings
            toppings = try await SupabaseService.fetchToppings()
        } catch {
            print("Error loading customization options: \(error)")
        }
    }
}