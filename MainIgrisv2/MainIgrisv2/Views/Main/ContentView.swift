import SwiftUI
import FirebaseAuth

struct ContentView: View {
    @EnvironmentObject var sessionManager: SessionManager
    @EnvironmentObject var taskVM: TaskViewModel
    @Environment(\.colorScheme) var colorScheme
    
    // Reference to ThemeManager
    private let theme = ThemeManager.shared
    
    var body: some View {
        Group {
            if sessionManager.isAuthenticated {
                // Main app content when authenticated
                ZStack {
                    // Use ThemeManager's background gradient
                    theme.backgroundGradient
                        .ignoresSafeArea()
                    
                    TabView {
                        HomeView()
                            .environmentObject(sessionManager)
                            .environmentObject(taskVM)
                            .tabItem {
                                Label("Home", systemImage: "house.fill")
                            }
                        
                        TasksView()
                            .environmentObject(sessionManager)
                            .environmentObject(taskVM)
                            .tabItem {
                                Label("Tasks", systemImage: "list.bullet")
                            }
                        
                        TodoListView()
                            .environmentObject(sessionManager)
                            .environmentObject(taskVM)
                            .tabItem {
                                Label("Todo", systemImage: "checkmark.circle")
                            }
                        
                        ProfileView()
                            .environmentObject(sessionManager)
                            .tabItem {
                                Label("Profile", systemImage: "person.fill")
                            }
                    }
                    .accentColor(theme.accentColor) // Use ThemeManager's accent color
                }
            } else if Auth.auth().currentUser != nil && !sessionManager.isEmailVerified {
                // User is logged in but email is not verified
                EmailVerificationView()
                    .environmentObject(sessionManager)
            } else {
                // Authentication view
                AuthContainerView()
            }
        }
        .preferredColorScheme(.dark) // Force dark mode to match TodoListView
        .onAppear {
            print("ContentView appeared, isAuthenticated: \(sessionManager.isAuthenticated)")
            
            // Ensure we fetch the todo list tasks when authenticated
            if sessionManager.isAuthenticated, let userId = sessionManager.currentUserId {
                taskVM.fetchTasks(for: userId)
            }
            
            // Check if the current user's email is verified
            if let user = Auth.auth().currentUser {
                user.reload { error in
                    if error == nil {
                        // Update the email verification status
                        sessionManager.isEmailVerified = user.isEmailVerified
                        if user.isEmailVerified && !sessionManager.isAuthenticated {
                            sessionManager.isAuthenticated = true
                        }
                    }
                }
            }
        }
        .onChange(of: sessionManager.isAuthenticated) { _, newValue in
            print("ContentView detected isAuthenticated change: \(newValue)")
            
            // Fetch todo list tasks when user becomes authenticated
            if newValue, let userId = sessionManager.currentUserId {
                taskVM.fetchTasks(for: userId)
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(SessionManager())
            .environmentObject(TaskViewModel())
            .preferredColorScheme(.dark)
    }
}
