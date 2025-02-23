import SwiftUI

struct ICSFeedView: View {
    @EnvironmentObject var sessionManager: SessionManager
    @EnvironmentObject var taskVM: TaskViewModel
    @Environment(\.dismiss) var dismiss
    @State private var urlInput: String = ""
    @State private var isLoading: Bool = false
    @State private var errorMessage: String?
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.knightGray
                    .ignoresSafeArea()
                VStack(spacing: 20) {
                    Text("Add ICS Calendar")
                        .font(.largeTitle)
                        .foregroundColor(.black)
                        .bold()
                    
                    TextField("Enter ICS URL", text: $urlInput)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(8)
                        .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.black, lineWidth: 1))
                    
                    if isLoading { ProgressView("Loading...") }
                    if let error = errorMessage { Text(error).foregroundColor(.red) }
                    
                    Button(action: { saveICS() }) {
                        Text("Save ICS")
                            .fontWeight(.semibold)
                            .foregroundColor(.black)
                            .padding()
                            .frame(maxWidth: 250)
                            .background(Color.babyblue)
                            .cornerRadius(10)
                            .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.black, lineWidth: 1))
                    }
                    
                    if taskVM.icsLink != nil {
                        Button(action: { removeICS() }) {
                            Text("Remove ICS")
                                .fontWeight(.semibold)
                                .foregroundColor(.black)
                                .padding()
                                .frame(maxWidth: 250)
                                .background(Color.red.opacity(0.8))
                                .cornerRadius(10)
                                .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.black, lineWidth: 1))
                        }
                    }
                    
                    Button(action: { dismiss() }) {
                        Text("Cancel")
                            .fontWeight(.semibold)
                            .foregroundColor(.black)
                            .padding()
                            .frame(maxWidth: 250)
                            .background(Color.white)
                            .cornerRadius(10)
                            .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.black, lineWidth: 1))
                    }
                }
                .padding()
            }
            .onAppear { urlInput = taskVM.icsLink ?? "" }
        }
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
