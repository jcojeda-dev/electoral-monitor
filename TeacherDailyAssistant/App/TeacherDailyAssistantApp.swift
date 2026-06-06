import SwiftUI
import SwiftData

@main
struct TeacherDailyAssistantApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Course.self,
            Activity.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()
    
    @StateObject private var authService = AuthService()
    @StateObject private var settingsViewModel = SettingsViewModel()
    @State private var isAppUnlocked = false
    @State private var showingLockScreen = false
    
    var body: some Scene {
        WindowGroup {
            ZStack {
                if !authService.isAuthenticated {
                    LoginView(authService: authService)
                        .transition(.slide)
                } else if showingLockScreen {
                    lockOverlayScreen
                } else {
                    DashboardView()
                        .transition(.opacity)
                }
            }
            .animation(.default, value: authService.isAuthenticated)
            .onAppear {
                handleAppUnlock()
            }
            .onChange(of: authService.isAuthenticated) { _, newValue in
                if newValue {
                    handleAppUnlock()
                } else {
                    isAppUnlocked = false
                    showingLockScreen = false
                }
            }
        }
        .modelContainer(sharedModelContainer)
    }
    
    private var lockOverlayScreen: some View {
        VStack(spacing: 24) {
            Spacer()
            
            Image(systemName: "lock.shield")
                .font(.system(size: 64))
                .foregroundColor(.purple)
                .shadow(color: .purple.opacity(0.2), radius: 8)
            
            Text("Teacher Daily Assistant")
                .font(.title2)
                .fontWeight(.bold)
            
            Text("Aplicación bloqueada por Face ID")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Spacer()
            
            Button(action: {
                triggerBiometricAuthentication()
            }) {
                HStack {
                    Image(systemName: "faceid")
                    Text("Reintentar Desbloquear")
                }
                .fontWeight(.bold)
                .foregroundColor(.white)
                .padding(.horizontal, 24)
                .padding(.vertical, 14)
                .background(Color.purple)
                .cornerRadius(12)
            }
            .padding(.bottom, 60)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(uiColor: .systemBackground))
    }
    
    private func handleAppUnlock() {
        if settingsViewModel.isFaceIDEnabled {
            showingLockScreen = true
            triggerBiometricAuthentication()
        } else {
            isAppUnlocked = true
            showingLockScreen = false
        }
    }
    
    private func triggerBiometricAuthentication() {
        settingsViewModel.authenticateUser { success in
            if success {
                withAnimation {
                    isAppUnlocked = true
                    showingLockScreen = false
                }
            } else {
                isAppUnlocked = false
                showingLockScreen = true
            }
        }
    }
}