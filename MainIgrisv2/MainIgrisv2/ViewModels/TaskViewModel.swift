import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

class TaskViewModel: ObservableObject {
    @Published var tasks: [TaskItem] = []
    @Published var todoListTasks: [TaskItem] = []
    @Published var icsLink: String?
    private var db = Firestore.firestore()
    
    func fetchTasks(for userId: String) {
        db.collection("tasks")
            .whereField("userId", isEqualTo: userId)
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self = self else { return }
                
                if let error = error {
                    print("Error fetching tasks: \(error)")
                    return
                }
                
                guard let documents = snapshot?.documents else {
                    print("No tasks found")
                    return
                }
                
                self.tasks = documents.compactMap { try? $0.data(as: TaskItem.self) }
                
                // Only schedule notifications for future, incomplete tasks
                let futureTasksForNotification = self.tasks.filter { task in
                    !task.isComplete &&
                    task.dueDate > Date() &&
                    self.shouldScheduleNotification(for: task)
                }
                
                NotificationManager.shared.scheduleAllTaskNotifications(tasks: futureTasksForNotification)
                
                // Update todo list tasks
                self.updateTodoListTasks()
            }
    }
    
    // Update todo list tasks based on the main tasks array
    private func updateTodoListTasks() {
        // Get all tasks that have been added to the todo list
        todoListTasks = tasks.filter { $0.addedToTodoList }
    }
    
    func addTask(_ task: TaskItem) {
        do {
            _ = try db.collection("tasks").addDocument(from: task)
            
            // Only schedule notification for future tasks
            if !task.isComplete && task.dueDate > Date() {
                NotificationManager.shared.scheduleTaskNotification(task: task, remindBeforeMinutes: 30)
            }
        } catch {
            print("Error adding task: \(error)")
        }
    }
    
    func deleteTask(_ task: TaskItem) {
        if let taskId = task.id {
            db.collection("tasks").document(taskId).delete { error in
                if let error = error {
                    print("Error deleting task: \(error)")
                }
            }
            NotificationManager.shared.cancelNotification(for: task)
        }
    }
    
    func toggleTaskCompletion(_ task: TaskItem) {
        guard let taskId = task.id else { return }
        
        // Create a mutable copy of the task and toggle completion
        var updatedTask = task
        updatedTask.isComplete.toggle()
        
        // Update in Firestore
        db.collection("tasks").document(taskId).updateData([
            "isComplete": updatedTask.isComplete
        ]) { [weak self] error in
            guard let self = self else { return }
            
            if let error = error {
                print("Error toggling task completion: \(error)")
                return
            }
            
            // Update local tasks array
            if let index = self.tasks.firstIndex(where: { $0.id == taskId }) {
                self.tasks[index] = updatedTask
            }
            
            // Also update in todoListTasks if present
            if let index = self.todoListTasks.firstIndex(where: { $0.id == taskId }) {
                self.todoListTasks[index] = updatedTask
            }
            
            // Manage notifications
            if updatedTask.isComplete {
                NotificationManager.shared.cancelNotification(for: task)
            } else {
                // Only schedule for future, incomplete tasks
                if updatedTask.dueDate > Date() {
                    NotificationManager.shared.scheduleTaskNotification(task: updatedTask, remindBeforeMinutes: 30)
                }
            }
        }
    }
    
    func markTaskComplete(_ task: TaskItem) {
        if let taskId = task.id {
            db.collection("tasks").document(taskId).updateData(["isComplete": true]) { error in
                if let error = error {
                    print("Error marking task complete: \(error)")
                }
            }
            NotificationManager.shared.cancelNotification(for: task)
        }
    }
    
    // Add task to todo list
    func addTaskToTodoList(_ task: TaskItem) {
        guard let taskId = task.id else { return }
        
        // Create a mutable copy of the task and mark as added to todo list
        var updatedTask = task
        updatedTask.addedToTodoList = true
        
        // Update in Firestore
        db.collection("tasks").document(taskId).updateData([
            "addedToTodoList": true
        ]) { [weak self] error in
            guard let self = self else { return }
            
            if let error = error {
                print("Error adding task to todo list: \(error)")
                return
            }
            
            // Update local tasks array
            if let index = self.tasks.firstIndex(where: { $0.id == taskId }) {
                self.tasks[index] = updatedTask
            }
            
            // Update todoListTasks array
            self.updateTodoListTasks()
            
            // Show notification to user
            NotificationManager.shared.schedulePreviewNotification(
                title: "Task Added to Todo List",
                body: "\(task.title) has been added to your todo list."
            )
        }
    }
    
    // Remove task from todo list
    func removeTaskFromTodoList(_ task: TaskItem) {
        guard let taskId = task.id else { return }
        
        // Create a mutable copy of the task and mark as not added to todo list
        var updatedTask = task
        updatedTask.addedToTodoList = false
        
        // Update in Firestore
        db.collection("tasks").document(taskId).updateData([
            "addedToTodoList": false
        ]) { [weak self] error in
            guard let self = self else { return }
            
            if let error = error {
                print("Error removing task from todo list: \(error)")
                return
            }
            
            // Update local tasks array
            if let index = self.tasks.firstIndex(where: { $0.id == taskId }) {
                self.tasks[index] = updatedTask
            }
            
            // Update todoListTasks array
            self.updateTodoListTasks()
        }
    }
    
    // Helper method to determine if a notification should be scheduled
    private func shouldScheduleNotification(for task: TaskItem, remindBeforeMinutes: Int = 30) -> Bool {
        // Prevent scheduling notifications for very old tasks
        let minimumValidDate = Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date()
        let futureDate = Calendar.current.date(byAdding: .minute, value: -remindBeforeMinutes, to: task.dueDate) ?? task.dueDate
        
        return !task.isComplete &&
               task.dueDate > Date() &&
               futureDate > minimumValidDate
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
            if let error = error {
                print("Error fetching ICS link: \(error)")
                return
            }
            if let document = document, document.exists {
                self.icsLink = document.data()?["icsLink"] as? String
                if self.icsLink != nil { self.syncICS(userId: userId) }
            }
        }
    }
    
    func syncICS(userId: String) {
        guard let link = icsLink else { return }
        let parser = ICSParser()
        
        db.collection("tasks")
            .whereField("userId", isEqualTo: userId)
            .getDocuments { [weak self] (snapshot, error) in
                guard let self = self else { return }
                if let error = error {
                    print("Error fetching tasks for deduplication: \(error)")
                    return
                }
                let existingTasks = snapshot?.documents.compactMap { try? $0.data(as: TaskItem.self) } ?? []
                
                parser.fetchAndParseICS(from: link) { events in
                    let existingTaskKeys = Set(existingTasks.map { "\($0.title)_\($0.dueDate.timeIntervalSince1970)" })
                    
                    for event in events.filter({ $0.startDate > Date() }) {
                        let taskKey = "\(event.name)_\(event.startDate.timeIntervalSince1970)"
                        
                        if !existingTaskKeys.contains(taskKey) {
                            // Try to extract course information from event
                            var courseName: String? = nil
                            
                            // Check if event description contains course information
                            if !event.description.isEmpty {
                                // Look for common course identifiers in description
                                if let courseMatch = event.description.range(of: "Course: ([^\\n]+)", options: .regularExpression) {
                                    courseName = String(event.description[courseMatch])
                                        .replacingOccurrences(of: "Course: ", with: "")
                                }
                            }
                            
                            // If no course in description, try to extract from event name
                            if courseName == nil {
                                // Common patterns: "MATH101: Assignment" or "[MATH101] Assignment"
                                if let courseMatch = event.name.range(of: "([A-Z]+\\d+)[ :-]", options: .regularExpression) {
                                    courseName = String(event.name[courseMatch])
                                        .trimmingCharacters(in: CharacterSet(charactersIn: " :-"))
                                }
                            }
                            
                            let task = TaskItem(
                                id: nil,
                                userId: userId,
                                title: event.name,
                                description: event.description,
                                dueDate: event.startDate,
                                isComplete: false,
                                course: courseName
                            )
                            self.addTask(task) // This will also schedule the notification
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
