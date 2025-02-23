import SwiftUI
import UserNotifications
import FirebaseAuth

class NotificationManager: ObservableObject {
    static let shared = NotificationManager()
    private init() {}
    
    // Request permission for notifications
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
    
    // Schedule a notification for a task
    func scheduleTaskNotification(task: TaskItem) {
        guard !task.isComplete else { return }
        
        let content = UNMutableNotificationContent()
        content.title = "Task Due: \(task.title)"
        content.body = task.description.isEmpty ? "Due now!" : "\(task.description) is due now!"
        content.sound = .default
        content.userInfo = ["taskId": task.id ?? ""]
        
        let triggerDate = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: task.dueDate)
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
                print("Scheduled notification for task: \(task.title) at \(task.dueDate)")
            }
        }
    }
    
    // Schedule a notification for an event
    func scheduleEventNotification(event: EventItem, remindBeforeMinutes: Int = 30) {
        let remindDate = Calendar.current.date(byAdding: .minute, value: -remindBeforeMinutes, to: event.startDate) ?? event.startDate
        guard remindDate > Date() else { return }  // Don’t schedule if already past
        
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
    
    // Cancel a notification for a specific task or event
    func cancelNotification(for item: any Identifiable) {
        if let id = (item as? TaskItem)?.id ?? (item as? EventItem)?.id {
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [id])
            print("Cancelled notification for item with ID: \(id)")
        }
    }
    
    // Schedule notifications for all tasks
    func scheduleAllTaskNotifications(tasks: [TaskItem]) {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        for task in tasks.filter({ !$0.isComplete && $0.dueDate > Date() }) {
            scheduleTaskNotification(task: task)
        }
    }
    
    // Schedule a preview notification
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
