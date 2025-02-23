import SwiftUI
import FirebaseAuth

class SessionManager: ObservableObject {
    @Published var isAuthenticated: Bool = false

    init() {
        checkAuthState()
    }

    func checkAuthState() {
        if Auth.auth().currentUser != nil {
            isAuthenticated = true
        } else {
            isAuthenticated = false
        }
    }

    func signOut() {
        do {
            try Auth.auth().signOut()
            isAuthenticated = false
        } catch {
            print("Error signing out: \(error.localizedDescription)")
        }
    }
}
