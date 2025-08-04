import SwiftUI

struct AdminView: View {
    @EnvironmentObject var authManager: AuthenticationManager
    @State private var selectedTab = 0
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header
                AdminHeaderView()
                
                // Tab selection
                AdminTabView(selectedTab: $selectedTab)
                
                // Content
                TabView(selection: $selectedTab) {
                    MenuManagementView()
                        .tag(0)
                    
                    CategoryManagementView()
                        .tag(1)
                    
                    SystemSettingsView()
                        .tag(2)
                    
                    ReportsView()
                        .tag(3)
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            }
            .navigationTitle("Admin")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Logout") {
                        authManager.logout()
                    }
                }
            }
        }
    }
}

// MARK: - Admin Header
struct AdminHeaderView: View {
    @EnvironmentObject var authManager: AuthenticationManager
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Administration")
                    .font(.title2.bold())
                Text("Manage your POS system")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text(authManager.currentUser?.name ?? "Admin")
                    .font(.subheadline.bold())
                Text(authManager.currentUser?.role.rawValue ?? "Administrator")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .shadow(color: .black.opacity(0.1), radius: 2, y: 1)
    }
}

// MARK: - Admin Tabs
struct AdminTabView: View {
    @Binding var selectedTab: Int
    
    private let tabs = [
        ("Menu", "list.bullet"),
        ("Categories", "folder"),
        ("Settings", "gear"),
        ("Reports", "chart.bar")
    ]
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(0..<tabs.count, id: \.self) { index in
                AdminTabButton(
                    title: tabs[index].0,
                    icon: tabs[index].1,
                    isSelected: selectedTab == index,
                    onTap: { selectedTab = index }
                )
            }
        }
        .background(Color(.systemGray6))
    }
}

struct AdminTabButton: View {
    let title: String
    let icon: String
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 20))
                Text(title)
                    .font(.caption)
            }
            .foregroundColor(isSelected ? .white : .primary)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(
                Rectangle()
                    .fill(isSelected ? Color.blue : Color.clear)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Menu Management
struct MenuManagementView: View {
    @State private var menuItems: [MenuItem] = []
    @State private var categories: [MenuCategory] = []
    @State private var showingAddItem = false
    @State private var selectedItem: MenuItem?
    @State private var isLoading = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("Menu Items")
                    .font(.title2.bold())
                Spacer()
                Button(action: { showingAddItem = true }) {
                    HStack {
                        Image(systemName: "plus")
                        Text("Add Item")
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color.blue)
                    .cornerRadius(8)
                }
            }
            .padding()
            
            // Menu items list
            if isLoading {
                LoadingView()
            } else {
                List(menuItems) { item in
                    MenuItemRowView(
                        item: item,
                        category: categories.first { $0.id == item.category_id }
                    ) {
                        selectedItem = item
                    }
                }
                .listStyle(PlainListStyle())
            }
        }
        .sheet(isPresented: $showingAddItem) {
            MenuItemEditorView(
                item: nil,
                categories: categories,
                onSave: { newItem in
                    // Handle save
                    print("Saving new item: \(newItem.name)")
                }
            )
        }
        .sheet(item: $selectedItem) { item in
            MenuItemEditorView(
                item: item,
                categories: categories,
                onSave: { updatedItem in
                    // Handle update
                    print("Updating item: \(updatedItem.name)")
                }
            )
        }
        .task {
            await loadData()
        }
    }
    
    private func loadData() async {
        isLoading = true
        do {
            categories = try await SupabaseService.fetchCategories()
            if let firstCategory = categories.first {
                menuItems = try await SupabaseService.fetchMenuItems(for: firstCategory.id)
            }
        } catch {
            print("Failed to load data: \(error)")
        }
        isLoading = false
    }
}

struct MenuItemRowView: View {
    let item: MenuItem
    let category: MenuCategory?
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 16) {
                // Item image placeholder
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color(.systemGray4))
                    .frame(width: 60, height: 60)
                    .overlay(
                        Image(systemName: "cup.and.saucer")
                            .foregroundColor(.gray)
                    )
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(item.name)
                        .font(.headline)
                    
                    if let category = category {
                        Text(category.name)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Text(item.formattedPrice)
                        .font(.subheadline.bold())
                        .foregroundColor(.blue)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.vertical, 4)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Category Management
struct CategoryManagementView: View {
    @State private var categories: [MenuCategory] = []
    @State private var showingAddCategory = false
    @State private var selectedCategory: MenuCategory?
    @State private var isLoading = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("Categories")
                    .font(.title2.bold())
                Spacer()
                Button(action: { showingAddCategory = true }) {
                    HStack {
                        Image(systemName: "plus")
                        Text("Add Category")
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color.blue)
                    .cornerRadius(8)
                }
            }
            .padding()
            
            // Categories list
            if isLoading {
                LoadingView()
            } else {
                List(categories) { category in
                    CategoryRowView(category: category) {
                        selectedCategory = category
                    }
                }
                .listStyle(PlainListStyle())
            }
        }
        .sheet(isPresented: $showingAddCategory) {
            CategoryEditorView(
                category: nil,
                onSave: { newCategory in
                    // Handle save
                    print("Saving new category: \(newCategory.name)")
                }
            )
        }
        .sheet(item: $selectedCategory) { category in
            CategoryEditorView(
                category: category,
                onSave: { updatedCategory in
                    // Handle update
                    print("Updating category: \(updatedCategory.name)")
                }
            )
        }
        .task {
            await loadCategories()
        }
    }
    
    private func loadCategories() async {
        isLoading = true
        do {
            categories = try await SupabaseService.fetchCategories()
        } catch {
            print("Failed to load categories: \(error)")
        }
        isLoading = false
    }
}

struct CategoryRowView: View {
    let category: MenuCategory
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack {
                Image(systemName: "folder.fill")
                    .font(.title2)
                    .foregroundColor(.blue)
                    .frame(width: 40)
                
                Text(category.name)
                    .font(.headline)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.vertical, 4)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - System Settings
struct SystemSettingsView: View {
    @State private var settings = SystemSettings()
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // General Settings
                SettingsSection(title: "General") {
                    SettingsRow(
                        title: "Store Name",
                        value: $settings.storeName
                    )
                    
                    SettingsRow(
                        title: "Tax Rate (%)",
                        value: Binding(
                            get: { String(format: "%.1f", settings.taxRate * 100) },
                            set: { newValue in
                                if let rate = Double(newValue) {
                                    settings.taxRate = rate / 100
                                }
                            }
                        )
                    )
                    
                    SettingsRow(
                        title: "Currency",
                        value: $settings.currency
                    )
                }
                
                // Receipt Settings
                SettingsSection(title: "Receipt") {
                    SettingsRow(
                        title: "Header Text",
                        value: $settings.receiptHeader
                    )
                    
                    SettingsRow(
                        title: "Footer Text",
                        value: $settings.receiptFooter
                    )
                    
                    Toggle("Show Logo", isOn: $settings.showLogoOnReceipt)
                        .padding(.horizontal)
                }
                
                // Payment Settings
                SettingsSection(title: "Payment") {
                    Toggle("Accept Cash", isOn: $settings.acceptCash)
                        .padding(.horizontal)
                    
                    Toggle("Accept Cards", isOn: $settings.acceptCards)
                        .padding(.horizontal)
                    
                    Toggle("Accept Mobile Payments", isOn: $settings.acceptMobilePayments)
                        .padding(.horizontal)
                }
                
                // Save Button
                Button(action: saveSettings) {
                    Text("Save Settings")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(12)
                }
                .padding(.horizontal)
            }
            .padding()
        }
    }
    
    private func saveSettings() {
        // Implement settings save
        print("Saving settings: \(settings)")
    }
}

struct SettingsSection<Content: View>: View {
    let title: String
    let content: Content
    
    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.headline)
                .padding(.horizontal)
            
            VStack(spacing: 0) {
                content
            }
            .background(Color(.systemBackground))
            .cornerRadius(12)
        }
    }
}

struct SettingsRow: View {
    let title: String
    @Binding var value: String
    
    var body: some View {
        HStack {
            Text(title)
                .font(.subheadline)
            
            Spacer()
            
            TextField("Enter value", text: $value)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .frame(width: 150)
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
    }
}

// MARK: - Reports View
struct ReportsView: View {
    @State private var selectedReport: ReportType = .sales
    @State private var dateRange: DateRange = .today
    
    var body: some View {
        VStack(spacing: 20) {
            // Report Type Selector
            Picker("Report Type", selection: $selectedReport) {
                ForEach(ReportType.allCases, id: \.self) { report in
                    Text(report.displayName).tag(report)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding(.horizontal)
            
            // Date Range Selector
            Picker("Date Range", selection: $dateRange) {
                ForEach(DateRange.allCases, id: \.self) { range in
                    Text(range.displayName).tag(range)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding(.horizontal)
            
            // Report Content
            ScrollView {
                VStack(spacing: 20) {
                    ReportSummaryView(reportType: selectedReport, dateRange: dateRange)
                    
                    ReportChartView(reportType: selectedReport, dateRange: dateRange)
                    
                    ReportDetailsView(reportType: selectedReport, dateRange: dateRange)
                }
                .padding()
            }
        }
        .navigationTitle("Reports")
    }
}

struct ReportSummaryView: View {
    let reportType: ReportType
    let dateRange: DateRange
    
    var body: some View {
        VStack(spacing: 16) {
            Text("Summary")
                .font(.headline)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 16) {
                SummaryCard(
                    title: "Total Sales",
                    value: "$1,234.56",
                    color: .green
                )
                
                SummaryCard(
                    title: "Orders",
                    value: "45",
                    color: .blue
                )
                
                SummaryCard(
                    title: "Average Order",
                    value: "$27.43",
                    color: .orange
                )
                
                SummaryCard(
                    title: "Items Sold",
                    value: "123",
                    color: .purple
                )
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
    }
}

struct SummaryCard: View {
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            
            Text(value)
                .font(.title2.bold())
                .foregroundColor(color)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(color.opacity(0.1))
        .cornerRadius(8)
    }
}

struct ReportChartView: View {
    let reportType: ReportType
    let dateRange: DateRange
    
    var body: some View {
        VStack(spacing: 16) {
            Text("Chart")
                .font(.headline)
            
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemGray5))
                .frame(height: 200)
                .overlay(
                    VStack {
                        Image(systemName: "chart.bar.fill")
                            .font(.system(size: 40))
                            .foregroundColor(.gray)
                        Text("Chart visualization")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                )
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
    }
}

struct ReportDetailsView: View {
    let reportType: ReportType
    let dateRange: DateRange
    
    var body: some View {
        VStack(spacing: 16) {
            Text("Details")
                .font(.headline)
            
            VStack(spacing: 8) {
                ForEach(1...5, id: \.self) { index in
                    HStack {
                        Text("Item \(index)")
                        Spacer()
                        Text("$\(Double(index) * 10.0, specifier: "%.2f")")
                            .font(.subheadline.bold())
                    }
                    .padding(.vertical, 4)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
    }
}

// MARK: - Supporting Models
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

enum ReportType: String, CaseIterable {
    case sales = "sales"
    case orders = "orders"
    case items = "items"
    case customers = "customers"
    
    var displayName: String {
        switch self {
        case .sales: return "Sales"
        case .orders: return "Orders"
        case .items: return "Items"
        case .customers: return "Customers"
        }
    }
}

enum DateRange: String, CaseIterable {
    case today = "today"
    case week = "week"
    case month = "month"
    case year = "year"
    
    var displayName: String {
        switch self {
        case .today: return "Today"
        case .week: return "This Week"
        case .month: return "This Month"
        case .year: return "This Year"
        }
    }
}

#Preview {
    AdminView()
        .environmentObject(AuthenticationManager())
}