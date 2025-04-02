import SwiftUI
import FirebaseAuth

struct SignUpView: View {
    @EnvironmentObject var sessionManager: SessionManager
    @Binding var isLogin: Bool
    
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var confirmPassword: String = ""
    @State private var errorMessage: String?
    @State private var showVerificationAlert: Bool = false
    @State private var agreedToTerms: Bool = false
    @State private var showingTerms: Bool = false
    
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
                        
                        SecureField("Confirm Password", text: $confirmPassword)
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
                        
                        // Terms of Service agreement
                        HStack(alignment: .center) {
                            Button(action: {
                                agreedToTerms.toggle()
                            }) {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 3)
                                        .stroke(theme.textSecondary.opacity(0.5), lineWidth: 1.5)
                                        .frame(width: 20, height: 20)
                                        .background(
                                            agreedToTerms ?
                                            RoundedRectangle(cornerRadius: 3).fill(theme.accentColor) :
                                            RoundedRectangle(cornerRadius: 3).fill(Color.clear)
                                        )
                                    
                                    if agreedToTerms {
                                        Image(systemName: "checkmark")
                                            .font(.system(size: 12, weight: .bold))
                                            .foregroundColor(theme.textPrimary)
                                    }
                                }
                            }
                            
                            Text("I agree to the ")
                                .foregroundColor(theme.textSecondary)
                                .font(theme.captionFont())
                            
                            Button(action: {
                                showingTerms = true
                            }) {
                                Text("Terms of Service")
                                    .foregroundColor(theme.accentColor)
                                    .font(theme.captionFont())
                                    .underline()
                            }
                        }
                        .frame(width: 250, alignment: .leading)
                        .padding(.top, 5)
                        
                        if let errorMessage = errorMessage {
                            Text(errorMessage)
                                .foregroundColor(theme.textPrimary)
                                .multilineTextAlignment(.center)
                                .frame(width: 250)
                                .padding(8)
                                .background(theme.errorColor.opacity(0.3))
                                .cornerRadius(theme.cornerRadiusMedium)
                        }
                        
                        Button(action: signUp) {
                            Text("Create Account")
                                .foregroundColor(theme.textPrimary)
                                .font(theme.bodyFont())
                                .fontWeight(.bold)
                                .padding(10)
                                .frame(maxWidth: .infinity)
                                .background(
                                    agreedToTerms ? theme.taskButtonGradient : LinearGradient(
                                        gradient: Gradient(colors: [theme.textSecondary.opacity(0.3), theme.textSecondary.opacity(0.3)]),
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .cornerRadius(theme.cornerRadiusMedium)
                        }
                        .frame(width: 250)
                        .modifier(theme.buttonShadow())
                        .disabled(!agreedToTerms)
                        
                        HStack {
                            Button("Already have an account?") {
                                isLogin = true
                            }
                            .foregroundColor(theme.accentColor)
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
            .alert("Email Verification Required", isPresented: $showVerificationAlert) {
                Button("OK") {
                    // After dismissing the alert, redirect to login
                    isLogin = true
                }
            } message: {
                Text("A verification email has been sent to \(email). Please verify your email address before logging in.")
            }
            .sheet(isPresented: $showingTerms) {
                TermsOfServiceView()
            }
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
        
        // Ensure terms are accepted
        guard agreedToTerms else {
            errorMessage = "You must agree to the Terms of Service."
            return
        }
        
        // Proceed with Firebase signup
        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            DispatchQueue.main.async {
                if let error = error {
                    self.errorMessage = error.localizedDescription
                } else if let user = authResult?.user {
                    // Send email verification
                    sendEmailVerification(user: user)
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
                    // Show verification alert
                    self.showVerificationAlert = true
                }
            }
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
