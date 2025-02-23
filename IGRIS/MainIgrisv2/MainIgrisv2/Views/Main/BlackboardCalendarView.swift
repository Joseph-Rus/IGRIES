import SwiftUI

// Deprecated unless specific use case is clarified
struct BlackboardCalendarView: View {
    @State private var blackboardEvents: [EventItem] = []
    @State private var isLoading = false
    let icsURL = "https://calbaptist.blackboard.com/webapps/calendar/calendarFeed/02190916b6604c7ba3be7648eddd9f4f/learn.ics"
    
    var body: some View {
        NavigationView {
            VStack {
                if isLoading {
                    ProgressView("Loading Calendar...")
                        .padding()
                } else if blackboardEvents.isEmpty {
                    Text("No events found.")
                        .foregroundColor(.gray)
                        .padding()
                } else {
                    List(blackboardEvents) { event in
                        VStack(alignment: .leading) {
                            Text(event.name)
                                .font(.headline)
                            Text("Starts: \(event.startDate.formatted(date: .abbreviated, time: .shortened))")
                                .font(.subheadline)
                            if !event.description.isEmpty {
                                Text(event.description)
                                    .font(.caption)
                            }
                        }
                    }
                }
                Button("Fetch Blackboard Calendar") {
                    fetchBlackboardCalendar()
                }
                .padding()
            }
            .navigationTitle("Blackboard Calendar")
        }
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
