import Foundation
import FirebaseAuth

class SessionManager: ObservableObject {
    @Published var isAuthenticated: Bool = false
    @Published var currentUserId: String? = nil
    @Published var currentUserEmail: String? = nil
    @Published var currentUserName: String? = nil // Add username tracking
    
    init() {
        Auth.auth().addStateDidChangeListener { [weak self] (_, user) in
            if let user = user {
                self?.isAuthenticated = true
                self?.currentUserId = user.uid
                self?.currentUserEmail = user.email ?? "No email provided"
                self?.currentUserName = user.displayName ?? "User" // Fetch displayName
                print("User signed in: \(user.uid), Email: \(user.email ?? "N/A"), Name: \(user.displayName ?? "N/A")")
            } else {
                self?.isAuthenticated = false
                self?.currentUserId = nil
                self?.currentUserEmail = nil
                self?.currentUserName = nil
                print("No user signed in")
            }
        }
        print("SessionManager initialized")
    }
    
    func signOut() {
        do {
            try Auth.auth().signOut()
            self.isAuthenticated = false
            self.currentUserId = nil
            self.currentUserEmail = nil
            self.currentUserName = nil
            print("Signed out successfully, isAuthenticated: \(self.isAuthenticated)")
        } catch {
            print("Error signing out: \(error.localizedDescription)")
        }
    }
    
    func updateUserName(_ name: String) {
        guard let user = Auth.auth().currentUser else {
            print("No authenticated user to update username")
            return
        }
        let changeRequest = user.createProfileChangeRequest()
        changeRequest.displayName = name
        changeRequest.commitChanges { [weak self] error in
            if let error = error {
                print("Error updating username: \(error.localizedDescription)")
            } else {
                DispatchQueue.main.async {
                    self?.currentUserName = name
                    print("Username updated to: \(name)")
                }
            }
        }
    }
}
