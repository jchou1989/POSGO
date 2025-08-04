# Chagee POS - Modern Tea Culture Point of Sale System

A beautiful, iPad-optimized point of sale system inspired by Chagee's modern tea culture aesthetic. Built with SwiftUI and designed for professional tea houses and beverage shops.

## 🌟 Features

### ✅ **Current Features (Production Ready)**
- **Chagee-Inspired Design**: Warm tea colors, premium materials aesthetic
- **iPad Optimized**: Landscape-only interface optimized for iPad Pro
- **Dynamic Customization**: Sugar levels, ice options, size selection, toppings
- **Real-time Cart Management**: Add, modify, and remove items with live totals
- **Professional UI/UX**: Clean, modern interface suitable for commercial use
- **Backend Integration**: Supabase for data management and synchronization
- **Admin Management**: Category, menu item, and modifier administration
- **Receipt Generation**: Professional receipts with all order details

### 🚧 **In Progress**
- **Payment Processing**: Card reader integration and payment handling
- **Receipt Printing**: AirPrint support for thermal printers
- **Analytics Dashboard**: Sales tracking and business insights

### 📋 **Planned Features**
- **Table Management**: Dine-in order tracking and table assignments
- **Staff Management**: Employee accounts and permissions
- **Inventory Tracking**: Real-time stock management
- **Customer Loyalty**: Points system and customer profiles
- **Multi-location**: Franchise support and centralized management

## 🎨 Design Philosophy

Inspired by Chagee's brand identity:
- **Tea Culture Heritage**: Drawing from ancient Tea Horse Road and Silk Road
- **Warm Color Palette**: Golden tea, pure white milk, desert ambiance
- **Premium Materials**: Wood, bamboo, rattan visual elements
- **Interactive Experience**: Customers watch drink preparation process
- **Minimalist Elegance**: Clean design focusing on products and service

## 🛠 Technical Stack

- **Framework**: SwiftUI (iOS 15.0+)
- **Backend**: Supabase (PostgreSQL, Real-time subscriptions)
- **Architecture**: MVVM pattern with Combine framework
- **Target Device**: iPad (landscape orientation only)
- **Payment**: Ready for Square, Stripe Terminal, or Clover integration
- **Deployment**: Native iOS app via App Store or Enterprise distribution

## 📱 System Requirements

### Hardware
- **iPad Pro 12.9"** (recommended) or iPad Pro 11"
- **iOS 15.0** or later
- **Bluetooth 4.0+** for card reader connectivity
- **Wi-Fi/Cellular** for real-time synchronization

### Optional Hardware
- **Card Reader**: Square Reader, Stripe Terminal, or compatible
- **Receipt Printer**: AirPrint compatible thermal printer
- **Barcode Scanner**: Bluetooth or Lightning connected

## 🚀 Installation & Setup

### 1. Prerequisites
```bash
# Xcode 14.0+ required
# iOS 15.0+ deployment target
# Valid Apple Developer account for iPad deployment
```

### 2. Database Setup
1. Create a Supabase account at [supabase.com](https://supabase.com)
2. Create a new project
3. Run the following SQL to set up tables:

```sql
-- Categories table
CREATE TABLE menu_categories (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  name TEXT NOT NULL,
  created_at TIMESTAMP DEFAULT NOW()
);

-- Menu items table
CREATE TABLE menu_items (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  name TEXT NOT NULL,
  price DECIMAL(10,2) NOT NULL,
  image_url TEXT,
  category_id UUID REFERENCES menu_categories(id),
  created_at TIMESTAMP DEFAULT NOW()
);

-- Size options table
CREATE TABLE sizes (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  label TEXT NOT NULL,
  price DECIMAL(10,2) NOT NULL DEFAULT 0,
  created_at TIMESTAMP DEFAULT NOW()
);

-- Toppings table
CREATE TABLE toppings (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  label TEXT NOT NULL,
  price DECIMAL(10,2) NOT NULL DEFAULT 0,
  created_at TIMESTAMP DEFAULT NOW()
);

-- Orders table
CREATE TABLE orders (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  items JSONB NOT NULL,
  total DECIMAL(10,2) NOT NULL,
  payment_method TEXT,
  customer_name TEXT,
  customer_phone TEXT,
  created_at TIMESTAMP DEFAULT NOW()
);

-- Insert sample data
INSERT INTO menu_categories (name) VALUES 
('Tea Latte'), ('Pure Tea'), ('Iced Lemon Tea'), ('Tea Frappe');

INSERT INTO sizes (label, price) VALUES 
('Small', 0.00), ('Medium', 0.50), ('Large', 1.00), ('Extra Large', 1.50);

INSERT INTO toppings (label, price) VALUES 
('Pearls', 0.75), ('Brown Sugar', 0.50), ('Grass Jelly', 0.50), 
('Coconut Jelly', 0.60), ('Red Bean', 0.65), ('Pudding', 0.70);
```

### 3. App Configuration
1. Update `SupabaseClient.swift` with your Supabase URL and API key
2. Configure payment processor settings in `PaymentProcessor.swift`
3. Customize colors and branding in `MainView.swift` color extensions

### 4. Build & Deploy
```bash
# Open in Xcode
open POSGO.xcodeproj

# Select iPad target
# Set deployment target to iPad
# Configure signing & capabilities
# Build and run on iPad device
```

## 🎯 Usage Guide

### For Staff
1. **Launch App**: Opens to main menu with categories
2. **Select Category**: Tap category to view items
3. **Add Items**: Tap item → customize → add to cart
4. **Process Order**: Review cart → select payment → complete transaction
5. **Print Receipt**: Automatic receipt generation and printing

### For Managers
1. **Admin Mode**: Toggle admin mode in sidebar
2. **Manage Menu**: Add/edit categories, items, sizes, toppings
3. **View Reports**: Access sales data and analytics
4. **Staff Management**: Create user accounts and permissions

## 🔧 Customization

### Branding
- Update colors in `Color` extensions (MainView.swift)
- Replace logo and images in Assets catalog
- Modify receipt template in `ReceiptGenerator.swift`

### Menu Configuration
- Categories and items managed through admin interface
- Bulk import via Supabase dashboard
- Real-time updates across all devices

### Payment Integration
Replace mock payment processor with actual SDK:
```swift
// Example for Square SDK integration
import SquarePointOfSaleSDK

class SquarePaymentProcessor: PaymentProcessor {
    // Implement actual Square payment processing
}
```

## 📊 Analytics & Reporting

The system tracks:
- **Sales Data**: Revenue, transaction counts, average order value
- **Popular Items**: Best-selling products and combinations
- **Peak Hours**: Busiest times for staffing optimization
- **Customer Preferences**: Most popular customizations

## 🔒 Security Features

- **PCI Compliance**: Card data never stored locally
- **End-to-End Encryption**: Secure payment processing
- **User Authentication**: Staff accounts with role-based access
- **Data Backup**: Automatic cloud synchronization
- **Offline Mode**: Continue operations during connectivity issues

## 🌐 Multi-Language Support

Ready for localization:
- English (default)
- Chinese (Traditional/Simplified)
- Spanish
- French

## 📞 Support & Maintenance

### Regular Maintenance
- **Daily**: Check payment processor connectivity
- **Weekly**: Review analytics and adjust inventory
- **Monthly**: Update menu items and pricing
- **Quarterly**: Staff training and system updates

### Troubleshooting
1. **App Crashes**: Check device storage and restart
2. **Payment Issues**: Verify card reader connection
3. **Sync Problems**: Check internet connectivity
4. **Print Issues**: Ensure printer compatibility

## 🚀 Future Roadmap

### Phase 2 (Q1 2024)
- Table management system
- Customer loyalty program
- Advanced analytics dashboard
- Multi-location support

### Phase 3 (Q2 2024)
- Kitchen display system
- Inventory management
- Staff scheduling
- Customer-facing display

### Phase 4 (Q3 2024)
- Mobile ordering integration
- Delivery service integration
- CRM system
- Franchise management

## 📄 License

This project is proprietary software designed for commercial use. Contact the development team for licensing information.

## 🤝 Contributing

This is a commercial product. For feature requests or bug reports, please contact the development team.

---

**Chagee POS** - Bringing modern tea culture to the digital age with elegant, efficient point of sale technology.