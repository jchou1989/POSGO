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
            VStack(spacing: 0) {
                // Filter buttons
                OrderFilterView(selectedFilter: $selectedFilter)
                
                // Orders list
                if isLoading {
                    LoadingView()
                } else if filteredOrders.isEmpty {
                    EmptyOrdersView(filter: selectedFilter)
                } else {
                    OrdersListView(orders: filteredOrders)
                }
            }
            .navigationTitle("Orders")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: refreshOrders) {
                        Image(systemName: "arrow.clockwise")
                    }
                }
            }
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
                        Text(order.total.formatted(.currency(code: "USD")))
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
                    Text(order.total.formatted(.currency(code: "USD")))
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
                        
                        if !item.toppings.isEmpty {
                            Text(item.toppings.joined(separator: ", "))
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    Spacer()
                    
                    Text(item.formattedPrice)
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
    let paymentMethod: PaymentMethod
    let paymentStatus: PaymentStatus
    let timestamp: Date
    
    static let sampleOrders: [OrderRecord] = [
        OrderRecord(
            id: UUID(),
            orderNumber: "1001",
            customerName: "John Doe",
            items: [
                OrderItem(
                    name: "Iced Coffee",
                    size: "Large",
                    sugar: "50%",
                    ice: "Regular",
                    toppings: ["Whipped Cream"],
                    sizePrice: 1.50,
                    toppingPrices: [0.50],
                    price: 4.25
                )
            ],
            total: 4.25,
            status: .completed,
            paymentMethod: .card,
            paymentStatus: .success,
            timestamp: Date()
        ),
        OrderRecord(
            id: UUID(),
            orderNumber: "1002",
            customerName: "Jane Smith",
            items: [
                OrderItem(
                    name: "Hot Coffee",
                    size: "Medium",
                    sugar: "100%",
                    ice: "None",
                    toppings: [],
                    sizePrice: 0,
                    toppingPrices: [],
                    price: 3.50
                )
            ],
            total: 3.50,
            status: .pending,
            paymentMethod: .cash,
            paymentStatus: .pending,
            timestamp: Date().addingTimeInterval(-3600)
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

enum OrderStatus: String, Codable, CaseIterable {
    case pending = "pending"
    case inProgress = "in_progress"
    case completed = "completed"
    case cancelled = "cancelled"
    
    var displayName: String {
        switch self {
        case .pending: return "Pending"
        case .inProgress: return "In Progress"
        case .completed: return "Completed"
        case .cancelled: return "Cancelled"
        }
    }
    
    var color: Color {
        switch self {
        case .pending: return .orange
        case .inProgress: return .blue
        case .completed: return .green
        case .cancelled: return .red
        }
    }
}

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