import SwiftUI

struct ContentView: View {
    @EnvironmentObject var sessionManager: SessionManager
    @EnvironmentObject var taskVM: TaskViewModel
    @EnvironmentObject var eventVM: EventViewModel
    
    var body: some View {
        NavigationStack {
            if sessionManager.isAuthenticated {
                MinimalSpeechView()
                    .environmentObject(sessionManager)
                    .environmentObject(taskVM)
                    .environmentObject(eventVM)
            } else {
                AuthContainerView()
            }
        }
        .onAppear {
            print("ContentView appeared, isAuthenticated: \(sessionManager.isAuthenticated)")
        }
        .onChange(of: sessionManager.isAuthenticated) { _, newValue in
            print("ContentView detected isAuthenticated change: \(newValue)")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(SessionManager())
            .environmentObject(TaskViewModel())
            .environmentObject(EventViewModel())
    }
}
