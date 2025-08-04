# POS GO - Production-Ready iPad POS System

A modern, iPad-optimized Point of Sale system built with SwiftUI, designed for coffee shops and quick-service restaurants. Inspired by Chagee's POS design patterns and optimized for iPad deployment.

## 🚀 Features

### Core POS Functionality
- **iPad-Optimized UI**: Large touch-friendly buttons and split-screen layouts
- **Real-time Menu Management**: Dynamic category and item management
- **Advanced Cart System**: Customizable items with modifiers (size, sugar, ice, toppings)
- **Multiple Payment Methods**: Cash, card, mobile payments, and gift cards
- **Receipt Generation**: Professional receipt printing and digital copies
- **Order Management**: Complete order lifecycle tracking

### Authentication & Security
- **Role-based Access**: Cashier, Manager, and Admin roles
- **Secure Authentication**: Employee login system
- **Session Management**: Automatic logout and session handling

### Admin & Management
- **Menu Management**: Add, edit, and organize menu items and categories
- **System Settings**: Configurable tax rates, currency, and receipt settings
- **Sales Reports**: Comprehensive reporting and analytics
- **Inventory Tracking**: Basic inventory management capabilities

### Technical Features
- **Offline Support**: Local data caching and offline functionality
- **Real-time Sync**: Supabase backend integration
- **Responsive Design**: Optimized for iPad in both portrait and landscape
- **Performance Optimized**: Efficient data loading and caching

## 📱 iPad Optimization

### Design Principles
- **Large Touch Targets**: Minimum 44pt touch areas for all interactive elements
- **Split-Screen Layout**: Menu on left, cart on right for efficient workflow
- **High Contrast**: Clear visual hierarchy and readable fonts
- **Gesture Support**: Swipe gestures and iPad-specific interactions

### Layout Features
- **Adaptive Grid**: Responsive menu item grid that adapts to screen size
- **Floating Cart**: Persistent cart sidebar with real-time updates
- **Quick Actions**: Shortcut buttons for common operations
- **Status Indicators**: Clear visual feedback for all system states

## 🏗️ Architecture

### MVVM Pattern
```
├── Models/
│   ├── OrderItem.swift
│   ├── MenuItem.swift
│   ├── MenuCategory.swift
│   └── PaymentTransaction.swift
├── Views/
│   ├── POSView.swift
│   ├── PaymentView.swift
│   ├── OrdersView.swift
│   └── AdminView.swift
├── ViewModels/
│   ├── CartViewModel.swift
│   ├── PaymentManager.swift
│   └── AuthenticationManager.swift
└── Services/
    └── SupabaseService.swift
```

### Key Components

#### AppState
Central state management for:
- Cart management with local persistence
- Offline/online status tracking
- User session management

#### AuthenticationManager
Handles:
- Employee authentication
- Role-based access control
- Session management

#### PaymentManager
Manages:
- Multiple payment method processing
- Transaction recording
- Receipt generation

## 🛠️ Installation & Setup

### Prerequisites
- Xcode 15.0+
- iOS 17.0+
- iPad with iPadOS 17.0+
- Supabase account and project

### Setup Instructions

1. **Clone the Repository**
   ```bash
   git clone <repository-url>
   cd POSGO
   ```

2. **Install Dependencies**
   ```bash
   # Dependencies are managed through Swift Package Manager
   # Add the following packages in Xcode:
   # - Supabase Swift
   # - PostgREST
   ```

3. **Configure Supabase**
   - Create a new Supabase project
   - Set up the database schema (see Database Schema section)
   - Update `SupabaseClient.swift` with your project credentials

4. **Build and Run**
   - Open `POSGO.xcodeproj` in Xcode
   - Select iPad as the target device
   - Build and run the project

### Database Schema

```sql
-- Menu Categories
CREATE TABLE menu_categories (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Menu Items
CREATE TABLE menu_items (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL,
    price DECIMAL(10,2) NOT NULL,
    category_id UUID REFERENCES menu_categories(id),
    image_url TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Orders
CREATE TABLE orders (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    items JSONB NOT NULL,
    total DECIMAL(10,2) NOT NULL,
    status TEXT DEFAULT 'pending',
    payment_method TEXT,
    payment_status TEXT DEFAULT 'pending',
    customer_name TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Employees
CREATE TABLE employees (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL,
    role TEXT NOT NULL,
    username TEXT UNIQUE NOT NULL,
    password_hash TEXT NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
```

## 🚀 Deployment

### iPad Deployment Options

#### 1. App Store Distribution
- Archive the project in Xcode
- Upload to App Store Connect
- Submit for review and distribution

#### 2. Enterprise Distribution
- Configure enterprise provisioning profile
- Build and distribute via MDM solution
- Deploy to managed iPads

#### 3. Ad Hoc Distribution
- Create ad hoc provisioning profile
- Build and distribute to specific devices
- Install via iTunes or Apple Configurator

### Production Checklist

#### Security
- [ ] Enable App Transport Security
- [ ] Configure proper API keys and secrets
- [ ] Implement certificate pinning
- [ ] Set up proper authentication flow

#### Performance
- [ ] Optimize image assets for iPad
- [ ] Implement proper caching strategies
- [ ] Test with large datasets
- [ ] Monitor memory usage

#### Testing
- [ ] Test on various iPad models
- [ ] Verify offline functionality
- [ ] Test payment processing
- [ ] Validate receipt printing

## 📊 Usage Guide

### Cashier Workflow
1. **Login**: Enter employee credentials
2. **Select Items**: Browse categories and add items to cart
3. **Customize**: Modify items with size, sugar, ice, and toppings
4. **Checkout**: Process payment and generate receipt
5. **Complete**: Order is saved and cart is cleared

### Manager Workflow
1. **Access Admin**: Login with manager credentials
2. **Manage Menu**: Add/edit menu items and categories
3. **View Reports**: Access sales and order analytics
4. **System Settings**: Configure tax rates and receipt settings

### Admin Workflow
1. **Full Access**: All manager capabilities plus:
2. **Employee Management**: Add/edit employee accounts
3. **System Configuration**: Advanced settings and integrations
4. **Data Management**: Export and backup functionality

## 🔧 Configuration

### System Settings
```swift
struct SystemSettings {
    var storeName = "POS GO"
    var taxRate: Double = 0.08
    var currency = "USD"
    var receiptHeader = "Thank you for your purchase!"
    var receiptFooter = "Please come again!"
    var showLogoOnReceipt = true
    var acceptCash = true
    var acceptCards = true
    var acceptMobilePayments = true
}
```

### Payment Methods
- **Cash**: Manual cash handling with change calculation
- **Card**: Credit/debit card processing
- **Mobile**: Apple Pay, Google Pay integration
- **Gift Card**: Gift card redemption system

## 🐛 Troubleshooting

### Common Issues

#### Build Errors
- Ensure all Swift Package Manager dependencies are resolved
- Check that iOS deployment target is set to 17.0+
- Verify iPad-specific settings in project configuration

#### Runtime Issues
- Check Supabase connection and credentials
- Verify network connectivity for online features
- Test offline functionality when network is unavailable

#### Performance Issues
- Monitor memory usage with large menus
- Optimize image loading and caching
- Check for memory leaks in long-running sessions

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests for new functionality
5. Submit a pull request

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🆘 Support

For support and questions:
- Create an issue in the GitHub repository
- Contact the development team
- Check the documentation and troubleshooting guide

## 🔮 Future Enhancements

### Planned Features
- **Inventory Management**: Advanced stock tracking
- **Customer Loyalty**: Points and rewards system
- **Multi-location Support**: Chain store management
- **Advanced Analytics**: Machine learning insights
- **Third-party Integrations**: Accounting and CRM systems

### Technical Improvements
- **Real-time Updates**: WebSocket integration
- **Offline Sync**: Improved offline/online synchronization
- **Performance Optimization**: Further iPad optimization
- **Accessibility**: Enhanced accessibility features

---

**POS GO** - Modern POS for the iPad era. Built with ❤️ using SwiftUI.