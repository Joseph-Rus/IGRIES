import SwiftUI
import FirebaseAuth

struct SignUpView: View {
    @EnvironmentObject var sessionManager: SessionManager
    @Binding var isLogin: Bool
    
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var confirmPassword: String = ""
    @State private var errorMessage: String?
    
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
                        .cornerRadius(10) // Updated to match LoginView rounded corners
                        .shadow(color: .black.opacity(0.1), radius: 3, x: 0, y: 2) // Updated to match LoginView shadow
                    
                    VStack(spacing: 15) {
                        TextField("Email", text: $email)
                            .textContentType(.emailAddress)
                            .keyboardType(.emailAddress)
                            .padding(10)
                            .background(Color.white.opacity(0.2))
                            .cornerRadius(10) // Updated to match LoginView
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.white.opacity(0.5), lineWidth: 1)
                            )
                            .foregroundColor(.white)
                            .frame(width: 250)
                        
                        SecureField("Password", text: $password)
                            .textContentType(.password)
                            .padding(10)
                            .background(Color.white.opacity(0.2))
                            .cornerRadius(10) // Updated to match LoginView
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.white.opacity(0.5), lineWidth: 1)
                            )
                            .foregroundColor(.white)
                            .frame(width: 250)
                        
                        SecureField("Confirm Password", text: $confirmPassword)
                            .textContentType(.password)
                            .padding(10)
                            .background(Color.white.opacity(0.2))
                            .cornerRadius(10) // Updated to match LoginView
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
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
                                .cornerRadius(10) // Updated to match LoginView
                        }
                        
                        Button(action: signUp) {
                            Text("Create Account")
                                .foregroundColor(.white)
                                .fontWeight(.bold)
                                .padding(10)
                                .frame(maxWidth: .infinity)
                                .background(
                                    LinearGradient(
                                        gradient: Gradient(colors: [Color.blue, Color.purple]), // Updated to match LoginView gradient
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .cornerRadius(10) // Updated to match LoginView
                        }
                        .frame(width: 250)
                        .shadow(color: .black.opacity(0.1), radius: 3, x: 0, y: 2) // Updated to match LoginView
                        
                        HStack {
                            Button("Already have an account?") {
                                isLogin = true
                            }
                            .foregroundColor(.white)
                        }
                        .padding(.horizontal, 80)
                    }
                    
                    Spacer()
                }
                .padding()
            }
            .navigationTitle("Sign Up")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.dark, for: .navigationBar)
        }
        .preferredColorScheme(.dark)
    }
    
    private func signUp() {
        // Validate all fields are filled
        guard !email.isEmpty, !password.isEmpty, !confirmPassword.isEmpty else {
            errorMessage = "Please fill in all fields."
            return
        }
        
        // Check if passwords match
        guard password == confirmPassword else {
            errorMessage = "Passwords do not match."
            return
        }
        
        // Proceed with Firebase signup
        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            DispatchQueue.main.async {
                if let error = error {
                    self.errorMessage = error.localizedDescription
                } else {
                    sessionManager.isAuthenticated = true
                    self.resetToMain()
                }
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
            print("Root view reset to ContentView after signup")
        } else {
            print("Failed to reset root view to ContentView")
        }
    }
}

struct SignUpView_Previews: PreviewProvider {
    static var previews: some View {
        SignUpView(isLogin: .constant(false))
            .environmentObject(SessionManager())
            .preferredColorScheme(.dark)
    }
}
