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
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.knightGray
                    .ignoresSafeArea()
                
                VStack(spacing: 20) {
                    Spacer()
                    
                    Text("IGRIS")
                        .font(.largeTitle)
                        .foregroundColor(.black)
                        .bold()
                    
                    Image("MainKnight")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 100, height: 100)
                        .cornerRadius(15)
                    
                    VStack(spacing: 15) {
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
                            .frame(width: 250)
                        
                        SecureField("Password", text: $password)
                            .textContentType(.password)
                            .padding(10)
                            .background(Color.white)
                            .cornerRadius(8)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.black, lineWidth: 2)
                            )
                            .frame(width: 250)
                        
                        if let errorMessage = errorMessage {
                            Text(errorMessage)
                                .foregroundColor(.black)
                                .multilineTextAlignment(.center)
                                .frame(width: 250)
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
            }
            .navigationTitle("Login")
            .navigationBarTitleDisplayMode(.inline)
            .alert("Password Reset", isPresented: $showPasswordResetAlert) {
                Button("OK") {}
            } message: {
                Text(passwordResetMessage)
            }
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
    }
}
