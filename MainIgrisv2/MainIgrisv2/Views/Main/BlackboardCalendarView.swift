import SwiftUI

// Deprecated unless specific use case is clarified
struct BlackboardCalendarView: View {
    @State private var blackboardEvents: [EventItem] = []
    @State private var isLoading = false
    @Environment(\.colorScheme) var colorScheme
    
    let icsURL = "https://calbaptist.blackboard.com/webapps/calendar/calendarFeed/02190916b6604c7ba3be7648eddd9f4f/learn.ics"
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background gradient matching TodoListView
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color.blue.opacity(0.7),
                        Color.purple.opacity(0.7)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack {
                    if isLoading {
                        ProgressView("Loading Calendar...")
                            .padding()
                            .foregroundColor(.white)
                    } else if blackboardEvents.isEmpty {
                        emptyStateView
                    } else {
                        List {
                            ForEach(blackboardEvents) { event in
                                eventRowView(event)
                                    .listRowBackground(Color.clear)
                                    .listRowSeparator(.hidden)
                            }
                        }
                        .listStyle(PlainListStyle())
                    }
                    
                    Button("Fetch Blackboard Calendar") {
                        fetchBlackboardCalendar()
                    }
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .padding()
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: [.blue, .purple]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(12)
                    .shadow(color: .black.opacity(0.3), radius: 4, x: 0, y: 2)
                    .padding(.bottom, 20)
                }
                .navigationTitle("Blackboard Calendar")
            }
        }
        .preferredColorScheme(.dark)
    }
    
    // Empty State View styled like TodoListView
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "calendar")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 100, height: 100)
                .foregroundColor(.white.opacity(0.6))
            
            Text("No events found")
                .font(.headline)
                .foregroundColor(.white)
            
            Text("Tap the button below to fetch your Blackboard calendar")
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.8))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    // Event Row View styled like TodoListView
    private func eventRowView(_ event: EventItem) -> some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(event.name)
                .font(.headline)
                .foregroundColor(.white)
            
            Text("Starts: \(event.startDate.formatted(date: .abbreviated, time: .shortened))")
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.7))
            
            if !event.description.isEmpty {
                Text(event.description)
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.7))
                    .lineLimit(2)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.white.opacity(0.2))
                .shadow(color: .black.opacity(0.1), radius: 3, x: 0, y: 2)
        )
        .padding(.horizontal)
        .padding(.vertical, 5)
    }
    
    private func fetchBlackboardCalendar() {
        isLoading = true
        let parser = ICSParser()
        parser.fetchAndParseICS(from: icsURL) { events in
            self.blackboardEvents = events
            self.isLoading = false
        }
    }
}

struct BlackboardCalendarView_Previews: PreviewProvider {
    static var previews: some View {
        BlackboardCalendarView()
    }
}
