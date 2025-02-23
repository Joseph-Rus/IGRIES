import SwiftUI
import FirebaseAuth

struct ProfileView: View {
    @EnvironmentObject var sessionManager: SessionManager
    @Environment(\.dismiss) var dismiss
    @State private var showingLogoutAlert = false
    @State private var userEmail: String = Auth.auth().currentUser?.email ?? "No email"
    @State private var userName: String = "User"
    @State private var userJoinDate: String = "Unknown"
    
    var body: some View {
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
                    
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.black)
                            .font(.title2)
                    }
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
                    infoField(title: "Name", value: userName)
                    infoField(title: "Email", value: userEmail)
                    infoField(title: "Joined", value: userJoinDate)
                }
                .padding()
                .background(Color.white.opacity(0.9))
                .cornerRadius(15)
                .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
                .frame(maxWidth: 300)
                
                Spacer()
                
                VStack(spacing: 15) {
                    Button(action: {
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
                    
                    Button(action: {
                        dismiss()
                    }) {
                        Text("Back to Chat")
                            .fontWeight(.semibold)
                            .foregroundColor(.black)
                            .padding()
                            .frame(maxWidth: 250)
                            .background(Color.white)
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
        .alert(isPresented: $showingLogoutAlert) {
            Alert(
                title: Text("Logout"),
                message: Text("Are you sure you want to logout?"),
                primaryButton: .destructive(Text("Logout")) {
                    sessionManager.signOut()
                    dismiss()
                },
                secondaryButton: .cancel()
            )
        }
        .onAppear {
            loadUserData()
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
        if let user = Auth.auth().currentUser {
            userEmail = user.email ?? "No email"
            userName = user.displayName ?? "User"
            if let creationDate = user.metadata.creationDate {
                userJoinDate = DateFormatter.localizedString(from: creationDate, dateStyle: .medium, timeStyle: .none)
            }
        }
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
            .environmentObject(SessionManager())
    }
}
