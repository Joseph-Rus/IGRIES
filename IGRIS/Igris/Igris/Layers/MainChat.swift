import SwiftUI

struct MainChat: View {
    @EnvironmentObject var sessionManager: SessionManager
    @State private var messageText: String = ""

    var body: some View {
        ZStack {
            // Background color
            Color.white
                .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 0) {
                // MARK: - Top Bar
                HStack {
                    // Hamburger menu button (left)
                    Button(action: {
                        // Handle side menu action here (e.g., open a drawer menu)
                    }) {
                        Image(systemName: "line.horizontal.3")
                            .foregroundColor(.black)
                            .font(.title)
                    }
                    
                    Spacer()
                    
                    // Title in the center
                    Text("Chat")
                        .foregroundColor(.black)
                        .font(.headline)
                    
                    Spacer()
                    
                    // Drop-down menu on the right
                    Menu {
                        Button("Profile", action: {})
                        Button("Settings", action: {})
                        Button("Logout", action: logout)
                    } label: {
                        Image(systemName: "person.crop.circle.fill")
                            .foregroundColor(.black)
                            .font(.title)
                    }
                }
                .padding()
                .background(Color.white)
                
                // MARK: - Main Content Area
                VStack {
                    Spacer()
                    
                    // Chat bar at the bottom
                    HStack(spacing: 8) {
                        // TextField for message input
                        TextField("Type a message...", text: $messageText)
                            .padding(.horizontal)
                            .frame(height: 44)
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(8)
                        
                        // Send button with a paper plane icon
                        Button(action: sendMessage) {
                            Image(systemName: "paperplane.fill")
                                .foregroundColor(.white)
                                .frame(width: 44, height: 44)
                                .background(Color.blue)
                                .cornerRadius(22)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                }
            }
        }
    }
    
    // MARK: - Logout Function
    private func logout() {
        sessionManager.signOut()
    }
    
    // MARK: - Send Message Function (Placeholder)
    private func sendMessage() {
        guard !messageText.isEmpty else { return }
        print("Message sent: \(messageText)")
        messageText = ""
    }
}

struct MainChat_Previews: PreviewProvider {
    static var previews: some View {
        MainChat()
            .environmentObject(SessionManager())
    }
}
