import SwiftUI
import FirebaseAuth
import UIKit

struct LoginView: View {
    @EnvironmentObject var sessionManager: SessionManager
    @Binding var isLogin: Bool
    
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var errorMessage: String?
    @State private var showPasswordResetAlert: Bool = false
    @State private var passwordResetMessage: String = ""
    
    // Background gradient - already matches TodoListView
    private var backgroundGradient: some View {
        LinearGradient(
            gradient: Gradient(colors: [
                Color.blue.opacity(0.7),
                Color.purple.opacity(0.7)
            ]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                backgroundGradient
                
                VStack(spacing: 20) {
                    Spacer()
                    
                    Text("IGRIS")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Image("MainKnight")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 100, height: 100)
                        .cornerRadius(10) // Updated to match TodoListView rounded corners
                        .shadow(color: .black.opacity(0.1), radius: 3, x: 0, y: 2) // Updated to match TodoListView shadow
                    
                    VStack(spacing: 15) {
                        TextField("Email", text: $email)
                            .textContentType(.emailAddress)
                            .keyboardType(.emailAddress)
                            .padding(10)
                            .background(Color.white.opacity(0.2)) // Already matches TodoListView
                            .cornerRadius(10) // Updated to match TodoListView rounded corners
                            .overlay(
                                RoundedRectangle(cornerRadius: 10) // Updated to match corner radius
                                    .stroke(Color.white.opacity(0.5), lineWidth: 1)
                            )
                            .foregroundColor(.white)
                            .frame(width: 250)
                        
                        SecureField("Password", text: $password)
                            .textContentType(.password)
                            .padding(10)
                            .background(Color.white.opacity(0.2)) // Already matches TodoListView
                            .cornerRadius(10) // Updated to match TodoListView rounded corners
                            .overlay(
                                RoundedRectangle(cornerRadius: 10) // Updated to match corner radius
                                    .stroke(Color.white.opacity(0.5), lineWidth: 1)
                            )
                            .foregroundColor(.white)
                            .frame(width: 250)
                        
                        if let errorMessage = errorMessage {
                            Text(errorMessage)
                                .foregroundColor(.white)
                                .multilineTextAlignment(.center)
                                .frame(width: 250)
                                .padding(8)
                                .background(Color.red.opacity(0.3))
                                .cornerRadius(10) // Updated to match TodoListView rounded corners
                        }
                        
                        Button(action: login) {
                            Text("Sign In")
                                .foregroundColor(.white)
                                .fontWeight(.bold)
                                .padding(10)
                                .frame(maxWidth: .infinity)
                                .background(
                                    LinearGradient(
                                        gradient: Gradient(colors: [Color.blue, Color.purple]), // Updated to match TodoListView gradient
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .cornerRadius(10) // Updated to match TodoListView rounded corners
                        }
                        .frame(width: 250)
                        .shadow(color: .black.opacity(0.1), radius: 3, x: 0, y: 2) // Updated to match TodoListView shadow
                        
                        HStack {
                            Button("Create Account") {
                                isLogin = false
                            }
                            .foregroundColor(.white)
                            
                            Spacer()
                            
                            Button(action: forgotPassword) {
                                Text("Forgot Password")
                                    .foregroundColor(.white)
                            }
                        }
                        .padding(.horizontal, 80)
                    }
                    
                    Spacer()
                }
                .padding()
            }
            .navigationTitle("Login")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .alert("Password Reset", isPresented: $showPasswordResetAlert) {
                Button("OK") {}
            } message: {
                Text(passwordResetMessage)
            }
        }
        .preferredColorScheme(.dark) // Already matches TodoListView
    }
    
    private func login() {
        guard !email.isEmpty, !password.isEmpty else {
            errorMessage = "Please fill in all fields."
            return
        }
        Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("Login failed: \(error.localizedDescription)")
                    self.errorMessage = error.localizedDescription
                } else {
                    print("Login succeeded, setting isAuthenticated to true")
                    self.sessionManager.isAuthenticated = true
                    self.resetToMain()
                }
            }
        }
    }
    
    private func forgotPassword() {
        guard !email.isEmpty else {
            errorMessage = "Please enter your email for password reset."
            return
        }
        Auth.auth().sendPasswordReset(withEmail: email) { error in
            DispatchQueue.main.async {
                if let error = error {
                    self.passwordResetMessage = error.localizedDescription
                } else {
                    self.passwordResetMessage = "A password reset link has been sent to \(self.email)."
                }
                self.showPasswordResetAlert = true
            }
        }
    }
    
    private func resetToMain() {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {
            let mainView = ContentView()
                .environmentObject(sessionManager)
                .environmentObject(TaskViewModel())
                .environmentObject(EventViewModel())
            window.rootViewController = UIHostingController(rootView: mainView)
            window.makeKeyAndVisible()
            print("Root view reset to ContentView after login")
        } else {
            print("Failed to reset root view to ContentView")
        }
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView(isLogin: .constant(true))
            .environmentObject(SessionManager())
            .preferredColorScheme(.dark)
    }
}
