import Foundation
import SwiftUI

// MARK: - Error Handling System
enum AppError: LocalizedError, Identifiable {
    case networkError(String)
    case dataError(String)
    case authenticationError(String)
    case paymentError(String)
    case offlineError(String)
    case validationError(String)
    case unknownError(String)
    
    var id: String {
        switch self {
        case .networkError: return "network"
        case .dataError: return "data"
        case .authenticationError: return "auth"
        case .paymentError: return "payment"
        case .offlineError: return "offline"
        case .validationError: return "validation"
        case .unknownError: return "unknown"
        }
    }
    
    var errorDescription: String? {
        switch self {
        case .networkError(let message):
            return "Network Error: \(message)"
        case .dataError(let message):
            return "Data Error: \(message)"
        case .authenticationError(let message):
            return "Authentication Error: \(message)"
        case .paymentError(let message):
            return "Payment Error: \(message)"
        case .offlineError(let message):
            return "Offline Error: \(message)"
        case .validationError(let message):
            return "Validation Error: \(message)"
        case .unknownError(let message):
            return "Unknown Error: \(message)"
        }
    }
    
    var recoverySuggestion: String? {
        switch self {
        case .networkError:
            return "Please check your internet connection and try again."
        case .dataError:
            return "Please refresh the app or contact support."
        case .authenticationError:
            return "Please log in again with valid credentials."
        case .paymentError:
            return "Please try a different payment method or contact support."
        case .offlineError:
            return "Please connect to the internet to continue."
        case .validationError:
            return "Please check your input and try again."
        case .unknownError:
            return "Please restart the app or contact support."
        }
    }
    
    var severity: ErrorSeverity {
        switch self {
        case .networkError, .offlineError:
            return .warning
        case .authenticationError, .paymentError:
            return .error
        case .dataError, .validationError, .unknownError:
            return .critical
        }
    }
}

enum ErrorSeverity {
    case warning
    case error
    case critical
    
    var color: Color {
        switch self {
        case .warning: return .orange
        case .error: return .red
        case .critical: return .purple
        }
    }
    
    var icon: String {
        switch self {
        case .warning: return "exclamationmark.triangle"
        case .error: return "xmark.circle"
        case .critical: return "exclamationmark.octagon"
        }
    }
}

// MARK: - Error Handler
class ErrorHandler: ObservableObject {
    @Published var currentError: AppError?
    @Published var isShowingError = false
    @Published var errorLog: [AppError] = []
    
    static let shared = ErrorHandler()
    
    private init() {}
    
    func handle(_ error: AppError) {
        DispatchQueue.main.async {
            self.currentError = error
            self.isShowingError = true
            self.errorLog.append(error)
            
            // Log error for debugging
            print("🚨 Error: \(error.errorDescription ?? "Unknown error")")
            print("💡 Recovery: \(error.recoverySuggestion ?? "No suggestion")")
        }
    }
    
    func clearError() {
        DispatchQueue.main.async {
            self.currentError = nil
            self.isShowingError = false
        }
    }
    
    func logError(_ error: AppError) {
        errorLog.append(error)
        print("📝 Logged Error: \(error.errorDescription ?? "Unknown error")")
    }
}

// MARK: - Network Monitor
class NetworkMonitor: ObservableObject {
    @Published var isConnected = true
    @Published var connectionType: ConnectionType = .unknown
    
    enum ConnectionType {
        case wifi
        case cellular
        case ethernet
        case unknown
    }
    
    static let shared = NetworkMonitor()
    
    private init() {
        // In a real app, you would use Network framework to monitor connectivity
        // For now, we'll simulate network monitoring
        startMonitoring()
    }
    
    private func startMonitoring() {
        // Simulate network monitoring
        Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { _ in
            // Simulate network status changes
            let random = Int.random(in: 1...10)
            DispatchQueue.main.async {
                self.isConnected = random > 1 // 90% uptime
                self.connectionType = random > 5 ? .wifi : .cellular
            }
        }
    }
}

// MARK: - Offline Manager
class OfflineManager: ObservableObject {
    @Published var isOfflineMode = false
    @Published var pendingOperations: [PendingOperation] = []
    
    struct PendingOperation: Identifiable, Codable {
        var id = UUID()
        let type: OperationType
        let data: Data
        let timestamp: Date
        
        enum OperationType: String, Codable {
            case orderSubmission
            case dataSync
            case paymentProcessing
        }
    }
    
    static let shared = OfflineManager()
    
    private init() {}
    
    func addPendingOperation(_ operation: PendingOperation) {
        pendingOperations.append(operation)
        savePendingOperations()
    }
    
    func processPendingOperations() async {
        guard !pendingOperations.isEmpty else { return }
        
        for operation in pendingOperations {
            do {
                switch operation.type {
                case .orderSubmission:
                    // Process pending orders
                    break
                case .dataSync:
                    // Sync data
                    break
                case .paymentProcessing:
                    // Process payments
                    break
                }
                
                // Remove successful operation
                if let index = pendingOperations.firstIndex(where: { $0.id == operation.id }) {
                    pendingOperations.remove(at: index)
                }
            } catch {
                // Note: This catch block is intentionally empty as the operation is simulated
            }
        }
        
        savePendingOperations()
    }
    
    private func savePendingOperations() {
        if let encoded = try? JSONEncoder().encode(pendingOperations) {
            UserDefaults.standard.set(encoded, forKey: "pendingOperations")
        }
    }
    
    private func loadPendingOperations() {
        if let data = UserDefaults.standard.data(forKey: "pendingOperations"),
           let decoded = try? JSONDecoder().decode([PendingOperation].self, from: data) {
            pendingOperations = decoded
        }
    }
}

// MARK: - Error Alert View
struct ErrorAlertView: View {
    @ObservedObject var errorHandler = ErrorHandler.shared
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        if let error = errorHandler.currentError {
            VStack(spacing: 20) {
                Image(systemName: error.severity.icon)
                    .font(.system(size: 50))
                    .foregroundColor(error.severity.color)
                
                Text(error.errorDescription ?? "Unknown Error")
                    .font(.headline)
                    .multilineTextAlignment(.center)
                
                if let suggestion = error.recoverySuggestion {
                    Text(suggestion)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                
                HStack(spacing: 15) {
                    Button("Dismiss") {
                        errorHandler.clearError()
                    }
                    .buttonStyle(.bordered)
                    
                    Button("Retry") {
                        errorHandler.clearError()
                        // Add retry logic here
                    }
                    .buttonStyle(.borderedProminent)
                }
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(15)
            .shadow(radius: 10)
        }
    }
}

// MARK: - Error Loading View
struct ErrorLoadingView: View {
    let message: String
    let error: AppError?
    let retryAction: (() -> Void)?
    
    init(message: String = "Loading...", error: AppError? = nil, retryAction: (() -> Void)? = nil) {
        self.message = message
        self.error = error
        self.retryAction = retryAction
    }
    
    var body: some View {
        VStack(spacing: 20) {
            if let error = error {
                Image(systemName: error.severity.icon)
                    .font(.system(size: 40))
                    .foregroundColor(error.severity.color)
                
                Text(error.errorDescription ?? "Unknown Error")
                    .font(.headline)
                    .multilineTextAlignment(.center)
                
                if let retryAction = retryAction {
                    Button("Retry") {
                        retryAction()
                    }
                    .buttonStyle(.borderedProminent)
                }
            } else {
                ProgressView()
                    .scaleEffect(1.5)
                
                Text(message)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
    }
} 
