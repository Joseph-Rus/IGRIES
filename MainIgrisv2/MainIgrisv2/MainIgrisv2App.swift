import SwiftUI
import FirebaseCore
import FirebaseAuth

@main
struct MainIgrisv2App: App {
    @StateObject var sessionManager = SessionManager()
    @StateObject var taskVM = TaskViewModel()
    @State private var isLoading = true
    
    init() {
        FirebaseApp.configure() // Firebase initialization
        
        // Apply global theme settings for better text visibility
        ThemeManager.shared.applyGlobalTheme()
        
        // Force all presented views to use dark mode
        UIView.appearance().overrideUserInterfaceStyle = .dark
    }
    
    var body: some Scene {
        WindowGroup {
            ZStack {
                if isLoading {
                    SplashScreenView()
                } else {
                    ContentView()
                        .environmentObject(sessionManager)
                        .environmentObject(taskVM)
                        .preferredColorScheme(.dark) // Force dark mode at SwiftUI level
                }
            }
            .onAppear {
                // Efficiently check auth state and transition
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { // Minimum delay for UX
                    // Check if user is already signed in
                    if let user = Auth.auth().currentUser {
                        // Check if email is verified
                        user.reload { error in
                            if let error = error {
                                print("Error reloading user: \(error.localizedDescription)")
                                isLoading = false
                            } else {
                                if user.isEmailVerified {
                                    // Email is verified, user is authenticated
                                    sessionManager.isEmailVerified = true
                                    sessionManager.isAuthenticated = true
                                    sessionManager.currentUserId = user.uid
                                    sessionManager.currentUserEmail = user.email
                                    sessionManager.currentUserName = user.displayName
                                    
                                    // Preload data if authenticated
                                    taskVM.fetchTasks(for: user.uid)
                                } else {
                                    // Email is not verified, user is not fully authenticated
                                    sessionManager.isEmailVerified = false
                                    sessionManager.isAuthenticated = false
                                    sessionManager.currentUserId = user.uid
                                    sessionManager.currentUserEmail = user.email
                                    sessionManager.currentUserName = user.displayName
                                }
                                isLoading = false
                            }
                        }
                    } else {
                        // No user is signed in
                        isLoading = false
                    }
                }
            }
        }
    }
}
