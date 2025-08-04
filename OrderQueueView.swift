import SwiftUI

struct OrderQueueView: View {
    @StateObject private var viewModel = OrderQueueViewModel()
    @State private var currentTime = Date()
    
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            headerView
            
            // Order Grid
            orderGrid
            
            // Footer
            footerView
        }
        .background(ChageeTheme.Colors.background)
        .onReceive(timer) { _ in
            currentTime = Date()
        }
        .task {
            await viewModel.startMonitoring()
        }
    }
    
    private var headerView: some View {
        VStack(spacing: ChageeTheme.Spacing.md) {
            // Logo and Time
            HStack {
                Text("CHAGEE")
                    .font(ChageeTheme.Typography.largeTitle)
                    .foregroundColor(ChageeTheme.Colors.primaryGreen)
                
                Spacer()
                
                Text(currentTime, style: .time)
                    .font(ChageeTheme.Typography.title)
                    .foregroundColor(ChageeTheme.Colors.text)
            }
            
            // Status Sections
            HStack(spacing: ChageeTheme.Spacing.xl) {
                StatusSection(
                    title: "PREPARING",
                    icon: "timer",
                    color: ChageeTheme.Colors.warning
                )
                
                StatusSection(
                    title: "READY",
                    icon: "checkmark.circle.fill",
                    color: ChageeTheme.Colors.success
                )
                
                StatusSection(
                    title: "COLLECTED",
                    icon: "bag.fill",
                    color: ChageeTheme.Colors.textSecondary
                )
            }
        }
        .padding(ChageeTheme.Spacing.xl)
        .background(ChageeTheme.Colors.surface)
    }
    
    private var orderGrid: some View {
        ScrollView {
            VStack(spacing: ChageeTheme.Spacing.xl) {
                // Preparing Orders
                if !viewModel.preparingOrders.isEmpty {
                    OrderSection(
                        title: "PREPARING",
                        orders: viewModel.preparingOrders,
                        backgroundColor: ChageeTheme.Colors.warning.opacity(0.1),
                        borderColor: ChageeTheme.Colors.warning
                    )
                }
                
                // Ready Orders
                if !viewModel.readyOrders.isEmpty {
                    OrderSection(
                        title: "READY FOR COLLECTION",
                        orders: viewModel.readyOrders,
                        backgroundColor: ChageeTheme.Colors.success.opacity(0.1),
                        borderColor: ChageeTheme.Colors.success
                    )
                }
                
                // Recent Collected
                if !viewModel.collectedOrders.isEmpty {
                    OrderSection(
                        title: "RECENTLY COLLECTED",
                        orders: viewModel.collectedOrders,
                        backgroundColor: ChageeTheme.Colors.textSecondary.opacity(0.05),
                        borderColor: ChageeTheme.Colors.textSecondary
                    )
                }
            }
            .padding(ChageeTheme.Spacing.xl)
        }
    }
    
    private var footerView: some View {
        HStack {
            Text("Thank you for your patience")
                .font(ChageeTheme.Typography.body)
                .foregroundColor(ChageeTheme.Colors.textSecondary)
            
            Spacer()
            
            Text("Average wait time: \(viewModel.averageWaitTime) mins")
                .font(ChageeTheme.Typography.body)
                .foregroundColor(ChageeTheme.Colors.text)
        }
        .padding(ChageeTheme.Spacing.lg)
        .background(ChageeTheme.Colors.surface)
    }
}

// MARK: - Supporting Views
struct StatusSection: View {
    let title: String
    let icon: String
    let color: Color
    
    var body: some View {
        HStack(spacing: ChageeTheme.Spacing.sm) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            Text(title)
                .font(ChageeTheme.Typography.callout)
                .foregroundColor(ChageeTheme.Colors.text)
        }
        .frame(maxWidth: .infinity)
        .padding(ChageeTheme.Spacing.md)
        .background(color.opacity(0.1))
        .cornerRadius(ChageeTheme.Radius.sm)
    }
}

struct OrderSection: View {
    let title: String
    let orders: [QueueOrder]
    let backgroundColor: Color
    let borderColor: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: ChageeTheme.Spacing.md) {
            Text(title)
                .font(ChageeTheme.Typography.headline)
                .foregroundColor(ChageeTheme.Colors.text)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: ChageeTheme.Spacing.md) {
                ForEach(orders) { order in
                    OrderCard(order: order, backgroundColor: backgroundColor)
                }
            }
        }
        .padding(ChageeTheme.Spacing.lg)
        .background(backgroundColor.opacity(0.3))
        .cornerRadius(ChageeTheme.Radius.md)
        .overlay(
            RoundedRectangle(cornerRadius: ChageeTheme.Radius.md)
                .stroke(borderColor, lineWidth: 2)
        )
    }
}

struct OrderCard: View {
    let order: QueueOrder
    let backgroundColor: Color
    
    var body: some View {
        VStack(spacing: ChageeTheme.Spacing.sm) {
            Text("#\(order.orderNumber)")
                .font(ChageeTheme.Typography.largeTitle)
                .foregroundColor(ChageeTheme.Colors.primaryGreen)
            
            Text(order.customerName ?? "Guest")
                .font(ChageeTheme.Typography.body)
                .foregroundColor(ChageeTheme.Colors.text)
            
            Text("\(order.itemCount) items")
                .font(ChageeTheme.Typography.caption)
                .foregroundColor(ChageeTheme.Colors.textSecondary)
            
            if let waitTime = order.waitingTime {
                Text("\(waitTime) min")
                    .font(ChageeTheme.Typography.caption)
                    .foregroundColor(ChageeTheme.Colors.textSecondary)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(ChageeTheme.Spacing.lg)
        .background(ChageeTheme.Colors.surface)
        .cornerRadius(ChageeTheme.Radius.md)
        .shadow(
            color: ChageeTheme.Shadow.sm.color,
            radius: CGFloat(ChageeTheme.Shadow.sm.radius),
            x: CGFloat(ChageeTheme.Shadow.sm.x),
            y: CGFloat(ChageeTheme.Shadow.sm.y)
        )
    }
}

// MARK: - Data Models
struct QueueOrder: Identifiable {
    let id = UUID()
    let orderNumber: String
    let customerName: String?
    let itemCount: Int
    let status: OrderStatus
    let createdAt: Date
    
    var waitingTime: Int? {
        let minutes = Int(Date().timeIntervalSince(createdAt) / 60)
        return minutes > 0 ? minutes : nil
    }
    
    enum OrderStatus {
        case preparing
        case ready
        case collected
    }
}

// MARK: - View Model
@MainActor
class OrderQueueViewModel: ObservableObject {
    @Published var preparingOrders: [QueueOrder] = []
    @Published var readyOrders: [QueueOrder] = []
    @Published var collectedOrders: [QueueOrder] = []
    @Published var averageWaitTime: Int = 5
    
    private var monitoringTask: Task<Void, Never>?
    
    func startMonitoring() async {
        // In production, this would connect to real-time updates from Supabase
        // For demo, we'll simulate some orders
        
        // Sample data
        preparingOrders = [
            QueueOrder(orderNumber: "0042", customerName: "Sarah", itemCount: 2, status: .preparing, createdAt: Date().addingTimeInterval(-120)),
            QueueOrder(orderNumber: "0043", customerName: "Mike", itemCount: 1, status: .preparing, createdAt: Date().addingTimeInterval(-60)),
            QueueOrder(orderNumber: "0044", customerName: nil, itemCount: 3, status: .preparing, createdAt: Date())
        ]
        
        readyOrders = [
            QueueOrder(orderNumber: "0040", customerName: "Emma", itemCount: 2, status: .ready, createdAt: Date().addingTimeInterval(-300)),
            QueueOrder(orderNumber: "0041", customerName: "John", itemCount: 1, status: .ready, createdAt: Date().addingTimeInterval(-240))
        ]
        
        collectedOrders = [
            QueueOrder(orderNumber: "0038", customerName: "Lisa", itemCount: 2, status: .collected, createdAt: Date().addingTimeInterval(-420)),
            QueueOrder(orderNumber: "0039", customerName: "Tom", itemCount: 4, status: .collected, createdAt: Date().addingTimeInterval(-360))
        ]
        
        // Start monitoring for updates
        monitoringTask = Task {
            while !Task.isCancelled {
                try? await Task.sleep(nanoseconds: 5_000_000_000) // 5 seconds
                // In production, fetch updates from backend
            }
        }
    }
    
    deinit {
        monitoringTask?.cancel()
    }
}