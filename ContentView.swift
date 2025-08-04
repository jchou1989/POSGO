import SwiftUI

struct ContentView: View {
    @EnvironmentObject var authManager: AuthenticationManager
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        Group {
            if authManager.isAuthenticated {
                MainPOSView()
            } else {
                LoginView()
            }
        }
        .onAppear {
            appState.loadCartFromLocal()
        }
    }
}

struct LoginView: View {
    @EnvironmentObject var authManager: AuthenticationManager
    @State private var username = ""
    @State private var password = ""
    @State private var showError = false
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: [Color.blue.opacity(0.8), Color.purple.opacity(0.6)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 40) {
                // Logo and title
                VStack(spacing: 20) {
                    Image(systemName: "cup.and.saucer.fill")
                        .font(.system(size: 80))
                        .foregroundColor(.white)
                    
                    Text("POS GO")
                        .font(.largeTitle.bold())
                        .foregroundColor(.white)
                    
                    Text("Point of Sale System")
                        .font(.title3)
                        .foregroundColor(.white.opacity(0.8))
                }
                
                // Login form
                VStack(spacing: 20) {
                    TextField("Username", text: $username)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                    
                    SecureField("Password", text: $password)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    Button(action: login) {
                        HStack {
                            if authManager.isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    .scaleEffect(0.8)
                            } else {
                                Image(systemName: "arrow.right.circle.fill")
                            }
                            Text("Login")
                                .font(.headline)
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(10)
                    }
                    .disabled(username.isEmpty || password.isEmpty || authManager.isLoading)
                }
                .padding(.horizontal, 40)
                
                // Demo credentials
                VStack(spacing: 8) {
                    Text("Demo Login")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                    Text("Any username/password will work")
                        .font(.caption2)
                        .foregroundColor(.white.opacity(0.5))
                }
            }
            .padding()
        }
        .alert("Login Failed", isPresented: $showError) {
            Button("OK") { }
        } message: {
            Text("Please check your credentials and try again.")
        }
    }
    
    private func login() {
        Task {
            let success = await authManager.login(username: username, password: password)
            if !success {
                showError = true
            }
        }
    }
}

struct MainPOSView: View {
    @EnvironmentObject var authManager: AuthenticationManager
    @EnvironmentObject var appState: AppState
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // POS Tab
            POSView()
                .tabItem {
                    Image(systemName: "cart.fill")
                    Text("POS")
                }
                .tag(0)
            
            // Orders Tab
            OrdersView()
                .tabItem {
                    Image(systemName: "list.bullet")
                    Text("Orders")
                }
                .tag(1)
            
            // Admin Tab (only for managers/admins)
            if authManager.currentUser?.role != .cashier {
                AdminView()
                    .tabItem {
                        Image(systemName: "gear")
                        Text("Admin")
                    }
                    .tag(2)
            }
        }
        .navigationBarHidden(true)
    }
}

#Preview {
    ContentView()
        .environmentObject(AuthenticationManager())
        .environmentObject(AppState())
        .environmentObject(PaymentManager())
}