import SwiftUI
import UserNotifications
import FirebaseAuth

class NotificationManager: ObservableObject {
    static let shared = NotificationManager()
    private init() {}
    
    func requestPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("Notification permission error: \(error.localizedDescription)")
                } else {
                    print("Notification permission granted: \(granted)")
                }
            }
        }
    }
    
    // Updated to include remindBeforeMinutes parameter
    func scheduleTaskNotification(task: TaskItem, remindBeforeMinutes: Int = 30) {
        guard !task.isComplete else { return }
        
        let remindDate = Calendar.current.date(byAdding: .minute, value: -remindBeforeMinutes, to: task.dueDate) ?? task.dueDate
        guard remindDate > Date() else { return } // Don’t schedule if already past
        
        let content = UNMutableNotificationContent()
        content.title = "Task Reminder: \(task.title)"
        content.body = task.description.isEmpty ? "Due in \(remindBeforeMinutes) minutes!" : "\(task.description) is due in \(remindBeforeMinutes) minutes!"
        content.sound = .default
        content.userInfo = ["taskId": task.id ?? ""]
        
        let triggerDate = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: remindDate)
        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)
        
        let request = UNNotificationRequest(
            identifier: task.id ?? UUID().uuidString,
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling notification for task \(task.title): \(error.localizedDescription)")
            } else {
                print("Scheduled notification for task: \(task.title) at \(remindDate)")
            }
        }
    }
    
    func scheduleEventNotification(event: EventItem, remindBeforeMinutes: Int = 30) {
        let remindDate = Calendar.current.date(byAdding: .minute, value: -remindBeforeMinutes, to: event.startDate) ?? event.startDate
        guard remindDate > Date() else { return }
        
        let content = UNMutableNotificationContent()
        content.title = "Event Reminder: \(event.name)"
        content.body = event.description.isEmpty ? "Starts in \(remindBeforeMinutes) minutes!" : "\(event.description) starts in \(remindBeforeMinutes) minutes!"
        content.sound = .default
        content.userInfo = ["eventId": event.id ?? ""]
        
        let triggerDate = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: remindDate)
        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)
        
        let request = UNNotificationRequest(
            identifier: event.id ?? UUID().uuidString,
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling notification for event \(event.name): \(error.localizedDescription)")
            } else {
                print("Scheduled notification for event: \(event.name) at \(remindDate)")
            }
        }
    }
    
    func cancelNotification(for item: any Identifiable) {
        if let id = (item as? TaskItem)?.id ?? (item as? EventItem)?.id {
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [id])
            print("Cancelled notification for item with ID: \(id)")
        }
    }
    
    func scheduleAllTaskNotifications(tasks: [TaskItem], remindBeforeMinutes: Int = 30) {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        for task in tasks.filter({ !$0.isComplete && $0.dueDate > Date() }) {
            scheduleTaskNotification(task: task, remindBeforeMinutes: remindBeforeMinutes)
        }
    }
    
    func scheduleAllEventNotifications(events: [EventItem], remindBeforeMinutes: Int = 30) {
        for event in events.filter({ $0.startDate > Date() }) {
            scheduleEventNotification(event: event, remindBeforeMinutes: remindBeforeMinutes)
        }
    }
    
    func schedulePreviewNotification(title: String, body: String, delay: TimeInterval = 5.0) {
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
}
