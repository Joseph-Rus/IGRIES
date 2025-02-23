import SwiftUI

struct ContentView: View {
    @EnvironmentObject var sessionManager: SessionManager
    
    var body: some View {
        NavigationView {
            if sessionManager.isAuthenticated {
                MainChat()
            } else {
                AuthContainerView()
            }
        }
        .onAppear {
            print("ContentView appeared, isAuthenticated: \(sessionManager.isAuthenticated)")
        }
    }
}
