import Foundation

// MARK: - Production Sample Data
struct ProductionData {
    
    // MARK: - Default User Credentials
    static let defaultUsers: [Employee] = [
        Employee(id: UUID(uuidString: "550e8400-e29b-41d4-a716-446655440001")!, name: "Ahmed Al-Rashid", role: .cashier),
        Employee(id: UUID(uuidString: "550e8400-e29b-41d4-a716-446655440002")!, name: "Fatima Hassan", role: .cashier),
        Employee(id: UUID(uuidString: "550e8400-e29b-41d4-a716-446655440003")!, name: "Omar Khalil", role: .manager),
        Employee(id: UUID(uuidString: "550e8400-e29b-41d4-a716-446655440004")!, name: "Layla Al-Zahra", role: .admin)
    ]
    
    // MARK: - Menu Categories
    static let defaultCategories: [MenuCategory] = [
        MenuCategory(id: UUID(uuidString: "660e8400-e29b-41d4-a716-446655440001")!, name: "Black Tea Series"),
        MenuCategory(id: UUID(uuidString: "660e8400-e29b-41d4-a716-446655440002")!, name: "Oolong Tea Series"),
        MenuCategory(id: UUID(uuidString: "660e8400-e29b-41d4-a716-446655440003")!, name: "Green Tea Series"),
        MenuCategory(id: UUID(uuidString: "660e8400-e29b-41d4-a716-446655440004")!, name: "Matcha Series"),
        MenuCategory(id: UUID(uuidString: "660e8400-e29b-41d4-a716-446655440005")!, name: "Taro Series"),
        MenuCategory(id: UUID(uuidString: "660e8400-e29b-41d4-a716-446655440006")!, name: "Wintermelon Series"),
        MenuCategory(id: UUID(uuidString: "660e8400-e29b-41d4-a716-446655440007")!, name: "Caffeine-free Series"),
        MenuCategory(id: UUID(uuidString: "660e8400-e29b-41d4-a716-446655440008")!, name: "Coffee Series")
    ]
    
    // MARK: - Menu Items (Based on Excel Data)
    static let defaultMenuItems: [MenuItem] = [
        // Black Tea Series
        MenuItem(id: UUID(uuidString: "770e8400-e29b-41d4-a716-446655440001")!, name: "Fragrant Black Tea", price: 12.00, imageURL: "black-tea", category_id: UUID(uuidString: "660e8400-e29b-41d4-a716-446655440001")!),
        MenuItem(id: UUID(uuidString: "770e8400-e29b-41d4-a716-446655440002")!, name: "Brown Sugar Pearl Milk Tea", price: 18.00, imageURL: "brown-sugar-pearl", category_id: UUID(uuidString: "660e8400-e29b-41d4-a716-446655440001")!),
        MenuItem(id: UUID(uuidString: "770e8400-e29b-41d4-a716-446655440003")!, name: "Iced Lemon Tea", price: 15.00, imageURL: "iced-lemon-tea", category_id: UUID(uuidString: "660e8400-e29b-41d4-a716-446655440001")!),
        MenuItem(id: UUID(uuidString: "770e8400-e29b-41d4-a716-446655440004")!, name: "Black Tea Latte", price: 16.00, imageURL: "black-tea-latte", category_id: UUID(uuidString: "660e8400-e29b-41d4-a716-446655440001")!),
        
        // Oolong Tea Series
        MenuItem(id: UUID(uuidString: "770e8400-e29b-41d4-a716-446655440005")!, name: "Oolong Tea Latte", price: 17.00, imageURL: "oolong-latte", category_id: UUID(uuidString: "660e8400-e29b-41d4-a716-446655440002")!),
        MenuItem(id: UUID(uuidString: "770e8400-e29b-41d4-a716-446655440006")!, name: "Oolong Tea", price: 13.00, imageURL: "oolong-tea", category_id: UUID(uuidString: "660e8400-e29b-41d4-a716-446655440002")!),
        
        // Green Tea Series
        MenuItem(id: UUID(uuidString: "770e8400-e29b-41d4-a716-446655440007")!, name: "Pomegranate Green Tea", price: 16.00, imageURL: "pomegranate-green", category_id: UUID(uuidString: "660e8400-e29b-41d4-a716-446655440003")!),
        MenuItem(id: UUID(uuidString: "770e8400-e29b-41d4-a716-446655440008")!, name: "Passionfruit Green Tea", price: 16.00, imageURL: "passionfruit-green", category_id: UUID(uuidString: "660e8400-e29b-41d4-a716-446655440003")!),
        MenuItem(id: UUID(uuidString: "770e8400-e29b-41d4-a716-446655440009")!, name: "Green Milk Tea", price: 15.00, imageURL: "green-milk-tea", category_id: UUID(uuidString: "660e8400-e29b-41d4-a716-446655440003")!),
        MenuItem(id: UUID(uuidString: "770e8400-e29b-41d4-a716-446655440010")!, name: "Green Tea Latte", price: 17.00, imageURL: "green-tea-latte", category_id: UUID(uuidString: "660e8400-e29b-41d4-a716-446655440003")!),
        MenuItem(id: UUID(uuidString: "770e8400-e29b-41d4-a716-446655440011")!, name: "Green Tea", price: 12.00, imageURL: "green-tea", category_id: UUID(uuidString: "660e8400-e29b-41d4-a716-446655440003")!),
        
        // Matcha Series
        MenuItem(id: UUID(uuidString: "770e8400-e29b-41d4-a716-446655440012")!, name: "Matcha Milk Tea", price: 19.00, imageURL: "matcha-milk", category_id: UUID(uuidString: "660e8400-e29b-41d4-a716-446655440004")!),
        MenuItem(id: UUID(uuidString: "770e8400-e29b-41d4-a716-446655440013")!, name: "Matcha Tea", price: 15.00, imageURL: "matcha-tea", category_id: UUID(uuidString: "660e8400-e29b-41d4-a716-446655440004")!),
        MenuItem(id: UUID(uuidString: "770e8400-e29b-41d4-a716-446655440014")!, name: "Matcha Latte", price: 18.00, imageURL: "matcha-latte", category_id: UUID(uuidString: "660e8400-e29b-41d4-a716-446655440004")!),
        
        // Taro Series
        MenuItem(id: UUID(uuidString: "770e8400-e29b-41d4-a716-446655440015")!, name: "Da Jia", price: 20.00, imageURL: "da-jia", category_id: UUID(uuidString: "660e8400-e29b-41d4-a716-446655440005")!),
        MenuItem(id: UUID(uuidString: "770e8400-e29b-41d4-a716-446655440016")!, name: "Angel Summer", price: 21.00, imageURL: "angel-summer", category_id: UUID(uuidString: "660e8400-e29b-41d4-a716-446655440005")!),
        
        // Wintermelon Series
        MenuItem(id: UUID(uuidString: "770e8400-e29b-41d4-a716-446655440017")!, name: "Wintermelon Milk Tea", price: 16.00, imageURL: "wintermelon-milk", category_id: UUID(uuidString: "660e8400-e29b-41d4-a716-446655440006")!),
        MenuItem(id: UUID(uuidString: "770e8400-e29b-41d4-a716-446655440018")!, name: "Wintermelon Tea", price: 13.00, imageURL: "wintermelon-tea", category_id: UUID(uuidString: "660e8400-e29b-41d4-a716-446655440006")!),
        MenuItem(id: UUID(uuidString: "770e8400-e29b-41d4-a716-446655440019")!, name: "Wintermelon Tea With Sea Salt Foam", price: 19.00, imageURL: "wintermelon-sea-salt", category_id: UUID(uuidString: "660e8400-e29b-41d4-a716-446655440006")!),
        
        // Caffeine-free Series
        MenuItem(id: UUID(uuidString: "770e8400-e29b-41d4-a716-446655440020")!, name: "Black Bear", price: 18.00, imageURL: "black-bear", category_id: UUID(uuidString: "660e8400-e29b-41d4-a716-446655440007")!),
        MenuItem(id: UUID(uuidString: "770e8400-e29b-41d4-a716-446655440021")!, name: "The Duke", price: 17.00, imageURL: "the-duke", category_id: UUID(uuidString: "660e8400-e29b-41d4-a716-446655440007")!),
        
        // Coffee Series
        MenuItem(id: UUID(uuidString: "770e8400-e29b-41d4-a716-446655440022")!, name: "Dalgona Coffee", price: 22.00, imageURL: "dalgona-coffee", category_id: UUID(uuidString: "660e8400-e29b-41d4-a716-446655440008")!)
    ]
    
    // MARK: - Size Options
    static let defaultSizes: [SizeOption] = [
        SizeOption(id: UUID(uuidString: "880e8400-e29b-41d4-a716-446655440001")!, label: "Small", price: 0.0),
        SizeOption(id: UUID(uuidString: "880e8400-e29b-41d4-a716-446655440002")!, label: "Medium", price: 3.0),
        SizeOption(id: UUID(uuidString: "880e8400-e29b-41d4-a716-446655440003")!, label: "Large", price: 6.0)
    ]
    
    // MARK: - Topping Options
    static let defaultToppings: [ToppingOption] = [
        ToppingOption(id: UUID(uuidString: "990e8400-e29b-41d4-a716-446655440001")!, label: "Extra Shot", price: 5.0),
        ToppingOption(id: UUID(uuidString: "990e8400-e29b-41d4-a716-446655440002")!, label: "Whipped Cream", price: 2.0),
        ToppingOption(id: UUID(uuidString: "990e8400-e29b-41d4-a716-446655440003")!, label: "Caramel Syrup", price: 3.0),
        ToppingOption(id: UUID(uuidString: "990e8400-e29b-41d4-a716-446655440004")!, label: "Vanilla Syrup", price: 3.0),
        ToppingOption(id: UUID(uuidString: "990e8400-e29b-41d4-a716-446655440005")!, label: "Chocolate Syrup", price: 3.0),
        ToppingOption(id: UUID(uuidString: "990e8400-e29b-41d4-a716-446655440006")!, label: "Hazelnut Syrup", price: 3.0)
    ]
    
    // MARK: - Sugar Levels (Based on Excel Data)
    static let sugarLevels: [ModifierOption] = [
        ModifierOption(label: "Zero Sugar"),
        ModifierOption(label: "Less"),
        ModifierOption(label: "Recommende"),
        ModifierOption(label: "Extra")
    ]
    
    // MARK: - Ice Levels (Based on Excel Data)
    static let iceLevels: [ModifierOption] = [
        ModifierOption(label: "No Ice"),
        ModifierOption(label: "Less Ice"),
        ModifierOption(label: "Normal")
    ]
}

// MARK: - Currency Formatter for QAR
extension NumberFormatter {
    static let qarFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "QAR"
        formatter.currencySymbol = "QR "
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        return formatter
    }()
}

// MARK: - Price Formatting Extensions
extension MenuItem {
    var qarFormattedPrice: String {
        return NumberFormatter.qarFormatter.string(from: NSNumber(value: price)) ?? "QR \(String(format: "%.2f", price))"
    }
}

extension OrderItem {
    var qarFormattedPrice: String {
        return NumberFormatter.qarFormatter.string(from: NSNumber(value: price)) ?? "QR \(String(format: "%.2f", price))"
    }
} 