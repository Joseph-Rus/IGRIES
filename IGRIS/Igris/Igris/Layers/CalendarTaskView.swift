import SwiftUI
import GoogleSignIn
import GoogleSignInSwift

struct ContentView: View {
    
    @StateObject private var calendarManager = GoogleCalendarManager.shared
    @State private var showingAddTask = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(UIColor.systemBackground)
                    .edgesIgnoringSafeArea(.all)
                
                VStack(alignment: .leading) {
                    Text("TASKS")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .padding([.leading, .top], 16)
                    
                    if calendarManager.isSignedIn {
                        List(calendarManager.calendarEvents, id: \.identifier) { event in
                            TaskRow(event: event)
                        }
                        .listStyle(PlainListStyle())
                    } else {
                        Spacer()
                        Text("Please sign in to view your tasks.")
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding()
                        Spacer()
                    }
                }
                .navigationBarTitleDisplayMode(.inline)
                .navigationBarItems(
                    trailing: HStack {
                        if !calendarManager.isSignedIn {
                            Button(action: {
                                if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                                    calendarManager.signIn(presentingWindow: scene)
                                }
                            }) {
                                Text("Sign In")
                            }
                        } else {
                            PulseButton {
                                showingAddTask = true
                            }
                        }
                    }
                )
                .sheet(isPresented: $showingAddTask) {
                    AddTaskView()
                }
            }
        }
    }
}

// MARK: - TaskRow

struct TaskRow: View {
    let event: GTLRCalendar_Event
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(event.summary ?? "Untitled Task")
                .font(.headline)
                .foregroundColor(.primary)
            
            if let desc = event.descriptionProperty, !desc.isEmpty {
                Text(desc)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(UIColor.systemGray5))
        .cornerRadius(8)
        .padding(.vertical, 4)
    }
}

// MARK: - PulseButton

struct PulseButton: View {
    let action: () -> Void
    @State private var animate = false
    
    var body: some View {
        Button(action: action) {
            Image(systemName: "plus.circle.fill")
                .resizable()
                .frame(width: 30, height: 30)
                .foregroundColor(.blue)
                .scaleEffect(animate ? 1.2 : 1.0)
                .animation(
                    Animation.easeInOut(duration: 1.0)
                        .repeatForever(autoreverses: true),
                    value: animate
                )
        }
        .onAppear {
            animate = true
        }
    }
}
