import SwiftUI

struct ICSFeedView: View {
    @EnvironmentObject var sessionManager: SessionManager
    @EnvironmentObject var taskVM: TaskViewModel
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var colorScheme
    
    @State private var urlInput: String = ""
    @State private var isLoading: Bool = false
    @State private var errorMessage: String?
    
    // Background view - updated to match TodoListView
    private var backgroundView: some View {
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
    
    // URL Input field - styled to match TodoListView
    private var urlInputField: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Calendar URL")
                .font(.headline)
                .foregroundColor(.white)
                .padding(.horizontal, 4)
            
            TextField("Enter ICS URL", text: $urlInput)
                .padding()
                .background(Color.white.opacity(0.2))
                .foregroundColor(.white)
                .cornerRadius(10)
                .shadow(color: .black.opacity(0.1), radius: 3, x: 0, y: 2)
        }
    }
    
    // Loading and error messages
    private var statusMessages: some View {
        VStack(spacing: 8) {
            if isLoading {
                ProgressView("Loading...")
                    .padding(.vertical, 8)
                    .foregroundColor(.white)
            }
            
            if let error = errorMessage {
                Text(error)
                    .foregroundColor(.red)
                    .font(.subheadline)
                    .padding(.vertical, 4)
            }
        }
    }
    
    // Save button - styled to match TodoListView
    private var saveButton: some View {
        Button(action: { saveICS() }) {
            Text("Save ICS")
                .fontWeight(.semibold)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: [.blue, .purple]),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .cornerRadius(10)
                .shadow(color: .black.opacity(0.1), radius: 3, x: 0, y: 2)
        }
    }
    
    // Remove button - styled to match TodoListView
    private var removeButton: some View {
        Group {
            if taskVM.icsLink != nil {
                Button(action: { removeICS() }) {
                    Text("Remove ICS")
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            LinearGradient(
                                gradient: Gradient(colors: [.red, .red.opacity(0.7)]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(10)
                        .shadow(color: .black.opacity(0.1), radius: 3, x: 0, y: 2)
                }
            }
        }
    }
    
    // Cancel button - styled to match TodoListView
    private var cancelButton: some View {
        Button(action: { dismiss() }) {
            Text("Cancel")
                .fontWeight(.semibold)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(
                    Color.white.opacity(0.2)
                )
                .cornerRadius(10)
                .shadow(color: .black.opacity(0.1), radius: 3, x: 0, y: 2)
        }
    }
    
    // Button stack
    private var buttonStack: some View {
        VStack(spacing: 16) {
            saveButton
            removeButton
            cancelButton
        }
    }
    
    // Main content
    private var mainContent: some View {
        VStack(alignment: .center, spacing: 24) {
            Text("Add ICS Calendar")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            urlInputField
            statusMessages
            
            Spacer(minLength: 30)
            
            buttonStack
                .padding(.bottom, 30)
        }
        .padding(.top, 20)
        .padding(.horizontal, 16)
    }
    
    // Main body
    var body: some View {
        NavigationStack {
            ZStack {
                backgroundView
                
                ScrollView {
                    mainContent
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Calendar Integration")
                        .font(.headline)
                        .foregroundColor(.white)
                }
            }
            .onAppear {
                urlInput = taskVM.icsLink ?? ""
            }
        }
        .preferredColorScheme(.dark) // Force dark mode to match TodoListView
    }
    
    private func saveICS() {
        guard !urlInput.isEmpty, let userId = sessionManager.currentUserId else {
            errorMessage = "Invalid URL or user not logged in."
            return
        }
        isLoading = true
        taskVM.saveICSLink(urlInput, for: userId)
        isLoading = false
        dismiss()
    }
    
    private func removeICS() {
        guard let userId = sessionManager.currentUserId else { return }
        taskVM.removeICSLink(for: userId)
        urlInput = ""
    }
}

struct ICSFeedView_Previews: PreviewProvider {
    static var previews: some View {
        ICSFeedView()
            .environmentObject(SessionManager())
            .environmentObject(TaskViewModel())
            .preferredColorScheme(.dark) // Show only dark mode preview
    }
}
