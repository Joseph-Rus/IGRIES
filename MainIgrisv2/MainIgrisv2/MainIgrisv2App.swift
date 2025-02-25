import SwiftUI
import FirebaseCore

@main
struct MainIgrisv2App: App {
    @StateObject var sessionManager = SessionManager()
    @StateObject var taskVM = TaskViewModel()
    @StateObject var eventVM = EventViewModel()
    @State private var isLoading = true
    
    init() {
        FirebaseApp.configure() // Firebase initialization
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
                        .environmentObject(eventVM)
                }
            }
            .onAppear {
                // Efficiently check auth state and transition
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { // Minimum delay for UX
                    // Rely on SessionManager’s auth listener to set isAuthenticated
                    if sessionManager.isAuthenticated {
                        // Preload data if authenticated
                        if let userId = sessionManager.currentUserId {
                            taskVM.fetchTasks(for: userId)
                            eventVM.fetchEvents(for: userId)
                        }
                    }
                    isLoading = false // Transition to ContentView
                }
            }
        }
    }
}
