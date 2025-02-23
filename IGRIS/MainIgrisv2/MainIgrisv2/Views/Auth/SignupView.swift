import SwiftUI
import FirebaseAuth

struct SignUpView: View {
    @EnvironmentObject var sessionManager: SessionManager
    @Binding var isLogin: Bool
    
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var confirmPassword: String = ""  // Added confirmation field
    @State private var errorMessage: String?
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.knightGray
                    .ignoresSafeArea()
                
                VStack(spacing: 20) {
                    Text("IGRIS")
                        .font(.largeTitle)
                        .foregroundColor(.black)
                        .bold()
                    
                    Image("MainKnight")
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
                        
                        SecureField("Confirm Password", text: $confirmPassword)  // Added confirmation field
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
                            .foregroundColor(.red)
                            .multilineTextAlignment(.center)
                    }
                    
                    Button(action: signUp) {
                        Text("Create")
                            .foregroundColor(.black)
                            .padding(10)
                            .frame(maxWidth: .infinity)
                            .background(Color.babyblue)
                            .cornerRadius(8)
                    }
                    .frame(width: 250)
                    
                    Button("Already have an account? Log in") {
                        isLogin = true
                    }
                    .foregroundColor(.black)
                }
                .padding()
            }
            .navigationTitle("Sign Up")
            .navigationBarTitleDisplayMode(.inline)
        }
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
