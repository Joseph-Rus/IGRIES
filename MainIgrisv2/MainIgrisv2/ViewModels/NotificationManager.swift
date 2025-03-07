import SwiftUI
import UserNotifications
import FirebaseAuth

class NotificationManager: NSObject, ObservableObject {
    static let shared = NotificationManager()
    
    private override init() {
        super.init()
        // Ensure notification center delegate is set
        UNUserNotificationCenter.current().delegate = self
    }
    
    // Persistent storage for notification identifiers
    private let defaults = UserDefaults.standard
    private let notificationIdentifiersKey = "savedNotificationIdentifiers"
    
    // Save notification identifiers
    private func saveNotificationIdentifiers(_ identifiers: [String]) {
        defaults.set(identifiers, forKey: notificationIdentifiersKey)
    }
    
    // Retrieve saved notification identifiers
    private func getSavedNotificationIdentifiers() -> [String] {
        return defaults.stringArray(forKey: notificationIdentifiersKey) ?? []
    }
    
    func requestPermission(completion: ((Bool) -> Void)? = nil) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("Notification permission error: \(error.localizedDescription)")
                    completion?(false)
                } else {
                    print("Notification permission granted: \(granted)")
                    completion?(granted)
                }
            }
        }
    }
    
    func scheduleTaskNotification(task: TaskItem, remindBeforeMinutes: Int = 30) {
        // Ensure we have a valid, future date
        guard task.dueDate > Date() else { return }
        
        // Calculate reminder date
        guard let remindDate = Calendar.current.date(byAdding: .minute, value: -remindBeforeMinutes, to: task.dueDate),
              remindDate > Date() else { return }
        
        // Prepare notification content
        let content = UNMutableNotificationContent()
        content.title = "Task Reminder: \(task.title)"
        content.body = task.description.isEmpty
            ? "Due in \(remindBeforeMinutes) minutes!"
            : "\(task.description) is due in \(remindBeforeMinutes) minutes!"
        content.sound = .default
        
        // Add task ID to userInfo for potential follow-up actions
        content.userInfo = ["taskId": task.id ?? "", "type": "task"]
        
        // Create trigger
        let triggerDate = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: remindDate)
        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)
        
        // Create and add notification request
        let identifier = task.id ?? UUID().uuidString
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        
        // Add request and save identifier
        UNUserNotificationCenter.current().add(request) { [weak self] error in
            if let error = error {
                print("Error scheduling notification for task \(task.title): \(error.localizedDescription)")
            } else {
                print("Scheduled notification for task: \(task.title) at \(remindDate)")
                
                // Save the identifier
                var savedIdentifiers = self?.getSavedNotificationIdentifiers() ?? []
                savedIdentifiers.append(identifier)
                self?.saveNotificationIdentifiers(savedIdentifiers)
            }
        }
    }
    
    func scheduleEventNotification(event: EventItem, remindBeforeMinutes: Int = 30) {
        // Ensure we have a valid, future date
        guard event.startDate > Date() else { return }
        
        // Calculate reminder date
        guard let remindDate = Calendar.current.date(byAdding: .minute, value: -remindBeforeMinutes, to: event.startDate),
              remindDate > Date() else { return }
        
        // Prepare notification content
        let content = UNMutableNotificationContent()
        content.title = "Event Reminder: \(event.name)"
        content.body = event.description.isEmpty
            ? "Starts in \(remindBeforeMinutes) minutes!"
            : "\(event.description) starts in \(remindBeforeMinutes) minutes!"
        content.sound = .default
        
        // Add event ID to userInfo for potential follow-up actions
        content.userInfo = ["eventId": event.id ?? "", "type": "event"]
        
        // Create trigger
        let triggerDate = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: remindDate)
        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)
        
        // Create a unique identifier for this event instance
        // For repeating events, include the date in the identifier to make it unique
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMdd"
        let dateStr = dateFormatter.string(from: event.startDate)
        let identifier = "\(event.id ?? UUID().uuidString)-\(dateStr)"
        
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        
        // Add request and save identifier
        UNUserNotificationCenter.current().add(request) { [weak self] error in
            if let error = error {
                print("Error scheduling notification for event \(event.name): \(error.localizedDescription)")
            } else {
                print("Scheduled notification for event: \(event.name) at \(remindDate)")
                
                // Save the identifier
                var savedIdentifiers = self?.getSavedNotificationIdentifiers() ?? []
                savedIdentifiers.append(identifier)
                self?.saveNotificationIdentifiers(savedIdentifiers)
            }
        }
    }
    
    func scheduleAllTaskNotifications(tasks: [TaskItem], remindBeforeMinutes: Int = 30) {
        requestPermission { [weak self] granted in
            guard granted else {
                print("❌ Notification permission not granted")
                return
            }
            
            // First, cancel all previous notifications
            UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
            
            // Clear saved identifiers
            self?.saveNotificationIdentifiers([])
            
            // Schedule notifications for future tasks
            let futureTasksToNotify = tasks.filter { task in
                guard let remindDate = Calendar.current.date(byAdding: .minute, value: -remindBeforeMinutes, to: task.dueDate) else {
                    return false
                }
                return task.dueDate > Date() && !task.isComplete && remindDate > Date()
            }
            
            for task in futureTasksToNotify {
                self?.scheduleTaskNotification(task: task, remindBeforeMinutes: remindBeforeMinutes)
            }
            
            // Print pending notifications for debugging
            self?.printPendingNotifications()
        }
    }
    
    func scheduleAllEventNotifications(events: [EventItem], remindBeforeMinutes: Int = 30) {
        requestPermission { [weak self] granted in
            guard let self = self, granted else {
                print("❌ Notification permission not granted")
                return
            }
            
            // Remove previous event notifications
            let savedIdentifiers = getSavedNotificationIdentifiers()
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: savedIdentifiers)
            
            // Clear saved identifiers
            saveNotificationIdentifiers([])
            
            // Current date and calendar
            let calendar = Calendar.current
            let now = Date()
            
            // For each event, check if it needs notifications
            for event in events {
                // Handle one-time events
                if event.repeatInterval == nil || event.repeatInterval?.isEmpty == true {
                    // Only schedule if in the future
                    if event.startDate > now {
                        scheduleEventNotification(event: event, remindBeforeMinutes: remindBeforeMinutes)
                    }
                    continue
                }
                
                // Handle repeating events
                let repeatInterval = event.repeatInterval!
                
                // Schedule notifications for the next 7 days for repeating events
                for dayOffset in 0...7 {
                    // Get the date for this offset
                    guard let futureDate = calendar.date(byAdding: .day, value: dayOffset, to: now) else { continue }
                    
                    // Check if event repeats on this date
                    let shouldSchedule = shouldEventRepeatOn(event: event, date: futureDate)
                    
                    if shouldSchedule {
                        // Create a virtual event instance for this date
                        var virtualEvent = event
                        
                        // Adjust times to the future date
                        let startHour = calendar.component(.hour, from: event.startDate)
                        let startMinute = calendar.component(.minute, from: event.startDate)
                        
                        if let adjustedDate = calendar.date(bySettingHour: startHour, minute: startMinute, second: 0, of: futureDate) {
                            // Only if this date is in the future
                            if adjustedDate > now {
                                virtualEvent.startDate = adjustedDate
                                scheduleEventNotification(event: virtualEvent, remindBeforeMinutes: remindBeforeMinutes)
                            }
                        }
                    }
                }
            }
            
            // Print scheduled notifications for debugging
            printPendingNotifications()
        }
    }
    
    // Helper method to determine if an event repeats on a specific date
    private func shouldEventRepeatOn(event: EventItem, date: Date) -> Bool {
        guard let repeatInterval = event.repeatInterval, !repeatInterval.isEmpty else {
            return false
        }
        
        let calendar = Calendar.current
        
        // Daily repeats - event repeats every day
        if repeatInterval.lowercased() == "daily" {
            return event.startDate <= date
        }
        
        // Weekly repeats (M, T, W, Th, F, Sa, Su)
        let weekdaySymbols = ["Su", "M", "T", "W", "Th", "F", "Sa"]
        let dayOfWeek = calendar.component(.weekday, from: date) // 1 = Sunday, 2 = Monday, etc.
        let daySymbol = weekdaySymbols[dayOfWeek - 1]
        
        // Check if this weekday is in the repeat interval
        return repeatInterval.contains(daySymbol)
    }
    
    func cancelNotification(for item: any Identifiable) {
        // For events with repeat patterns, we need to cancel all related notifications
        if let event = item as? EventItem, let id = event.id {
            // Get all notification IDs
            let allIds = getSavedNotificationIdentifiers()
            
            // Filter for all notifications related to this event
            let eventIds = allIds.filter { $0.starts(with: "\(id)-") }
            
            // Cancel all of them
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: eventIds)
            
            // Remove from saved identifiers
            var savedIdentifiers = getSavedNotificationIdentifiers()
            savedIdentifiers.removeAll { eventIds.contains($0) }
            saveNotificationIdentifiers(savedIdentifiers)
            
            print("Cancelled \(eventIds.count) notifications for event with ID: \(id)")
        }
        // For tasks or single events
        else if let id = (item as? TaskItem)?.id ?? (item as? EventItem)?.id {
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [id])
            
            // Remove from saved identifiers
            var savedIdentifiers = getSavedNotificationIdentifiers()
            savedIdentifiers.removeAll { $0 == id }
            saveNotificationIdentifiers(savedIdentifiers)
            
            print("Cancelled notification for item with ID: \(id)")
        }
    }
    
    func schedulePreviewNotification(title: String, body: String, delay: TimeInterval = 5.0) {
        // Schedule a test/preview notification
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: delay, repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling preview notification: \(error.localizedDescription)")
            }
        }
    }
    
    // Method to check and print pending notifications for debugging
    func printPendingNotifications() {
        UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
            print("Pending Notifications Count: \(requests.count)")
            for request in requests {
                print("Notification ID: \(request.identifier)")
                print("Title: \(request.content.title)")
                print("Body: \(request.content.body)")
                if let trigger = request.trigger as? UNCalendarNotificationTrigger {
                    print("Trigger Date: \(trigger.nextTriggerDate() ?? Date())")
                }
                print("---")
            }
        }
    }
}

extension NotificationManager: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        // Show notification even when the app is in the foreground
        completionHandler([.banner, .sound])
    }
}
