import Foundation
import FirebaseAuth

class SessionManager: ObservableObject {
    @Published var isAuthenticated: Bool = false
    @Published var currentUserId: String? = nil
    @Published var currentUserEmail: String? = nil
    @Published var currentUserName: String? = nil
    @Published var isEmailVerified: Bool = false
    
    init() {
        Auth.auth().addStateDidChangeListener { [weak self] (_, user) in
            if let user = user {
                // Check if email is verified before setting authenticated status
                let verified = user.isEmailVerified
                self?.isEmailVerified = verified
                
                if verified {
                    self?.isAuthenticated = true
                    self?.currentUserId = user.uid
                    self?.currentUserEmail = user.email ?? "No email provided"
                    self?.currentUserName = user.displayName ?? "User"
                    print("User signed in: \(user.uid), Email: \(user.email ?? "N/A"), Name: \(user.displayName ?? "N/A"), Verified: \(verified)")
                } else {
                    // User is logged in but email not verified
                    self?.isAuthenticated = false
                    self?.currentUserId = user.uid
                    self?.currentUserEmail = user.email
                    self?.currentUserName = user.displayName
                    print("User signed in but email not verified: \(user.uid), Email: \(user.email ?? "N/A")")
                    
                    // Sign out since email is not verified
                    try? Auth.auth().signOut()
                }
            } else {
                self?.isAuthenticated = false
                self?.currentUserId = nil
                self?.currentUserEmail = nil
                self?.currentUserName = nil
                self?.isEmailVerified = false
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
            self.isEmailVerified = false
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
    
    func refreshVerificationStatus() {
        guard let user = Auth.auth().currentUser else {
            return
        }
        
        // Reload user to get the latest verification status
        user.reload { [weak self] error in
            if let error = error {
                print("Error reloading user: \(error.localizedDescription)")
            } else {
                DispatchQueue.main.async {
                    self?.isEmailVerified = user.isEmailVerified
                    if user.isEmailVerified {
                        self?.isAuthenticated = true
                    }
                }
            }
        }
    }
    
    func sendVerificationEmail(completion: @escaping (Error?) -> Void) {
        guard let user = Auth.auth().currentUser else {
            completion(NSError(domain: "SessionManager", code: 1, userInfo: [NSLocalizedDescriptionKey: "No user is signed in"]))
            return
        }
        
        user.sendEmailVerification(completion: completion)
    }
}
