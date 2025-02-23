import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

class TaskViewModel: ObservableObject {
    @Published var tasks: [TaskItem] = []
    @Published var icsLink: String?
    private var db = Firestore.firestore()
    
    func fetchTasks(for userId: String) {
        db.collection("tasks")
            .whereField("userId", isEqualTo: userId)
            .addSnapshotListener { snapshot, error in
                if let error = error {
                    print("Error fetching tasks: \(error)")
                    return
                }
                self.tasks = snapshot?.documents.compactMap { try? $0.data(as: TaskItem.self) } ?? []
                NotificationManager.shared.scheduleAllTaskNotifications(tasks: self.tasks)
            }
    }
    
    func addTask(_ task: TaskItem) {
        do {
            _ = try db.collection("tasks").addDocument(from: task)
            NotificationManager.shared.scheduleTaskNotification(task: task)
        } catch {
            print("Error adding task: \(error)")
        }
    }
    
    func deleteTask(_ task: TaskItem) {
        if let taskId = task.id {
            db.collection("tasks").document(taskId).delete { error in
                if let error = error { print("Error deleting task: \(error)") }
            }
            NotificationManager.shared.cancelNotification(for: task)
        }
    }
    
    func markTaskComplete(_ task: TaskItem) {
        if let taskId = task.id {
            db.collection("tasks").document(taskId).updateData(["isComplete": true]) { error in
                if let error = error { print("Error marking task complete: \(error)") }
            }
            NotificationManager.shared.cancelNotification(for: task)
        }
    }
    
    func saveICSLink(_ link: String, for userId: String) {
        db.collection("users").document(userId).setData(["icsLink": link], merge: true) { error in
            if let error = error { print("Error saving ICS link: \(error)") }
            else {
                self.icsLink = link
                self.syncICS(userId: userId)
                NotificationManager.shared.schedulePreviewNotification(
                    title: "ICS Synced",
                    body: "Tasks from your calendar have been imported."
                )
            }
        }
    }
    
    func fetchICSLinkAndSync(userId: String) {
        db.collection("users").document(userId).getDocument { document, error in
            if let document = document, document.exists {
                self.icsLink = document.data()?["icsLink"] as? String
                if self.icsLink != nil { self.syncICS(userId: userId) }
            }
        }
    }
    
    func syncICS(userId: String) {
        guard let link = icsLink else { return }
        let parser = ICSParser()
        
        // Fetch existing tasks first
        db.collection("tasks")
            .whereField("userId", isEqualTo: userId)
            .getDocuments { [weak self] (snapshot, error) in
                guard let self = self else { return }
                if let error = error {
                    print("Error fetching tasks for deduplication: \(error)")
                    return
                }
                let existingTasks = snapshot?.documents.compactMap { try? $0.data(as: TaskItem.self) } ?? []
                
                // Parse ICS events
                parser.fetchAndParseICS(from: link) { events in
                    let existingTaskKeys = Set(existingTasks.map { "\($0.title)_\($0.dueDate.timeIntervalSince1970)" })
                    
                    for event in events.filter({ $0.startDate > Date() }) {
                        // Create a unique key for deduplication
                        let taskKey = "\(event.name)_\(event.startDate.timeIntervalSince1970)"
                        
                        // Only add if it doesn't exist
                        if !existingTaskKeys.contains(taskKey) {
                            let task = TaskItem(
                                id: nil,
                                userId: userId,
                                title: event.name,
                                description: event.description,
                                dueDate: event.startDate,
                                isComplete: false
                            )
                            self.addTask(task)
                        }
                    }
                }
            }
    }
    
    func removeICSLink(for userId: String) {
        db.collection("users").document(userId).updateData(["icsLink": FieldValue.delete()]) { error in
            if let error = error { print("Error removing ICS link: \(error)") }
            else { self.icsLink = nil }
        }
    }
}
