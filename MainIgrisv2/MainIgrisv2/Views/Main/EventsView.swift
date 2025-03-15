import SwiftUI

struct EventsView: View {
    @EnvironmentObject var sessionManager: SessionManager
    @EnvironmentObject var eventVM: EventViewModel
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.presentationMode) var presentationMode
    
    @State private var showAddEvent = false
    @State private var selectedFilter: EventFilter = .upcoming
    @State private var selectedDate = Date()
    
    // Keep track of how the view was presented
    var isPresentedModally: Bool = true
    
    enum EventFilter {
        case upcoming, past, all
    }
    
    private var filteredEvents: [EventItem] {
        let now = Date()
        
        switch selectedFilter {
        case .upcoming:
            return eventVM.events.filter {
                if let repeatInterval = $0.repeatInterval, !repeatInterval.isEmpty {
                    // For repeating events, check if they're repeating after now
                    return true
                }
                return $0.startDate >= now
            }.sorted { $0.startDate < $1.startDate }
            
        case .past:
            return eventVM.events.filter {
                if let repeatInterval = $0.repeatInterval, !repeatInterval.isEmpty {
                    // For repeating events, use the original creation date
                    return $0.startDate < now && !repeatInterval.isEmpty
                }
                return $0.startDate < now
            }.sorted { $0.startDate > $1.startDate }
            
        case .all:
            return eventVM.events.sorted { $0.startDate < $1.startDate }
        }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Updated background to match TodoListView style
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color.blue.opacity(0.7),
                        Color.purple.opacity(0.7)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack(spacing: 15) {
                    // Filter Segment Control - styled to match TodoListView
                    Picker("Filter", selection: $selectedFilter) {
                        Text("Upcoming").tag(EventFilter.upcoming)
                        Text("Past").tag(EventFilter.past)
                        Text("All").tag(EventFilter.all)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding(.horizontal)
                    .padding(.top, 10)
                    
                    // Events List
                    if filteredEvents.isEmpty {
                        emptyStateView
                    } else {
                        List {
                            ForEach(filteredEvents) { event in
                                eventRowView(event)
                                    .listRowBackground(Color.clear)
                                    .listRowSeparator(.hidden)
                                    .swipeActions(edge: .trailing) {
                                        Button(role: .destructive) {
                                            eventVM.deleteEvent(event)
                                        } label: {
                                            Label("Delete", systemImage: "trash")
                                        }
                                    }
                            }
                        }
                        .listStyle(PlainListStyle())
                    }
                }
                .navigationTitle("Events")
                .toolbar {
                    // Only show the dismiss button if presented modally
                    if isPresentedModally {
                        ToolbarItem(placement: .navigationBarLeading) {
                            Button(action: { dismiss() }) {
                                Image(systemName: "xmark")
                                    .foregroundColor(.white.opacity(0.7))
                            }
                        }
                    }
                    
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: { showAddEvent.toggle() }) {
                            Image(systemName: "plus.circle.fill")
                                .foregroundColor(.white)
                        }
                    }
                }
                .sheet(isPresented: $showAddEvent) {
                    AddEventView()
                        .environmentObject(sessionManager)
                        .environmentObject(eventVM)
                }
            }
        }
        .preferredColorScheme(.dark)
        .navigationBarBackButtonHidden(isPresentedModally) // Hide the back button when presented modally
        .onAppear {
            NotificationManager.shared.requestPermission()
            NotificationManager.shared.scheduleAllEventNotifications(events: eventVM.events, remindBeforeMinutes: 30)
            
            // Refresh the events list when the view appears
            eventVM.processTodayEvents()
        }
        .onChange(of: eventVM.events) { _, newEvents in
            NotificationManager.shared.scheduleAllEventNotifications(events: newEvents, remindBeforeMinutes: 30)
        }
    }
    
    // Empty State View - styled to match TodoListView
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "calendar.badge.plus")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 100, height: 100)
                .foregroundColor(.white.opacity(0.6))
            
            Text("No events")
                .font(.headline)
                .foregroundColor(.white)
            
            Text("Tap the '+' button to add a new event")
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.8))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    // Event Row View - styled to match TodoListView
    private func eventRowView(_ event: EventItem) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 5) {
                Text(event.name)
                    .font(.headline)
                    .foregroundColor(.white)
                
                Text(event.description)
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.7))
                    .lineLimit(1)
                
                HStack {
                    Text(event.startDate, style: .date)
                        .font(.caption)
                    
                    Text(event.startDate, style: .time)
                        .font(.caption)
                }
                .foregroundColor(.white.opacity(0.7))
                
                // Repeat Interval Display with improved visibility
                if let repeatInterval = event.repeatInterval, !repeatInterval.isEmpty {
                    Text("Repeats: \(formatRepeatInterval(repeatInterval))")
                        .font(.caption)
                        .foregroundColor(.white)
                        .padding(.vertical, 2)
                        .padding(.horizontal, 6)
                        .background(Color.blue.opacity(0.3))
                        .cornerRadius(4)
                }
            }
            
            Spacer()
            
            // Date Indicator - styled to match TodoListView
            VStack {
                Text(event.startDate, format: .dateTime.day())
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Text(event.startDate, format: .dateTime.month(.abbreviated))
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.8))
            }
            .padding(8)
            .background(Color.white.opacity(0.2))
            .cornerRadius(8)
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
    
    // Helper method to format repeat interval with improved handling
    private func formatRepeatInterval(_ interval: String) -> String {
        // Check for daily repeats first
        if interval.lowercased() == "daily" {
            return "Daily"
        }
        
        // Handle weekly repeats with improved day mapping
        let dayMap = [
            "Su": "Sunday",
            "M": "Monday",
            "T": "Tuesday",
            "W": "Wednesday",
            "Th": "Thursday",
            "F": "Friday",
            "Sa": "Saturday"
        ]
        
        var formattedDays: [String] = []
        
        // Process two-character days first (Th)
        var processedString = interval
        for twoCharDay in ["Th", "Su", "Sa"] {
            if processedString.contains(twoCharDay) {
                formattedDays.append(dayMap[twoCharDay] ?? twoCharDay)
                processedString = processedString.replacingOccurrences(of: twoCharDay, with: "")
            }
        }
        
        // Then process single-character days
        for char in processedString {
            if let day = dayMap[String(char)] {
                formattedDays.append(day)
            }
        }
        
        if formattedDays.isEmpty {
            return interval // If nothing matched, just return the original
        }
        
        return formattedDays.joined(separator: ", ")
    }
    
    // Delete Items Function
    private func deleteItems(offsets: IndexSet) {
        offsets.map { filteredEvents[$0] }.forEach { event in
            eventVM.deleteEvent(event)
        }
    }
}

// Modifier to set presentation mode
extension EventsView {
    func presentedModally(_ isModal: Bool) -> EventsView {
        var view = self
        view.isPresentedModally = isModal
        return view
    }
}

struct EventsView_Previews: PreviewProvider {
    static var previews: some View {
        EventsView()
            .environmentObject(SessionManager())
            .environmentObject(EventViewModel())
            .preferredColorScheme(.dark)
    }
}
