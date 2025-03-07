import SwiftUI
import FirebaseFirestoreSwift
import FirebaseFirestore

class EventViewModel: ObservableObject {
    @Published var events: [EventItem] = []
    @Published var todayEvents: [EventItem] = [] // Added for today's events
    private let db = Firestore.firestore()
    private var listenerRegistration: ListenerRegistration?
    
    func fetchEvents(for userId: String) {
        listenerRegistration?.remove()
        listenerRegistration = db.collection("events")
            .whereField("userId", isEqualTo: userId)
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self = self else { return }
                
                if let error = error {
                    print("Error fetching events: \(error.localizedDescription)")
                    return
                }
                
                guard let docs = snapshot?.documents else {
                    print("No events found")
                    return
                }
                
                self.events = docs.compactMap { try? $0.data(as: EventItem.self) }
                
                // Only schedule notifications for future events
                let futureEventsForNotification = self.events.filter { event in
                    self.shouldScheduleNotification(for: event)
                }
                
                NotificationManager.shared.scheduleAllEventNotifications(events: futureEventsForNotification)
                
                // Process today's events
                self.processTodayEvents()
            }
    }
    
    // Helper method to determine if a notification should be scheduled
    private func shouldScheduleNotification(for event: EventItem, remindBeforeMinutes: Int = 30) -> Bool {
        // Prevent scheduling notifications for very old events
        let minimumValidDate = Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date()
        let futureDate = Calendar.current.date(byAdding: .minute, value: -remindBeforeMinutes, to: event.startDate) ?? event.startDate
        
        return event.startDate > Date() && futureDate > minimumValidDate
    }
    
    // Process and deduplicate today's events
    func processTodayEvents() {
        let calendar = Calendar.current
        let now = Date()
        let startOfToday = calendar.startOfDay(for: now)
        let endOfDay = calendar.date(bySettingHour: 23, minute: 59, second: 59, of: now) ?? now
        
        // Get all events for today, including repeating ones
        let todaysEvents = eventsForDate(now)
        
        // Create a dictionary to deduplicate by name
        var uniqueEvents: [String: EventItem] = [:]
        
        // Process each event
        for event in todaysEvents.sorted(by: { $0.startDate < $1.startDate }) {
            // Only keep the first occurrence of an event with each name
            if uniqueEvents[event.name] == nil {
                uniqueEvents[event.name] = event
            }
        }
        
        // Convert to sorted array
        self.todayEvents = uniqueEvents.values.sorted { $0.startDate < $1.startDate }
    }
    
    // Get events for a specific date (from midnight to 11:59:59 PM)
    func eventsForDate(_ date: Date) -> [EventItem] {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        guard let endOfDay = calendar.date(bySettingHour: 23, minute: 59, second: 59, of: date) else {
            return []
        }
        
        var dateEvents: [EventItem] = []
        
        for event in events {
            // First, check if the event directly falls on that day
            if event.startDate >= startOfDay && event.startDate <= endOfDay {
                dateEvents.append(event)
                continue
            }
            
            // Then check if it's a repeating event
            guard let repeatInterval = event.repeatInterval, !repeatInterval.isEmpty else {
                continue
            }
            
            // Handle daily repeats
            if repeatInterval.lowercased() == "daily" {
                // For daily events, check if the original event date is before or on our target date
                if event.startDate <= endOfDay {
                    // Create a new instance of the event with the date adjusted to today
                    var repeatedEvent = event
                    
                    // Adjust the start time to be on the target date
                    let originalHour = calendar.component(.hour, from: event.startDate)
                    let originalMinute = calendar.component(.minute, from: event.startDate)
                    
                    if let adjustedDate = calendar.date(bySettingHour: originalHour, minute: originalMinute, second: 0, of: date) {
                        repeatedEvent.startDate = adjustedDate
                        
                        // Also adjust end date if it exists
                        if let originalEndDate = event.endDate {
                            let endHour = calendar.component(.hour, from: originalEndDate)
                            let endMinute = calendar.component(.minute, from: originalEndDate)
                            
                            if let adjustedEndDate = calendar.date(bySettingHour: endHour, minute: endMinute, second: 0, of: date) {
                                repeatedEvent.endDate = adjustedEndDate
                            }
                        }
                        
                        dateEvents.append(repeatedEvent)
                    }
                }
                continue
            }
            
            // Handle weekly repeats (M, T, W, Th, F)
            let weekdaySymbols = ["Su", "M", "T", "W", "Th", "F", "Sa"]
            let dayOfWeek = calendar.component(.weekday, from: date) // 1 = Sunday, 2 = Monday, etc.
            let daySymbol = weekdaySymbols[dayOfWeek - 1]
            
            if repeatInterval.contains(daySymbol) {
                // Create a new instance of the event with the date adjusted to today
                var repeatedEvent = event
                
                // Adjust the start time to be on the target date
                let originalHour = calendar.component(.hour, from: event.startDate)
                let originalMinute = calendar.component(.minute, from: event.startDate)
                
                if let adjustedDate = calendar.date(bySettingHour: originalHour, minute: originalMinute, second: 0, of: date) {
                    repeatedEvent.startDate = adjustedDate
                    
                    // Also adjust end date if it exists
                    if let originalEndDate = event.endDate {
                        let endHour = calendar.component(.hour, from: originalEndDate)
                        let endMinute = calendar.component(.minute, from: originalEndDate)
                        
                        if let adjustedEndDate = calendar.date(bySettingHour: endHour, minute: endMinute, second: 0, of: date) {
                            repeatedEvent.endDate = adjustedEndDate
                        }
                    }
                    
                    dateEvents.append(repeatedEvent)
                }
            }
        }
        
        return dateEvents
    }
    
    func addEvent(_ event: EventItem) throws {
        _ = try db.collection("events").addDocument(from: event)
        
        // Only schedule notification for future events
        if event.startDate > Date() {
            NotificationManager.shared.scheduleEventNotification(event: event, remindBeforeMinutes: 30)
        }
        
        // Update today's events
        processTodayEvents()
    }
    
    func updateEvent(_ event: EventItem) throws {
        guard let id = event.id else { return }
        
        try db.collection("events").document(id).setData(from: event)
        
        // Cancel old notification
        NotificationManager.shared.cancelNotification(for: event)
        
        // Schedule new notification if event is in the future
        if event.startDate > Date() {
            NotificationManager.shared.scheduleEventNotification(event: event, remindBeforeMinutes: 30)
        }
        
        // Update today's events
        processTodayEvents()
    }
    
    func deleteEvent(_ event: EventItem) {
        guard let id = event.id else { return }
        
        db.collection("events").document(id).delete { error in
            if let error = error {
                print("Error deleting event: \(error.localizedDescription)")
            }
        }
        
        // Cancel associated notification
        NotificationManager.shared.cancelNotification(for: event)
        
        // Update today's events
        processTodayEvents()
    }
}
