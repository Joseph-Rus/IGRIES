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
    
    func cancelNotification(for task: TaskItem) {
        if let id = task.id {
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [id])
            
            // Remove from saved identifiers
            var savedIdentifiers = getSavedNotificationIdentifiers()
            savedIdentifiers.removeAll { $0 == id }
            saveNotificationIdentifiers(savedIdentifiers)
            
            print("Cancelled notification for task with ID: \(id)")
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
