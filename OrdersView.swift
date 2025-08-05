import SwiftUI

struct OrdersView: View {
    @State private var orders: [OrderRecord] = []
    @State private var selectedFilter: OrderFilter = .all
    @State private var isLoading = false
    @State private var errorMessage = ""
    @State private var showError = false
    
    var filteredOrders: [OrderRecord] {
        switch selectedFilter {
        case .all:
            return orders
        case .pending:
            return orders.filter { $0.status == .pending }
        case .completed:
            return orders.filter { $0.status == .completed }
        case .cancelled:
            return orders.filter { $0.status == .cancelled }
        }
    }
    
    var body: some View {
        NavigationView {
            HStack(spacing: 0) {
                // Left side - Orders List (40% width)
                VStack(spacing: 0) {
                    // Header with filters
                    VStack(spacing: 0) {
                        HStack {
                            Text("Orders")
                                .font(.title2.bold())
                            Spacer()
                            Button(action: refreshOrders) {
                                Image(systemName: "arrow.clockwise")
                                    .font(.title3)
                            }
                        }
                        .padding()
                        
                        OrderFilterView(selectedFilter: $selectedFilter)
                    }
                    .background(Color(.systemBackground))
                    
                    // Orders list
                    if isLoading {
                        LoadingView()
                    } else if filteredOrders.isEmpty {
                        EmptyOrdersView(filter: selectedFilter)
                    } else {
                        OrdersListView(orders: filteredOrders)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color(.systemGray6))
                
                // Right side - Order Details & Analytics (60% width)
                OrderDetailsPanel(orders: filteredOrders)
            }
            .navigationTitle("Orders")
            .navigationBarTitleDisplayMode(.large)
        }
        .task {
            await loadOrders()
        }
        .alert("Error", isPresented: $showError) {
            Button("OK") { }
        } message: {
            Text(errorMessage)
        }
    }
    
    private func loadOrders() async {
        isLoading = true
        do {
            // Simulate loading orders from backend
            try await Task.sleep(nanoseconds: 1_000_000_000)
            orders = OrderRecord.sampleOrders
        } catch {
            errorMessage = "Failed to load orders: \(error.localizedDescription)"
            showError = true
        }
        isLoading = false
    }
    
    private func refreshOrders() {
        Task {
            await loadOrders()
        }
    }
}

// MARK: - Order Details Panel
struct OrderDetailsPanel: View {
    let orders: [OrderRecord]
    @State private var selectedOrder: OrderRecord?
    @State private var showingAnalytics = true
    
    var body: some View {
        VStack(spacing: 0) {
            // Panel Header
            HStack {
                Button("Analytics") {
                    showingAnalytics = true
                }
                .foregroundColor(showingAnalytics ? .blue : .secondary)
                
                Button("Order Details") {
                    showingAnalytics = false
                }
                .foregroundColor(!showingAnalytics ? .blue : .secondary)
                
                Spacer()
            }
            .padding()
            .background(Color(.systemBackground))
            
            // Panel Content
            if showingAnalytics {
                AnalyticsDashboard(orders: orders)
            } else if let selectedOrder = selectedOrder {
                OrderDetailView(order: selectedOrder)
            } else {
                VStack(spacing: 20) {
                    Image(systemName: "doc.text")
                        .font(.system(size: 60))
                        .foregroundColor(.gray.opacity(0.5))
                    
                    Text("Select an order to view details")
                        .font(.headline)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .background(Color(.systemBackground))
    }
}

// MARK: - Analytics Dashboard
struct AnalyticsDashboard: View {
    let orders: [OrderRecord]
    
    private var totalOrders: Int { orders.count }
    private var totalRevenue: Double { orders.reduce(0) { $0 + $1.total } }
    private var pendingOrders: Int { orders.filter { $0.status == .pending }.count }
    
    private var popularItems: [(String, Int)] {
        let itemCounts = orders.flatMap { $0.items }.reduce(into: [:]) { counts, item in
            counts[item.name, default: 0] += 1
        }
        return itemCounts.sorted { $0.value > $1.value }.prefix(5).map { ($0.key, $0.value) }
    }
    
    private var deliveryPartners: [(String, Int, Double)] {
        let partnerStats = orders.reduce(into: [String: (Int, Double)]()) { stats, order in
            let partner = order.orderType.displayName
            let current = stats[partner, default: (0, 0.0)]
            stats[partner] = (current.0 + 1, current.1 + order.total)
        }
        return partnerStats.map { ($0.key, $0.value.0, $0.value.1) }.sorted { $0.1 > $1.1 }
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Today's Summary
                VStack(alignment: .leading, spacing: 16) {
                    Text("Today's Summary")
                        .font(.title2.bold())
                    
                    HStack(spacing: 16) {
                        SummaryCard(
                            title: "Total Orders",
                            value: "\(totalOrders)",
                            icon: "list.bullet",
                            color: .blue
                        )
                        
                        SummaryCard(
                            title: "Revenue",
                            value: "QR \(String(format: "%.0f", totalRevenue))",
                            icon: "creditcard.fill",
                            color: .green
                        )
                        
                        SummaryCard(
                            title: "Pending",
                            value: "\(pendingOrders)",
                            icon: "clock.fill",
                            color: .orange
                        )
                    }
                }
                
                // Popular Items
                VStack(alignment: .leading, spacing: 16) {
                    Text("Popular Items")
                        .font(.title2.bold())
                    
                    VStack(spacing: 12) {
                        ForEach(Array(popularItems.enumerated()), id: \.offset) { index, item in
                            HStack {
                                Text("\(index + 1).")
                                    .font(.headline)
                                    .foregroundColor(.blue)
                                    .frame(width: 30, alignment: .leading)
                                
                                Text(item.0)
                                    .font(.subheadline)
                                
                                Spacer()
                                
                                Text("\(item.1) orders")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            .padding(.vertical, 8)
                            .padding(.horizontal, 12)
                            .background(Color(.systemGray6))
                            .cornerRadius(8)
                        }
                    }
                }
                
                // Delivery Partners
                VStack(alignment: .leading, spacing: 16) {
                    Text("Delivery Partners")
                        .font(.title2.bold())
                    
                    VStack(spacing: 12) {
                        ForEach(Array(deliveryPartners.enumerated()), id: \.offset) { index, partner in
                            HStack {
                                Image(systemName: "car.fill")
                                    .foregroundColor(partner.0 == "Talabat" ? .orange : 
                                                   partner.0 == "Deliveroo" ? .green : .blue)
                                
                                Text(partner.0)
                                    .font(.subheadline)
                                
                                Spacer()
                                
                                VStack(alignment: .trailing, spacing: 4) {
                                    Text("\(partner.1) orders")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    
                                    Text("QR \(String(format: "%.0f", partner.2))")
                                        .font(.caption.bold())
                                        .foregroundColor(.green)
                                }
                            }
                            .padding(.vertical, 8)
                            .padding(.horizontal, 12)
                            .background(Color(.systemGray6))
                            .cornerRadius(8)
                        }
                    }
                }
                
                // Recent Activity
                VStack(alignment: .leading, spacing: 16) {
                    Text("Recent Activity")
                        .font(.title2.bold())
                    
                    VStack(spacing: 8) {
                        ForEach(orders.prefix(5), id: \.id) { order in
                            HStack {
                                Circle()
                                    .fill(order.status.color)
                                    .frame(width: 8, height: 8)
                                
                                Text("Order #\(order.id.uuidString.prefix(8))")
                                    .font(.subheadline)
                                
                                Spacer()
                                
                                Text(order.status.displayName)
                                    .font(.caption)
                                    .foregroundColor(order.status.color)
                                
                                Text("QR \(String(format: "%.2f", order.total))")
                                    .font(.caption.bold())
                            }
                            .padding(.vertical, 4)
                        }
                    }
                }
            }
            .padding()
        }
    }
}

// MARK: - Summary Card
struct SummaryCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                Spacer()
            }
            
            Text(value)
                .font(.title2.bold())
                .foregroundColor(.primary)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 2, y: 1)
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Order Filter
struct OrderFilterView: View {
    @Binding var selectedFilter: OrderFilter
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(OrderFilter.allCases, id: \.self) { filter in
                    FilterButton(
                        filter: filter,
                        isSelected: selectedFilter == filter,
                        onTap: { selectedFilter = filter }
                    )
                }
            }
            .padding(.horizontal)
        }
        .padding(.vertical, 8)
        .background(Color(.systemBackground))
    }
}

struct FilterButton: View {
    let filter: OrderFilter
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            Text(filter.displayName)
                .font(.subheadline)
                .foregroundColor(isSelected ? .white : .primary)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(isSelected ? Color.blue : Color(.systemGray5))
                )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Orders List
struct OrdersListView: View {
    let orders: [OrderRecord]
    
    var body: some View {
        List(orders) { order in
            OrderRowView(order: order)
        }
        .listStyle(PlainListStyle())
    }
}

struct OrderRowView: View {
    let order: OrderRecord
    @State private var showingDetails = false
    
    var body: some View {
        Button(action: { showingDetails = true }) {
            HStack(spacing: 16) {
                // Order status indicator
                Circle()
                    .fill(order.status.color)
                    .frame(width: 12, height: 12)
                
                // Order info
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text("Order #\(order.orderNumber)")
                            .font(.headline)
                        Spacer()
                        Text("QR \(String(format: "%.2f", order.total))")
                            .font(.subheadline.bold())
                    }
                    
                    HStack {
                        Text(order.customerName)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        Spacer()
                        Text(order.timestamp.formatted(date: .abbreviated, time: .shortened))
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        HStack(spacing: 4) {
                            Image(systemName: order.orderType.icon)
                                .font(.caption)
                                .foregroundColor(order.orderType.color)
                            Text(order.orderType.displayName)
                                .font(.caption)
                                .foregroundColor(order.orderType.color)
                        }
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(order.orderType.color.opacity(0.1))
                        .cornerRadius(4)
                        
                        Spacer()
                        
                        Text("\(order.items.count) items")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        Text(order.status.displayName)
                            .font(.caption)
                            .foregroundColor(order.status.color)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 2)
                            .background(order.status.color.opacity(0.1))
                            .cornerRadius(4)
                    }
                }
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.vertical, 4)
        }
        .buttonStyle(PlainButtonStyle())
        .sheet(isPresented: $showingDetails) {
            OrderDetailView(order: order)
        }
    }
}

// MARK: - Order Detail
struct OrderDetailView: View {
    let order: OrderRecord
    @Environment(\.dismiss) private var dismiss
    @State private var showingStatusUpdate = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Order header
                    OrderHeaderView(order: order)
                    
                    // Items list
                    OrderItemsView(items: order.items)
                    
                    // Payment info
                    PaymentInfoView(order: order)
                    
                    // Action buttons
                    OrderActionButtons(
                        order: order,
                        onStatusUpdate: { showingStatusUpdate = true }
                    )
                }
                .padding()
            }
            .navigationTitle("Order #\(order.orderNumber)")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
        .sheet(isPresented: $showingStatusUpdate) {
            OrderStatusUpdateView(order: order)
        }
    }
}

struct OrderHeaderView: View {
    let order: OrderRecord
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Customer")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(order.customerName)
                        .font(.headline)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("Status")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(order.status.displayName)
                        .font(.subheadline.bold())
                        .foregroundColor(order.status.color)
                }
            }
            
            Divider()
            
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Order Time")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(order.timestamp.formatted(date: .abbreviated, time: .shortened))
                        .font(.subheadline)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("Total")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("QR \(String(format: "%.2f", order.total))")
                        .font(.title3.bold())
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

struct OrderItemsView: View {
    let items: [OrderItem]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Items")
                .font(.headline)
            
            ForEach(items) { item in
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(item.name)
                            .font(.subheadline)
                        
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
                .padding(.vertical, 4)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
    }
}

struct PaymentInfoView: View {
    let order: OrderRecord
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Payment")
                .font(.headline)
            
            HStack {
                Text("Method")
                Spacer()
                Text(order.paymentMethod.rawValue)
            }
            
            HStack {
                Text("Status")
                Spacer()
                Text(order.paymentStatus.displayName)
                    .foregroundColor(order.paymentStatus.color)
            }
        }
        .font(.subheadline)
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
    }
}

struct OrderActionButtons: View {
    let order: OrderRecord
    let onStatusUpdate: () -> Void
    
    var body: some View {
        VStack(spacing: 12) {
            Button(action: onStatusUpdate) {
                HStack {
                    Image(systemName: "pencil")
                    Text("Update Status")
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue)
                .cornerRadius(12)
            }
            
            Button(action: printOrder) {
                HStack {
                    Image(systemName: "printer")
                    Text("Print Order")
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.green)
                .cornerRadius(12)
            }
        }
    }
    
    private func printOrder() {
        // Implement order printing
        print("Printing order #\(order.orderNumber)")
    }
}

// MARK: - Supporting Views
struct LoadingView: View {
    var body: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.5)
            Text("Loading orders...")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct EmptyOrdersView: View {
    let filter: OrderFilter
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "list.bullet")
                .font(.system(size: 60))
                .foregroundColor(.gray.opacity(0.5))
            
            VStack(spacing: 8) {
                Text("No \(filter.displayName.lowercased()) orders")
                    .font(.title3.bold())
                Text("Orders will appear here when they are created")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Models
struct OrderRecord: Identifiable, Codable {
    let id: UUID
    let orderNumber: String
    let customerName: String
    let items: [OrderItem]
    let total: Double
    let status: OrderStatus
    let orderType: OrderType
    let paymentMethod: PaymentMethod
    let paymentStatus: PaymentStatus
    let timestamp: Date
    let estimatedDeliveryTime: Date?
    let deliveryAddress: String?
    
    static let sampleOrders: [OrderRecord] = [
        OrderRecord(
            id: UUID(),
            orderNumber: "1001",
            customerName: "John Doe",
            items: [
                OrderItem(
                    name: "Brown Sugar Pearl Milk Tea",
                    size: "Large",
                    sugarLevel: "Recommende",
                    iceLevel: "Normal",
                    selectedToppings: ["Extra Shot"],
                    sizePrice: 6.0,
                    toppingPrices: [5.0],
                    price: 29.0
                )
            ],
            total: 29.0,
            status: .completed,
            orderType: .talabat,
            paymentMethod: .card,
            paymentStatus: .success,
            timestamp: Date().addingTimeInterval(-3600),
            estimatedDeliveryTime: Date().addingTimeInterval(-1800),
            deliveryAddress: "Al Wakrah, Doha"
        ),
        OrderRecord(
            id: UUID(),
            orderNumber: "1002",
            customerName: "Jane Smith",
            items: [
                OrderItem(
                    name: "Matcha Milk Tea",
                    size: "Medium",
                    sugarLevel: "Less",
                    iceLevel: "Less Ice",
                    selectedToppings: ["Whipped Cream"],
                    sizePrice: 3.0,
                    toppingPrices: [2.0],
                    price: 24.0
                )
            ],
            total: 24.0,
            status: .pending,
            orderType: .deliveroo,
            paymentMethod: .cash,
            paymentStatus: .pending,
            timestamp: Date().addingTimeInterval(-7200),
            estimatedDeliveryTime: Date().addingTimeInterval(1800),
            deliveryAddress: "West Bay, Doha"
        ),
        OrderRecord(
            id: UUID(),
            orderNumber: "1003",
            customerName: "Walk-in Customer",
            items: [
                OrderItem(
                    name: "Fragrant Black Tea",
                    size: "Small",
                    sugarLevel: "Zero Sugar",
                    iceLevel: "No Ice",
                    selectedToppings: [],
                    sizePrice: 0.0,
                    toppingPrices: [],
                    price: 12.0
                )
            ],
            total: 12.0,
            status: .completed,
            orderType: .walkIn,
            paymentMethod: .qlub,
            paymentStatus: .success,
            timestamp: Date().addingTimeInterval(-1800),
            estimatedDeliveryTime: nil,
            deliveryAddress: nil
        )
    ]
}

enum OrderFilter: String, CaseIterable {
    case all = "all"
    case pending = "pending"
    case completed = "completed"
    case cancelled = "cancelled"
    
    var displayName: String {
        switch self {
        case .all: return "All"
        case .pending: return "Pending"
        case .completed: return "Completed"
        case .cancelled: return "Cancelled"
        }
    }
}

// OrderStatus is now defined in SharedModels.swift

// MARK: - Status Update View
struct OrderStatusUpdateView: View {
    let order: OrderRecord
    @Environment(\.dismiss) private var dismiss
    @State private var selectedStatus: OrderStatus
    
    init(order: OrderRecord) {
        self.order = order
        self._selectedStatus = State(initialValue: order.status)
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Update Order Status")
                    .font(.title2.bold())
                
                VStack(spacing: 12) {
                    ForEach(OrderStatus.allCases, id: \.self) { status in
                        Button(action: { selectedStatus = status }) {
                            HStack {
                                Circle()
                                    .fill(selectedStatus == status ? status.color : Color.clear)
                                    .frame(width: 20, height: 20)
                                    .overlay(
                                        Circle()
                                            .stroke(status.color, lineWidth: 2)
                                    )
                                
                                Text(status.displayName)
                                    .foregroundColor(.primary)
                                
                                Spacer()
                                
                                if selectedStatus == status {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(status.color)
                                }
                            }
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(8)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                
                Spacer()
                
                Button(action: updateStatus) {
                    Text("Update Status")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(12)
                }
            }
            .padding()
            .navigationTitle("Status Update")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func updateStatus() {
        // Implement status update logic
        print("Updating order #\(order.orderNumber) to \(selectedStatus.displayName)")
        dismiss()
    }
}

#Preview {
    OrdersView()
}
