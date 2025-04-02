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
    @State private var showVerificationAlert: Bool = false
    
    // Reference to ThemeManager
    private let theme = ThemeManager.shared
    
    // Background gradient - using ThemeManager
    private var backgroundGradient: some View {
        theme.backgroundGradient
            .ignoresSafeArea()
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                backgroundGradient
                
                VStack(spacing: 20) {
                    Spacer()
                    
                    Text("IGRIS")
                        .font(theme.titleFont(size: 34))
                        .fontWeight(.bold)
                        .foregroundColor(theme.textPrimary)
                    
                    Image("MainKnight")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 100, height: 100)
                        .cornerRadius(theme.cornerRadiusMedium)
                        .modifier(theme.standardShadow(radius: 3, x: 0, y: 2))
                    
                    VStack(spacing: 15) {
                        TextField("Email", text: $email)
                            .textContentType(.emailAddress)
                            .keyboardType(.emailAddress)
                            .padding(10)
                            .background(theme.cardBackgroundAlt)
                            .cornerRadius(theme.cornerRadiusMedium)
                            .overlay(
                                RoundedRectangle(cornerRadius: theme.cornerRadiusMedium)
                                    .stroke(theme.textSecondary.opacity(0.5), lineWidth: 1)
                            )
                            .foregroundColor(theme.textPrimary)
                            .frame(width: 250)
                        
                        SecureField("Password", text: $password)
                            .textContentType(.password)
                            .padding(10)
                            .background(theme.cardBackgroundAlt)
                            .cornerRadius(theme.cornerRadiusMedium)
                            .overlay(
                                RoundedRectangle(cornerRadius: theme.cornerRadiusMedium)
                                    .stroke(theme.textSecondary.opacity(0.5), lineWidth: 1)
                            )
                            .foregroundColor(theme.textPrimary)
                            .frame(width: 250)
                        
                        if let errorMessage = errorMessage {
                            Text(errorMessage)
                                .foregroundColor(theme.textPrimary)
                                .multilineTextAlignment(.center)
                                .frame(width: 250)
                                .padding(8)
                                .background(theme.errorColor.opacity(0.3))
                                .cornerRadius(theme.cornerRadiusMedium)
                        }
                        
                        Button(action: login) {
                            Text("Sign In")
                                .foregroundColor(theme.textPrimary)
                                .font(theme.bodyFont())
                                .fontWeight(.bold)
                                .padding(10)
                                .frame(maxWidth: .infinity)
                                .background(theme.taskButtonGradient)
                                .cornerRadius(theme.cornerRadiusMedium)
                        }
                        .frame(width: 250)
                        .modifier(theme.buttonShadow())
                        
                        HStack {
                            Button("Create Account") {
                                isLogin = false
                            }
                            .foregroundColor(theme.accentColor)
                            
                            Spacer()
                            
                            Button(action: forgotPassword) {
                                Text("Forgot Password")
                                    .foregroundColor(theme.accentColor)
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
            .alert("Email Verification Required", isPresented: $showVerificationAlert) {
                Button("Resend Verification Email") {
                    if let user = Auth.auth().currentUser {
                        sendEmailVerification(user: user)
                    }
                }
                Button("OK", role: .cancel) {}
            } message: {
                Text("Your email has not been verified yet. Please check your inbox for a verification link or request a new one.")
            }
        }
        .preferredColorScheme(.dark)
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
                } else if let user = authResult?.user {
                    // Check if email is verified
                    if user.isEmailVerified {
                        print("Login succeeded, setting isAuthenticated to true")
                        self.sessionManager.isAuthenticated = true
                        self.resetToMain()
                    } else {
                        print("Email not verified")
                        self.showVerificationAlert = true
                        // Sign out since email is not verified
                        try? Auth.auth().signOut()
                    }
                }
            }
        }
    }
    
    private func sendEmailVerification(user: User) {
        user.sendEmailVerification { error in
            DispatchQueue.main.async {
                if let error = error {
                    self.errorMessage = "Error sending verification email: \(error.localizedDescription)"
                } else {
                    self.errorMessage = "Verification email sent. Please check your inbox."
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
