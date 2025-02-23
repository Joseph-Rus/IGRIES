import SwiftUI
import FirebaseAuth

struct MainChat: View {
    @EnvironmentObject var sessionManager: SessionManager
    @EnvironmentObject var taskVM: TaskViewModel
    @EnvironmentObject var eventVM: EventViewModel
    @State private var messageText: String = ""
    @State private var showingProfile = false
    @State private var showingTasks = false
    @State private var showingEvents = false
    
    var body: some View {
        ZStack {
            Color.white
                .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 0) {
                // Header with hamburger on left and profile icon on right
                HStack {
                    Menu {
                        Button("Tasks") { showingTasks = true }
                        Button("Events") { showingEvents = true }
                        Button("Settings", action: {})
                    } label: {
                        Image(systemName: "line.horizontal.3")
                            .foregroundColor(.black)
                            .font(.title)
                    }
                    
                    Spacer()
                    
                    Text("Chat")
                        .foregroundColor(.black)
                        .font(.headline)
                    
                    Spacer()
                    
                    Button(action: { showingProfile = true }) {
                        Image(systemName: "person.circle.fill")
                            .foregroundColor(.black)
                            .font(.title)
                    }
                }
                .padding()
                .background(Color.white)
                
                VStack {
                    Spacer()
                    HStack(spacing: 8) {
                        TextField("Type a message...", text: $messageText)
                            .padding(.horizontal)
                            .frame(height: 44)
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(8)
                        Button(action: {
                            print("Send message: \(messageText)")
                            messageText = ""
                        }) {
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
        .sheet(isPresented: $showingProfile) {
            ProfileView()
                .environmentObject(sessionManager)
        }
        .sheet(isPresented: $showingTasks) {
            TasksView()
                .environmentObject(sessionManager)
                .environmentObject(taskVM)
        }
        .sheet(isPresented: $showingEvents) {
            EventsView()
                .environmentObject(sessionManager)
                .environmentObject(eventVM)
        }
        .onAppear {
            print("MainChat appeared, userId: \(sessionManager.currentUserId ?? "nil"), tasks count: \(taskVM.tasks.count)")
            if let userId = sessionManager.currentUserId {
                eventVM.fetchEvents(for: userId)
            }
        }
    }
}

struct MainChat_Previews: PreviewProvider {
    static var previews: some View {
        MainChat()
            .environmentObject(SessionManager())
            .environmentObject(TaskViewModel())
            .environmentObject(EventViewModel())
    }
}
