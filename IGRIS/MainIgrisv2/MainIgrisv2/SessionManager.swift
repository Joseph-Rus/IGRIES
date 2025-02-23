import Foundation
import FirebaseAuth

class SessionManager: ObservableObject {
    @Published var isAuthenticated: Bool = false
    @Published var currentUserId: String? = nil
    
    init() {
        Auth.auth().addStateDidChangeListener { [weak self] (_, user) in
            if let user = user {
                self?.isAuthenticated = true
                self?.currentUserId = user.uid
                print("User signed in: \(user.uid)")
            } else {
                self?.isAuthenticated = false
                self?.currentUserId = nil
                print("No user signed in")
            }
        }
    }
    
    func signOut() {
        do {
            try Auth.auth().signOut()
            self.isAuthenticated = false
            self.currentUserId = nil
            print("Signed out successfully")
        } catch {
            print("Error signing out: \(error.localizedDescription)")
        }
    }
}
