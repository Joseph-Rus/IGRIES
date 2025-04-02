import SwiftUI
import FirebaseAuth

struct EmailVerificationView: View {
    @EnvironmentObject var sessionManager: SessionManager
    @State private var isCheckingVerification = false
    @State private var verificationMessage = "Waiting for email verification..."
    @State private var showResendConfirmation = false
    
    // Timer to periodically check verification status
    let timer = Timer.publish(every: 5, on: .main, in: .common).autoconnect()
    
    // Reference to ThemeManager
    private let theme = ThemeManager.shared
    
    var body: some View {
        ZStack {
            theme.backgroundGradient
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                Text("Email Verification Required")
                    .font(theme.titleFont(size: 24))
                    .fontWeight(.bold)
                    .foregroundColor(theme.textPrimary)
                
                Image(systemName: "envelope.badge")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 80, height: 80)
                    .foregroundColor(theme.accentColor)
                
                Text("We've sent a verification email to:")
                    .foregroundColor(theme.textPrimary)
                    .font(theme.bodyFont())
                
                Text(sessionManager.currentUserEmail ?? "your email address")
                    .foregroundColor(theme.accentColor)
                    .font(theme.bodyFont(size: 18))
                    .fontWeight(.semibold)
                
                Text("Please check your inbox and click the verification link to continue.")
                    .foregroundColor(theme.textPrimary)
                    .font(theme.bodyFont())
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
                
                if isCheckingVerification {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: theme.accentColor))
                        .scaleEffect(1.2)
                }
                
                Text(verificationMessage)
                    .foregroundColor(verificationMessage.contains("verified") ? theme.successColor : theme.textPrimary)
                    .font(theme.bodyFont())
                    .padding()
                
                VStack(spacing: 12) {
                    Button(action: checkVerificationStatus) {
                        Text("I've Verified My Email")
                            .foregroundColor(theme.textPrimary)
                            .font(theme.bodyFont())
                            .fontWeight(.bold)
                            .padding(10)
                            .frame(width: 250)
                            .background(theme.taskButtonGradient)
                            .cornerRadius(theme.cornerRadiusMedium)
                    }
                    .modifier(theme.buttonShadow())
                    
                    Button(action: resendVerificationEmail) {
                        Text("Resend Verification Email")
                            .foregroundColor(theme.accentColor)
                            .font(theme.bodyFont())
                            .padding(10)
                            .frame(width: 250)
                    }
                    
                    Button(action: {
                        sessionManager.signOut()
                    }) {
                        Text("Back to Login")
                            .foregroundColor(theme.textSecondary)
                            .font(theme.bodyFont())
                            .padding(10)
                            .frame(width: 250)
                    }
                }
            }
            .padding()
            .alert(isPresented: $showResendConfirmation) {
                Alert(
                    title: Text("Verification Email Sent"),
                    message: Text("Please check your inbox for the verification link."),
                    dismissButton: .default(Text("OK"))
                )
            }
        }
        .preferredColorScheme(.dark)
        .onAppear {
            // Force reload user to check current verification status
            Auth.auth().currentUser?.reload(completion: { _ in
                checkVerificationStatus()
            })
        }
        .onReceive(timer) { _ in
            // Periodically check if the email has been verified
            // Only if we're not already in the middle of checking
            if !isCheckingVerification {
                checkVerificationStatus()
            }
        }
    }
    
    private func checkVerificationStatus() {
        guard let user = Auth.auth().currentUser else {
            return
        }
        
        isCheckingVerification = true
        verificationMessage = "Checking verification status..."
        
        // Reload user to get the latest verification status
        user.reload { error in
            DispatchQueue.main.async {
                if let error = error {
                    verificationMessage = "Error checking status: \(error.localizedDescription)"
                } else {
                    if user.isEmailVerified {
                        verificationMessage = "Email verified! Redirecting..."
                        // Update the session manager
                        sessionManager.isEmailVerified = true
                        sessionManager.isAuthenticated = true
                        
                        // Wait a moment to show the success message before redirecting
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                            // This will redirect to the main content view via SessionManager
                        }
                    } else {
                        verificationMessage = "Email not verified yet. Please check your inbox."
                    }
                }
                isCheckingVerification = false
            }
        }
    }
    
    private func resendVerificationEmail() {
        guard let user = Auth.auth().currentUser else {
            return
        }
        
        user.sendEmailVerification { error in
            DispatchQueue.main.async {
                if let error = error {
                    verificationMessage = "Error: \(error.localizedDescription)"
                } else {
                    showResendConfirmation = true
                }
            }
        }
    }
}

struct EmailVerificationView_Previews: PreviewProvider {
    static var previews: some View {
        EmailVerificationView()
            .environmentObject(SessionManager())
            .preferredColorScheme(.dark)
    }
}
