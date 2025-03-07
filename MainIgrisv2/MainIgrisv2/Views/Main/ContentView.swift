import SwiftUI

struct ContentView: View {
    @EnvironmentObject var sessionManager: SessionManager
    @EnvironmentObject var taskVM: TaskViewModel
    @EnvironmentObject var eventVM: EventViewModel
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        Group {
            if sessionManager.isAuthenticated {
                // Main app content when authenticated
                ZStack {
                    // Global background color/style that will show during transitions
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color.blue.opacity(0.7),
                            Color.purple.opacity(0.7)
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    .ignoresSafeArea()
                    
                    TabView {
                        HomeView()
                            .environmentObject(sessionManager)
                            .environmentObject(taskVM)
                            .environmentObject(eventVM)
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
                    .accentColor(.white) // Changed from blue to white for better visibility on dark background
                }
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
            .environmentObject(EventViewModel())
            .preferredColorScheme(.dark)
    }
}
