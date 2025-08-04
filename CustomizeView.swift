import SwiftUI

struct CustomizeView: View {
    @StateObject private var viewModel = CustomizeViewModel()
    @Environment(\.dismiss) private var dismiss
    let menuItem: MenuItem
    var onAddToCart: (OrderItem) -> Void
    
    // Sugar and Ice options
    private let sugarOptions = ["0%", "25%", "50%", "75%", "100%", "Extra Sweet"]
    private let iceOptions = ["No Ice", "Less Ice", "Normal Ice", "Extra Ice"]
    
    var body: some View {
        NavigationView {
            HStack(spacing: 0) {
                // Left Panel - Item Details & Image
                VStack(spacing: 0) {
                    // Item Header
                    VStack(spacing: 16) {
                        // Item Image
                        RoundedRectangle(cornerRadius: 20)
                            .fill(LinearGradient(
                                colors: [Color.teaGold.opacity(0.3), Color.teaBrown.opacity(0.2)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ))
                            .frame(width: 200, height: 200)
                            .overlay(
                                Image(systemName: "cup.and.saucer.fill")
                                    .font(.system(size: 48))
                                    .foregroundColor(.teaBrown.opacity(0.6))
                            )
                        
                        VStack(spacing: 8) {
                            Text(menuItem.name)
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(.teaBrown)
                                .multilineTextAlignment(.center)
                            
                            Text("Customize your perfect drink")
                                .font(.subheadline)
                                .foregroundColor(.teaBrown.opacity(0.7))
                        }
                    }
                    .padding(.top, 40)
                    .padding(.horizontal, 32)
                    
                    Spacer()
                    
                    // Price Summary
                    VStack(spacing: 16) {
                        Divider()
                            .background(Color.teaBrown.opacity(0.2))
                        
                        VStack(spacing: 8) {
                            HStack {
                                Text("Base Price")
                                    .foregroundColor(.teaBrown.opacity(0.7))
                                Spacer()
                                Text("$\(String(format: "%.2f", menuItem.price))")
                                    .foregroundColor(.teaBrown)
                            }
                            
                            if let selectedSize = viewModel.selectedSize, selectedSize.price > 0 {
                                HStack {
                                    Text("Size Upgrade")
                                        .foregroundColor(.teaBrown.opacity(0.7))
                                    Spacer()
                                    Text("+$\(String(format: "%.2f", selectedSize.price))")
                                        .foregroundColor(.teaGold)
                                }
                            }
                            
                            if !viewModel.selectedToppings.isEmpty {
                                HStack {
                                    Text("Toppings")
                                        .foregroundColor(.teaBrown.opacity(0.7))
                                    Spacer()
                                    Text("+$\(String(format: "%.2f", viewModel.toppingsTotal))")
                                        .foregroundColor(.teaGold)
                                }
                            }
                            
                            Divider()
                                .background(Color.teaBrown.opacity(0.2))
                            
                            HStack {
                                Text("Total")
                                    .font(.system(size: 18, weight: .bold))
                                    .foregroundColor(.teaBrown)
                                Spacer()
                                Text("$\(String(format: "%.2f", viewModel.totalPrice))")
                                    .font(.system(size: 20, weight: .bold))
                                    .foregroundColor(.teaGold)
                            }
                        }
                        .font(.system(size: 16))
                    }
                    .padding(.horizontal, 32)
                    .padding(.bottom, 32)
                }
                .frame(width: 320)
                .background(Color.teaCream)
                
                // Right Panel - Customization Options
                ScrollView {
                    VStack(spacing: 32) {
                        // Size Selection
                        CustomizationSection(title: "Size", icon: "cup.and.saucer") {
                            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                                ForEach(viewModel.sizes) { size in
                                    SizeOptionCard(
                                        size: size,
                                        isSelected: viewModel.selectedSize?.id == size.id
                                    ) {
                                        viewModel.selectedSize = size
                                    }
                                }
                            }
                        }
                        
                        // Sugar Level
                        CustomizationSection(title: "Sugar Level", icon: "cube.fill") {
                            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                                ForEach(sugarOptions, id: \.self) { option in
                                    OptionCard(
                                        title: option,
                                        isSelected: viewModel.selectedSugar == option
                                    ) {
                                        viewModel.selectedSugar = option
                                    }
                                }
                            }
                        }
                        
                        // Ice Level
                        CustomizationSection(title: "Ice Level", icon: "snowflake") {
                            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                                ForEach(iceOptions, id: \.self) { option in
                                    OptionCard(
                                        title: option,
                                        isSelected: viewModel.selectedIce == option
                                    ) {
                                        viewModel.selectedIce = option
                                    }
                                }
                            }
                        }
                        
                        // Toppings
                        CustomizationSection(title: "Toppings", icon: "plus.app") {
                            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                                ForEach(viewModel.toppings) { topping in
                                    ToppingCard(
                                        topping: topping,
                                        isSelected: viewModel.selectedToppings.contains(topping.id)
                                    ) {
                                        if viewModel.selectedToppings.contains(topping.id) {
                                            viewModel.selectedToppings.remove(topping.id)
                                        } else {
                                            viewModel.selectedToppings.insert(topping.id)
                                        }
                                    }
                                }
                            }
                        }
                        
                        // Quantity
                        CustomizationSection(title: "Quantity", icon: "number") {
                            HStack(spacing: 24) {
                                Button(action: { 
                                    if viewModel.quantity > 1 {
                                        viewModel.quantity -= 1
                                    }
                                }) {
                                    Image(systemName: "minus.circle.fill")
                                        .font(.title2)
                                        .foregroundColor(viewModel.quantity > 1 ? .teaGold : .gray)
                                }
                                .disabled(viewModel.quantity <= 1)
                                
                                Text("\(viewModel.quantity)")
                                    .font(.title.bold())
                                    .foregroundColor(.teaBrown)
                                    .frame(width: 60)
                                
                                Button(action: { 
                                    if viewModel.quantity < 10 {
                                        viewModel.quantity += 1
                                    }
                                }) {
                                    Image(systemName: "plus.circle.fill")
                                        .font(.title2)
                                        .foregroundColor(viewModel.quantity < 10 ? .teaGold : .gray)
                                }
                                .disabled(viewModel.quantity >= 10)
                            }
                            .padding(.vertical, 16)
                        }
                    }
                    .padding(.horizontal, 32)
                    .padding(.vertical, 24)
                }
                .background(Color.softWhite)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(.teaBrown)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Add to Cart") {
                        addToCart()
                    }
                    .disabled(viewModel.selectedSize == nil)
                    .buttonStyle(PrimaryButtonStyle())
                }
            }
        }
        .task {
            await viewModel.loadModifiers()
            // Set default values
            viewModel.selectedSugar = "50%"
            viewModel.selectedIce = "Normal Ice"
        }
        .overlay {
            if viewModel.isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.black.opacity(0.2))
            }
        }
    }
    
    private func addToCart() {
        let orderItem = OrderItem(
            id: UUID(),
            name: menuItem.name,
            size: viewModel.selectedSize?.label ?? "",
            sugar: viewModel.selectedSugar,
            ice: viewModel.selectedIce,
            toppings: viewModel.selectedToppings.compactMap { id in
                viewModel.toppings.first { $0.id == id }?.label
            },
            sizePrice: viewModel.selectedSize?.price ?? 0,
            toppingPrices: viewModel.selectedToppings.compactMap { id in
                viewModel.toppings.first { $0.id == id }?.price
            },
            price: viewModel.totalPrice
        )
        
        for _ in 0..<viewModel.quantity {
            onAddToCart(orderItem)
        }
        
        dismiss()
    }
}

// MARK: - Customization Section
struct CustomizationSection<Content: View>: View {
    let title: String
    let icon: String
    let content: Content
    
    init(title: String, icon: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.icon = icon
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundColor(.teaGold)
                
                Text(title)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.teaBrown)
            }
            
            content
        }
    }
}

// MARK: - Size Option Card
struct SizeOptionCard: View {
    let size: SizeOption
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Text(size.label)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(isSelected ? .white : .teaBrown)
                
                if size.price > 0 {
                    Text("+$\(String(format: "%.2f", size.price))")
                        .font(.system(size: 14))
                        .foregroundColor(isSelected ? .white.opacity(0.9) : .teaGold)
                } else {
                    Text("Included")
                        .font(.system(size: 14))
                        .foregroundColor(isSelected ? .white.opacity(0.9) : .teaBrown.opacity(0.6))
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(isSelected ? Color.teaGold : Color.white)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color.clear : Color.teaBrown.opacity(0.2), lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Option Card
struct OptionCard: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(isSelected ? .white : .teaBrown)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(isSelected ? Color.teaGold : Color.white)
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(isSelected ? Color.clear : Color.teaBrown.opacity(0.2), lineWidth: 1)
                )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Topping Card
struct ToppingCard: View {
    let topping: ToppingOption
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Text(topping.label)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(isSelected ? .white : .teaBrown)
                    .multilineTextAlignment(.center)
                
                Text("+$\(String(format: "%.2f", topping.price))")
                    .font(.system(size: 12))
                    .foregroundColor(isSelected ? .white.opacity(0.9) : .teaGold)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(isSelected ? Color.teaGold : Color.white)
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(isSelected ? Color.clear : Color.teaBrown.opacity(0.2), lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Primary Button Style
struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 16, weight: .semibold))
            .foregroundColor(.white)
            .padding(.horizontal, 24)
            .padding(.vertical, 12)
            .background(Color.teaGold)
            .cornerRadius(12)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

#Preview {
    CustomizeView(
        menuItem: MenuItem(
            id: UUID(),
            name: "Premium Jasmine Tea Latte",
            price: 4.99,
            category_id: UUID()
        ),
        onAddToCart: { _ in }
    )
}
