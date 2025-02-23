import SwiftUI
import FirebaseAuth

struct LoginView: View {
    // MARK: - Environment & State Variables
    @EnvironmentObject var sessionManager: SessionManager
    @Binding var isLogin: Bool
    
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var errorMessage: String?
    @State private var showPasswordResetAlert: Bool = false
    @State private var passwordResetMessage: String = ""

    var body: some View {
        NavigationView {
            ZStack {
                // Background color and red diagonal shapes
                Color.gray2
                    .ignoresSafeArea()
                
                GeometryReader { geo in
                    // Top-left red shape
                    Path { path in
                        path.move(to: .zero)
                        path.addLine(to: CGPoint(x: 0, y: geo.size.height * 0.2))
                        path.addLine(to: CGPoint(x: geo.size.width * 0.6, y: 0))
                        path.closeSubpath()
                    }
                    .fill(Color.red2)
                    
                    // Bottom-right red shape
                    Path { path in
                        path.move(to: CGPoint(x: geo.size.width, y: geo.size.height))
                        path.addLine(to: CGPoint(x: geo.size.width, y: geo.size.height * 0.8))
                        path.addLine(to: CGPoint(x: geo.size.width * 0.4, y: geo.size.height))
                        path.closeSubpath()
                    }
                    .fill(Color.red2)
                }
                .ignoresSafeArea()
                
                // Centered content using VStack with Spacers
                VStack {
                    Spacer()
                    
                    VStack(spacing: 20) {
                        // App title
                        Text("IGRIS")
                            .font(.largeTitle)
                            .foregroundColor(.white)
                            .bold()
                        
                        Image("MainKnight")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 100, height: 100)
                            .cornerRadius(15)
                        
                        // Input fields
                        Group {
                            TextField("Email", text: $email)
                                .textContentType(.emailAddress)
                                .keyboardType(.emailAddress)
                                .padding(10)
                                .background(Color.white)
                                .cornerRadius(8)
                            
                            SecureField("Password", text: $password)
                                .textContentType(.password)
                                .padding(10)
                                .background(Color.white)
                                .cornerRadius(8)
                        }
                        .frame(width: 250)
                        
                        // Error message display
                        if let errorMessage = errorMessage {
                            Text(errorMessage)
                                .foregroundColor(.red)
                                .multilineTextAlignment(.center)
                        }
                        
                        // Sign In button
                        Button(action: login) {
                            Text("Sign In")
                                .foregroundColor(.white)
                                .padding(10)
                                .frame(maxWidth: .infinity)
                                .background(Color.black)
                                .cornerRadius(8)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(Color.white, lineWidth: 1)
                                )
                        }
                        .frame(width: 250)
                        
                        // Bottom interactive buttons for "Create Account" and "Forgot Password"
                        HStack {
                            Button("Create Account") {
                                isLogin = false
                            }
                            .foregroundColor(.blue)
                            
                            Spacer()
                            
                            Button(action: forgotPassword) {
                                Text("Forgot Password")
                                    .foregroundColor(.blue)
                            }
                        }
                        .padding(.horizontal, 30)
                    }
                    
                    Spacer()
                }
                .alert(isPresented: $showPasswordResetAlert) {
                    Alert(title: Text("Password Reset"), message: Text(passwordResetMessage), dismissButton: .default(Text("OK")))
                }
            }
            .navigationTitle("Login")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    // MARK: - Login Function
    private func login() {
        // Validate input
        guard !email.isEmpty, !password.isEmpty else {
            errorMessage = "Please fill in all fields."
            return
        }
        
        // Sign in with Firebase Auth using email/password
        Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
            DispatchQueue.main.async {
                if let error = error {
                    self.errorMessage = error.localizedDescription
                } else {
                    sessionManager.isAuthenticated = true // Navigate to MainChat
                }
            }
        }
    }
    
    // MARK: - Forgot Password Function
    private func forgotPassword() {
        // Ensure an email is provided
        guard !email.isEmpty else {
            errorMessage = "Please enter your email for password reset."
            return
        }
        
        // Trigger Firebase password reset
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
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView(isLogin: .constant(true))
            .environmentObject(SessionManager())
    }
}
