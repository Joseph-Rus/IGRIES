import SwiftUI

struct TermsOfServiceView: View {
    @Environment(\.dismiss) var dismiss
    
    // Reference to ThemeManager
    private let theme = ThemeManager.shared
    
    var body: some View {
        ZStack {
            // Background color
            theme.darkBackground
                .ignoresSafeArea()
            
            VStack {
                // Header
                HStack {
                    Text("Terms of Service")
                        .font(theme.titleFont(size: 22))
                        .foregroundColor(theme.textPrimary)
                    
                    Spacer()
                    
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title2)
                            .foregroundColor(theme.textSecondary)
                    }
                }
                .padding(.bottom, 20)
                
                // Terms content in a scrollable view
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        Group {
                            Text("Last Updated: April 1, 2025")
                                .font(theme.captionFont())
                                .foregroundColor(theme.textSecondary)
                                .padding(.bottom, 8)
                            
                            Text("1. Acceptance of Terms")
                                .font(theme.bodyFont())
                                .fontWeight(.bold)
                                .foregroundColor(theme.textPrimary)
                            
                            Text("By accessing or using the IGRIS application ('App'), you agree to be bound by these Terms of Service ('Terms'). If you disagree with any part of the terms, you do not have permission to access the App.")
                                .font(theme.captionFont())
                                .foregroundColor(theme.textSecondary)
                                .fixedSize(horizontal: false, vertical: true)
                            
                            Text("2. Description of Service")
                                .font(theme.bodyFont())
                                .fontWeight(.bold)
                                .foregroundColor(theme.textPrimary)
                            
                            Text("IGRIS is a task management and productivity application designed to help users organize their academic and personal tasks. The App offers features including task creation, calendar integration, and notification services.")
                                .font(theme.captionFont())
                                .foregroundColor(theme.textSecondary)
                                .fixedSize(horizontal: false, vertical: true)
                            
                            Text("3. User Accounts")
                                .font(theme.bodyFont())
                                .fontWeight(.bold)
                                .foregroundColor(theme.textPrimary)
                            
                            Text("To use certain features of the App, you must register for an account. You agree to provide accurate information and to keep this information updated. You are responsible for maintaining the confidentiality of your account and password and for restricting access to your account. You accept responsibility for all activities that occur under your account.")
                                .font(theme.captionFont())
                                .foregroundColor(theme.textSecondary)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        
                        Group {
                            Text("4. Privacy Policy")
                                .font(theme.bodyFont())
                                .fontWeight(.bold)
                                .foregroundColor(theme.textPrimary)
                            
                            Text("Your use of the App is also governed by our Privacy Policy, which is incorporated by reference into these Terms. Please review our Privacy Policy to understand our practices regarding your personal information.")
                                .font(theme.captionFont())
                                .foregroundColor(theme.textSecondary)
                                .fixedSize(horizontal: false, vertical: true)
                            
                            Text("5. User Content")
                                .font(theme.bodyFont())
                                .fontWeight(.bold)
                                .foregroundColor(theme.textPrimary)
                            
                            Text("You retain all rights to the content you create, upload, or store within the App. By submitting content to the App, you grant us a non-exclusive, worldwide, royalty-free license to use, modify, and display this content solely for the purpose of providing and improving the App's services to you.")
                                .font(theme.captionFont())
                                .foregroundColor(theme.textSecondary)
                                .fixedSize(horizontal: false, vertical: true)
                            
                            Text("6. Calendar Integration")
                                .font(theme.bodyFont())
                                .fontWeight(.bold)
                                .foregroundColor(theme.textPrimary)
                            
                            Text("The App may integrate with third-party calendar services. You acknowledge that such integration is subject to the terms and conditions of those third-party services, and we are not responsible for any issues arising from those services.")
                                .font(theme.captionFont())
                                .foregroundColor(theme.textSecondary)
                                .fixedSize(horizontal: false, vertical: true)
                            
                            Text("7. Acceptable Use")
                                .font(theme.bodyFont())
                                .fontWeight(.bold)
                                .foregroundColor(theme.textPrimary)
                            
                            Text("You agree not to use the App to: (a) violate any laws; (b) infringe the rights of others; (c) transmit viruses or harmful code; (d) interfere with the operation of the App; or (e) engage in any activity that could harm other users or us.")
                                .font(theme.captionFont())
                                .foregroundColor(theme.textSecondary)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        
                        Group {
                            Text("8. Termination")
                                .font(theme.bodyFont())
                                .fontWeight(.bold)
                                .foregroundColor(theme.textPrimary)
                            
                            Text("We reserve the right to terminate or suspend your account and access to the App at our sole discretion, without notice, for conduct that we believe violates these Terms or is harmful to other users, us, or third parties, or for any other reason.")
                                .font(theme.captionFont())
                                .foregroundColor(theme.textSecondary)
                                .fixedSize(horizontal: false, vertical: true)
                            
                            Text("9. Disclaimers")
                                .font(theme.bodyFont())
                                .fontWeight(.bold)
                                .foregroundColor(theme.textPrimary)
                            
                            Text("THE APP IS PROVIDED 'AS IS' WITHOUT WARRANTIES OF ANY KIND, EITHER EXPRESS OR IMPLIED. We do not guarantee that the App will always be safe, secure, or error-free, or that it will function without disruptions, delays, or imperfections.")
                                .font(theme.captionFont())
                                .foregroundColor(theme.textSecondary)
                                .fixedSize(horizontal: false, vertical: true)
                            
                            Text("10. Limitation of Liability")
                                .font(theme.bodyFont())
                                .fontWeight(.bold)
                                .foregroundColor(theme.textPrimary)
                            
                            Text("TO THE MAXIMUM EXTENT PERMITTED BY LAW, WE SHALL NOT BE LIABLE FOR ANY INDIRECT, INCIDENTAL, SPECIAL, CONSEQUENTIAL, OR PUNITIVE DAMAGES, OR ANY LOSS OF PROFITS OR REVENUES, WHETHER INCURRED DIRECTLY OR INDIRECTLY.")
                                .font(theme.captionFont())
                                .foregroundColor(theme.textSecondary)
                                .fixedSize(horizontal: false, vertical: true)
                            
                            Text("11. Changes to Terms")
                                .font(theme.bodyFont())
                                .fontWeight(.bold)
                                .foregroundColor(theme.textPrimary)
                            
                            Text("We reserve the right to modify these Terms at any time. We will provide notice of significant changes by posting the new Terms on the App. Your continued use of the App after any changes to the Terms constitutes your acceptance of the new Terms.")
                                .font(theme.captionFont())
                                .foregroundColor(theme.textSecondary)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        
                        Group {
                            Text("12. Governing Law")
                                .font(theme.bodyFont())
                                .fontWeight(.bold)
                                .foregroundColor(theme.textPrimary)
                            
                            Text("These Terms shall be governed by the laws of the jurisdiction in which the App owner is established, without regard to its conflict of law principles.")
                                .font(theme.captionFont())
                                .foregroundColor(theme.textSecondary)
                                .fixedSize(horizontal: false, vertical: true)
                            
                            Text("13. Contact Information")
                                .font(theme.bodyFont())
                                .fontWeight(.bold)
                                .foregroundColor(theme.textPrimary)
                            
                            Text("If you have any questions about these Terms, please contact us at igrisassist@gmail.com.")
                                .font(theme.captionFont())
                                .foregroundColor(theme.textSecondary)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                    .padding(.bottom, 20)
                }
                
                // Accept button
                Button(action: {
                    dismiss()
                }) {
                    Text("I Understand and Accept")
                        .font(theme.bodyFont())
                        .fontWeight(.bold)
                        .foregroundColor(Color.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(theme.accentColor)
                        .cornerRadius(theme.cornerRadiusMedium)
                }
                .padding(.top, 10)
            }
            .padding(24)
        }
        .preferredColorScheme(.dark)
    }
}

struct TermsOfServiceView_Previews: PreviewProvider {
    static var previews: some View {
        TermsOfServiceView()
            .preferredColorScheme(.dark)
    }
}
