import SwiftUI
import FirebaseAuth

struct ProfileView: View {
    @EnvironmentObject var sessionManager: SessionManager
    @Environment(\.dismiss) var dismiss
    @State private var showingLogoutAlert = false
    @State private var userEmail: String = ""
    @State private var userName: String = ""
    @State private var userJoinDate: String = "Unknown"
    @State private var openAIAPIKey: String = UserDefaults.standard.string(forKey: "OpenAIAPIKey") ?? ""
    @State private var showingAPIKeySavedAlert = false
    @State private var showingNameSavedAlert = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.knightGray
                    .ignoresSafeArea()
                
                VStack(spacing: 30) {
                    HStack {
                        Text("Profile")
                            .font(.largeTitle)
                            .foregroundColor(.black)
                            .bold()
                        Spacer()
                    }
                    .padding(.horizontal)
                    
                    Image("MainKnight")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 120, height: 120)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(Color.babyblue, lineWidth: 2))
                        .shadow(radius: 5)
                    
                    VStack(spacing: 20) {
                        VStack(alignment: .leading, spacing: 5) {
                            Text("Name")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                            TextField("Enter your name", text: $userName)
                                .textFieldStyle(.roundedBorder)
                                .submitLabel(.done)
                                .onSubmit {
                                    saveUserName()
                                }
                        }
                        infoField(title: "Email", value: userEmail)
                        infoField(title: "Joined", value: userJoinDate)
                        VStack(alignment: .leading, spacing: 5) {
                            Text("OpenAI API Key")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                            TextField("Enter your OpenAI API Key", text: $openAIAPIKey)
                                .textFieldStyle(.roundedBorder)
                                .submitLabel(.done)
                                .onSubmit {
                                    saveAPIKey()
                                }
                            Button("Save API Key") {
                                saveAPIKey()
                            }
                            .font(.body)
                            .foregroundColor(.black)
                            .padding(10)
                            .background(Color.babyblue)
                            .cornerRadius(8)
                        }
                    }
                    .padding()
                    .background(Color.white.opacity(0.9))
                    .cornerRadius(15)
                    .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
                    .frame(maxWidth: 300)
                    
                    Spacer()
                    
                    VStack(spacing: 15) {
                        Button(action: {
                            print("Logout button tapped, showing alert")
                            showingLogoutAlert = true
                        }) {
                            Text("Logout")
                                .fontWeight(.semibold)
                                .foregroundColor(.black)
                                .padding()
                                .frame(maxWidth: 250)
                                .background(Color.babyblue)
                                .cornerRadius(10)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color.black, lineWidth: 1)
                                )
                        }
                    }
                }
                .padding(.vertical, 40)
            }
            .alert("Logout", isPresented: $showingLogoutAlert, actions: {
                Button("Logout", role: .destructive) {
                    print("Attempting to sign out...")
                    sessionManager.signOut()
                    print("Sign out completed, isAuthenticated: \(sessionManager.isAuthenticated)")
                    resetToLogin()
                }
                Button("Cancel", role: .cancel) {
                    print("Logout cancelled")
                }
            }, message: {
                Text("Are you sure you want to logout?")
            })
            .alert("Success", isPresented: $showingAPIKeySavedAlert) {
                Button("OK", role: .cancel) {}
            } message: {
                Text("API Key saved successfully")
            }
            .alert("Success", isPresented: $showingNameSavedAlert) {
                Button("OK", role: .cancel) {}
            } message: {
                Text("Username saved successfully")
            }
            .onAppear {
                loadUserData()
            }
            .navigationBarBackButtonHidden(false)
        }
    }
    
    private func infoField(title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(title)
                .font(.subheadline)
                .foregroundColor(.gray)
            Text(value)
                .font(.body)
                .foregroundColor(.black)
                .padding(10)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.white)
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.black.opacity(0.3), lineWidth: 1)
                )
        }
    }
    
    private func loadUserData() {
        userEmail = sessionManager.currentUserEmail ?? "No email"
        userName = sessionManager.currentUserName ?? "User"
        if let user = Auth.auth().currentUser,
           let creationDate = user.metadata.creationDate {
            userJoinDate = DateFormatter.localizedString(from: creationDate, dateStyle: .medium, timeStyle: .none)
        }
    }
    
    private func saveAPIKey() {
        UserDefaults.standard.set(openAIAPIKey, forKey: "OpenAIAPIKey")
        showingAPIKeySavedAlert = true
    }
    
    private func saveUserName() {
        sessionManager.updateUserName(userName)
        showingNameSavedAlert = true
    }
    
    private func resetToLogin() {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {
            let authView = AuthContainerView()
                .environmentObject(sessionManager)
            window.rootViewController = UIHostingController(rootView: authView)
            window.makeKeyAndVisible()
            print("Root view reset to AuthContainerView")
        } else {
            print("Failed to reset root view: No window scene found")
        }
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
            .environmentObject(SessionManager())
    }
}
