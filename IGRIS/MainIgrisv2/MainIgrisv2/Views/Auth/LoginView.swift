import SwiftUI
import FirebaseAuth

struct LoginView: View {
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
                Color.knightGray
                    .ignoresSafeArea()
                
                VStack {
                    Spacer()
                    
                    VStack(spacing: 20) {
                        Text("IGRIS")
                            .font(.largeTitle)
                            .foregroundColor(.black)
                            .bold()
                        
                        Image("MainKnight") // Placeholder image
                            .resizable()
                            .scaledToFit()
                            .frame(width: 100, height: 100)
                            .cornerRadius(15)
                        
                        Group {
                            TextField("Email", text: $email)
                                .textContentType(.emailAddress)
                                .keyboardType(.emailAddress)
                                .padding(10)
                                .background(Color.white)
                                .cornerRadius(8)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(Color.black, lineWidth: 2)
                                )
                                
                            
                            SecureField("Password", text: $password)
                                .textContentType(.password)
                                .padding(10)
                                .background(Color.white)
                                .cornerRadius(8)
                                
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(Color.black, lineWidth: 2)
                                )
                        }
                        .frame(width: 250)
                        
                        if let errorMessage = errorMessage {
                            Text(errorMessage)
                                .foregroundColor(.black)
                                .multilineTextAlignment(.center)
                        }
                        
                        Button(action: login) {
                            Text("Sign In")
                                .foregroundColor(.black)
                                .padding(10)
                                .frame(maxWidth: .infinity)
                                .background(Color.babyblue)
                                .cornerRadius(8)
                        }
                        .frame(width: 250)
                        
                        HStack {
                            Button("Create") {
                                isLogin = false
                            }
                            .foregroundColor(.black)
                            
                            Spacer()
                            
                            Button(action: forgotPassword) {
                                Text("Forgot")
                                    .foregroundColor(.black)
                            }
                        }
                        .padding(.horizontal, 80)
                    }
                    
                    Spacer()
                }
                .alert(isPresented: $showPasswordResetAlert) {
                    Alert(title: Text("Password Reset"), message: Text(passwordResetMessage), dismissButton: .default(Text("OK")))
                }
            }
            .navigationTitle("Login")
            .navigationBarTitleDisplayMode(.inline)
            padding(.bottom, 500)
        }
    }

    private func login() {
        guard !email.isEmpty, !password.isEmpty else {
            errorMessage = "Please fill in all fields."
            return
        }
        Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
            DispatchQueue.main.async {
                if let error = error {
                    self.errorMessage = error.localizedDescription
                } else {
                    sessionManager.isAuthenticated = true
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
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView(isLogin: .constant(true))
            .environmentObject(SessionManager())
    }
}
