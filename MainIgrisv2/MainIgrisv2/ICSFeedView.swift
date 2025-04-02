import SwiftUI

struct ICSFeedView: View {
    @EnvironmentObject var sessionManager: SessionManager
    @EnvironmentObject var taskVM: TaskViewModel
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var colorScheme
    
    // Theme manager for consistent styling
    private let theme = ThemeManager.shared
    
    @State private var urlInput: String = ""
    @State private var isLoading: Bool = false
    @State private var errorMessage: String?
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Use the app's background gradient
                theme.backgroundGradient
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        Text("Sync Your Calendar")
                            .font(theme.titleFont(size: 22))
                            .foregroundColor(theme.textPrimary)
                        
                        Text("Enter your ICS feed URL to import tasks.")
                            .font(theme.bodyFont())
                            .foregroundColor(theme.textSecondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                        
                        // Input field with styling
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Calendar URL")
                                .font(theme.captionFont())
                                .foregroundColor(theme.textSecondary)
                                .padding(.leading, 4)
                            
                            TextField("https://example.com/calendar.ics", text: $urlInput)
                                .padding()
                                .background(
                                    RoundedRectangle(cornerRadius: theme.cornerRadiusMedium)
                                        .fill(theme.cardBackgroundAlt)
                                )
                                .foregroundColor(theme.textPrimary)
                                .keyboardType(.URL)
                                .autocapitalization(.none)
                                .disableAutocorrection(true)
                        }
                        .padding(.horizontal)
                        
                        // Show error message if any
                        if let errorMessage = errorMessage {
                            Text(errorMessage)
                                .foregroundColor(theme.errorColor)
                                .font(theme.captionFont())
                                .padding(.horizontal)
                                .multilineTextAlignment(.center)
                        }
                        
                        // Status indicator
                        if isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: theme.accentColor))
                                .padding()
                        }
                        
                        // Action buttons
                        VStack(spacing: 16) {
                            Button(action: saveICS) {
                                Text("Sync Calendar")
                                    .font(theme.bodyFont())
                                    .fontWeight(.semibold)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(theme.taskButtonGradient)
                                    .foregroundColor(.white)
                                    .cornerRadius(theme.cornerRadiusMedium)
                                    .modifier(theme.buttonShadow())
                            }
                            .disabled(isLoading || urlInput.isEmpty)
                            
                            if taskVM.icsLink != nil {
                                Button(action: removeICS) {
                                    Text("Remove Calendar")
                                        .font(theme.bodyFont())
                                        .fontWeight(.semibold)
                                        .frame(maxWidth: .infinity)
                                        .padding()
                                        .background(
                                            RoundedRectangle(cornerRadius: theme.cornerRadiusMedium)
                                                .fill(theme.errorColor.opacity(0.8))
                                        )
                                        .foregroundColor(.white)
                                        .cornerRadius(theme.cornerRadiusMedium)
                                        .modifier(theme.buttonShadow())
                                }
                            }
                            
//                            Button(action: {
//                                // Use sample URL
//                                urlInput = "https://calbaptist.blackboard.com/webapps/calendar/calendarFeed/02190916b6604c7ba3be7648eddd9f4f/learn.ics"
//                            }) {
//                                Text("Use Sample URL")
//                                    .font(theme.bodyFont())
//                                    .frame(maxWidth: .infinity)
//                                    .padding()
//                                    .background(theme.cardBackground)
//                                    .foregroundColor(theme.textSecondary)
//                                    .cornerRadius(theme.cornerRadiusMedium)
//                            }
//                            .disabled(isLoading)
                            
                            Button(action: {
                                dismiss()
                            }) {
                                Text("Cancel")
                                    .font(theme.bodyFont())
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(
                                        RoundedRectangle(cornerRadius: theme.cornerRadiusMedium)
                                            .fill(theme.cardBackground.opacity(0.5))
                                    )
                                    .foregroundColor(theme.textSecondary)
                                    .cornerRadius(theme.cornerRadiusMedium)
                            }
                        }
                        .padding(.horizontal)
                        
                        Spacer(minLength: 50)
                    }
                    .padding(.top, 20)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Calendar Integration")
                        .font(theme.titleFont())
                        .foregroundColor(theme.textPrimary)
                }
                
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(theme.errorColor)
                }
            }
            .onAppear {
                urlInput = taskVM.icsLink ?? ""
            }
        }
        .preferredColorScheme(.dark)
    }
    
    private func saveICS() {
        guard !urlInput.isEmpty, let userId = sessionManager.currentUserId else {
            errorMessage = "Invalid URL or user not logged in."
            return
        }
        
        guard let _ = URL(string: urlInput) else {
            errorMessage = "Invalid URL format. Please enter a valid URL."
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        taskVM.saveICSLink(urlInput, for: userId) { success in
            DispatchQueue.main.async {
                self.isLoading = false
                if success {
                    self.dismiss()
                } else {
                    self.errorMessage = "Failed to sync calendar. Please check your URL and try again."
                }
            }
        }
    }
    
    private func removeICS() {
        guard let userId = sessionManager.currentUserId else {
            return
        }
        
        isLoading = true
        
        taskVM.removeICSLink(for: userId) { success in
            DispatchQueue.main.async {
                self.isLoading = false
                if success {
                    self.urlInput = ""
                } else {
                    self.errorMessage = "Failed to remove ICS link"
                }
            }
        }
    }
}

// Preview provider for SwiftUI canvas
struct ICSFeedView_Previews: PreviewProvider {
    static var previews: some View {
        ICSFeedView()
            .environmentObject(SessionManager())
            .environmentObject(TaskViewModel())
            .preferredColorScheme(.dark)
    }
}
