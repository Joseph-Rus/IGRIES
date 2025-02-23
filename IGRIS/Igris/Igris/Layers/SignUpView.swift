import SwiftUI
import FirebaseAuth

struct SignUpView: View {
    // MARK: - Environment & State Variables
    @EnvironmentObject var sessionManager: SessionManager
    @Binding var isLogin: Bool
    
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var errorMessage: String?

    var body: some View {
        NavigationView {
            ZStack {
                // Background color
                Color.gray2
                    .ignoresSafeArea()
                
                // Red diagonal corners using GeometryReader + Path
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
                
                // Main VStack for title, image, fields, and button
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
                        // Email field
                        TextField("Email", text: $email)
                            .textContentType(.emailAddress)
                            .keyboardType(.emailAddress)
                            .padding(10)
                            .background(Color.white)
                            .cornerRadius(8)
                        
                        // Password field (secure)
                        SecureField("Password", text: $password)
                            .textContentType(.password)
                            .padding(10)
                            .background(Color.white)
                            .cornerRadius(8)
                    }
                    .frame(width: 250)
                    
                    // Error message
                    if let errorMessage = errorMessage {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .multilineTextAlignment(.center)
                    }
                    
                    // Sign Up button
                    Button(action: signUp) {
                        Text("Create")
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
                    
                    // Already have an account? Log in
                    Button("Already have an account? Log in") {
                        isLogin = true
                    }
                    .foregroundColor(.blue)
                }
                .padding(EdgeInsets(top: 10, leading: 30, bottom: 90, trailing: 40))
            }
            .navigationTitle("Sign Up")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    // MARK: - Sign Up Function
    private func signUp() {
        // Validate input
        guard !email.isEmpty, !password.isEmpty else {
            errorMessage = "Please fill in all fields."
            return
        }
        
        // Create a new user with Firebase Auth using email/password
        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            DispatchQueue.main.async {
                if let error = error {
                    self.errorMessage = error.localizedDescription
                } else {
                    sessionManager.isAuthenticated = true // Navigate to MainChat
                }
            }
        }
    }
}

struct SignUpView_Previews: PreviewProvider {
    static var previews: some View {
        SignUpView(isLogin: .constant(false))
            .environmentObject(SessionManager())
    }
}
