import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

class TaskViewModel: ObservableObject {
    @Published var tasks: [TaskItem] = []
    @Published var todoListTasks: [TaskItem] = []
    @Published var icsLink: String?
    private var db = Firestore.firestore()
    private let parser = ICSParser()
    
    init() {
        // Initialize with any necessary setup, e.g., fetching initial data
    }
    
    func addTask(_ task: TaskItem) {
        do {
            let _ = try db.collection("tasks").addDocument(from: task) { error in
                if let error = error {
                    print("Error adding task: \(error.localizedDescription)")
                } else {
                    print("Task added successfully: \(task.title)")
                    self.fetchTasks(for: task.userId)
                }
            }
        } catch {
            print("Error encoding task: \(error.localizedDescription)")
        }
    }
    
    // Fixed fetchTasks with better error handling
    func fetchTasks(for userId: String) {
        print("Starting to fetch tasks for user: \(userId)")
        
        db.collection("tasks")
            .whereField("userId", isEqualTo: userId)
            .addSnapshotListener { [weak self] (snapshot, error) in
                guard let self = self else { return }
                
                if let error = error {
                    print("Error fetching tasks: \(error.localizedDescription)")
                    return
                }
                
                guard let documents = snapshot?.documents else {
                    print("No documents found")
                    return
                }
                
                print("Processing \(documents.count) documents")
                
                // Process documents safely with better error handling
                var loadedTasks: [TaskItem] = []
                
                for document in documents {
                    do {
                        // First try manually creating the task
                        if let task = TaskItem(document: document) {
                            loadedTasks.append(task)
                            print("Successfully created task manually: \(task.title)")
                        } else if let task = try? document.data(as: TaskItem.self) {
                            // Fallback to automatic decoding
                            loadedTasks.append(task)
                            print("Successfully decoded task: \(task.title)")
                        } else {
                            print("⚠️ Failed to create task from document: \(document.documentID)")
                            print("Document data: \(document.data())")
                        }
                    } catch {
                        print("❌ Error processing document \(document.documentID): \(error.localizedDescription)")
                    }
                }
                
                // Update on main thread
                DispatchQueue.main.async {
                    self.tasks = loadedTasks
                    self.todoListTasks = self.tasks.filter { $0.addedToTodoList }
                    print("Fetched \(self.tasks.count) tasks for user \(userId)")
                }
            }
    }
    
    func saveICSLink(_ link: String, for userId: String, completion: @escaping (Bool) -> Void = { _ in }) {
        print("Saving ICS link: \(link)")
        db.collection("users").document(userId).setData(["icsLink": link], merge: true) { [weak self] error in
            guard let self = self else {
                print("Self reference lost during ICS link save")
                completion(false)
                return
            }
            if let error = error {
                print("Error saving ICS link: \(error.localizedDescription)")
                completion(false)
            } else {
                print("Successfully saved ICS link")
                self.icsLink = link
                self.syncICS(userId: userId, completion: completion)
            }
        }
    }
    
    // Add method to remove ICS link
    func removeICSLink(for userId: String, completion: @escaping (Bool) -> Void = { _ in }) {
        print("Removing ICS link for user: \(userId)")
        
        // Use FieldValue.delete() to remove the field from the document
        db.collection("users").document(userId).updateData([
            "icsLink": FieldValue.delete()
        ]) { error in
            if let error = error {
                print("Error removing ICS link: \(error.localizedDescription)")
                completion(false)
            } else {
                print("Successfully removed ICS link")
                self.icsLink = nil
                completion(true)
            }
        }
    }
    
    func toggleTaskCompletion(_ task: TaskItem) {
        guard let taskId = task.id else {
            print("Task ID is nil")
            return
        }
        
        // Create an updated task with toggled completion status
        var updatedTask = task
        updatedTask.isComplete.toggle()
        
        // Update the task in Firestore
        do {
            try db.collection("tasks").document(taskId).setData(from: updatedTask) { error in
                if let error = error {
                    print("Error updating task: \(error.localizedDescription)")
                } else {
                    print("Task updated successfully: \(updatedTask.title)")
                    // Update the local tasks array
                    if let index = self.tasks.firstIndex(where: { $0.id == taskId }) {
                        self.tasks[index] = updatedTask
                    }
                    // Refresh the todoListTasks array
                    self.todoListTasks = self.tasks.filter { $0.addedToTodoList }
                }
            }
        } catch {
            print("Error encoding task: \(error.localizedDescription)")
        }
    }
    
    // Add task to todo list
    func addTaskToTodoList(_ task: TaskItem) {
        guard let taskId = task.id else {
            print("Task ID is nil")
            return
        }
        
        // Skip if already in todo list
        if task.addedToTodoList {
            print("Task is already in todo list: \(task.title)")
            return
        }
        
        // Create an updated task with addedToTodoList set to true
        var updatedTask = task
        updatedTask.addedToTodoList = true
        
        // Update the task in Firestore
        do {
            try db.collection("tasks").document(taskId).setData(from: updatedTask) { error in
                if let error = error {
                    print("Error adding task to todo list: \(error.localizedDescription)")
                } else {
                    print("Task added to todo list successfully: \(updatedTask.title)")
                    // Update the local tasks array
                    if let index = self.tasks.firstIndex(where: { $0.id == taskId }) {
                        self.tasks[index] = updatedTask
                    }
                    // Refresh the todoListTasks array
                    self.todoListTasks = self.tasks.filter { $0.addedToTodoList }
                }
            }
        } catch {
            print("Error encoding task: \(error.localizedDescription)")
        }
    }
    
    // Remove task from todo list
    func removeTaskFromTodoList(_ task: TaskItem) {
        guard let taskId = task.id else {
            print("Task ID is nil")
            return
        }
        
        // Create an updated task with addedToTodoList set to false
        var updatedTask = task
        updatedTask.addedToTodoList = false
        
        // Update the task in Firestore
        do {
            try db.collection("tasks").document(taskId).setData(from: updatedTask) { error in
                if let error = error {
                    print("Error removing task from todo list: \(error.localizedDescription)")
                } else {
                    print("Task removed from todo list successfully: \(updatedTask.title)")
                    // Update the local tasks array
                    if let index = self.tasks.firstIndex(where: { $0.id == taskId }) {
                        self.tasks[index] = updatedTask
                    }
                    // Refresh the todoListTasks array
                    self.todoListTasks = self.tasks.filter { $0.addedToTodoList }
                }
            }
        } catch {
            print("Error encoding task: \(error.localizedDescription)")
        }
    }
    
    // Delete a task completely
    func deleteTask(_ task: TaskItem) {
        guard let taskId = task.id else {
            print("Task ID is nil")
            return
        }
        
        db.collection("tasks").document(taskId).delete { error in
            if let error = error {
                print("Error deleting task: \(error.localizedDescription)")
            } else {
                print("Task deleted successfully: \(task.title)")
                // Remove from local arrays
                self.tasks.removeAll { $0.id == taskId }
                self.todoListTasks.removeAll { $0.id == taskId }
            }
        }
    }
    
    func syncICS(userId: String, completion: @escaping (Bool) -> Void = { _ in }) {
        guard let link = icsLink else {
            print("No ICS link available, cannot sync")
            completion(false)
            return
        }
        
        print("Starting ICS sync with link: \(link)")
        
        db.collection("tasks")
            .whereField("userId", isEqualTo: userId)
            .getDocuments { [weak self] (snapshot, error) in
                guard let self = self else {
                    completion(false)
                    return
                }
                if let error = error {
                    print("Error fetching tasks for deduplication: \(error.localizedDescription)")
                    completion(false)
                    return
                }
                
                // Safely fetch existing tasks
                var existingTasks: [TaskItem] = []
                if let documents = snapshot?.documents {
                    for document in documents {
                        if let task = TaskItem(document: document) {
                            existingTasks.append(task)
                        } else if let task = try? document.data(as: TaskItem.self) {
                            existingTasks.append(task)
                        }
                    }
                }
                
                print("Found \(existingTasks.count) existing tasks for deduplication")
                
                self.parser.fetchAndParseICS(from: link) { eventWrappers, error in
                    if let error = error {
                        print("ICS fetch error: \(error.localizedDescription)")
                        completion(false)
                        return
                    }
                    guard let eventWrappers = eventWrappers else {
                        print("No events parsed from ICS")
                        completion(false)
                        return
                    }
                    print("Parsed \(eventWrappers.count) events from ICS")
                    let existingTaskKeys = Set(existingTasks.map { "\($0.title)_\($0.dueDate.timeIntervalSince1970)" })
                    var tasksAdded = 0
                    
                    for wrapper in eventWrappers {
                        let task = wrapper.task
                        let taskKey = "\(task.title)_\(task.dueDate.timeIntervalSince1970)"
                        if !existingTaskKeys.contains(taskKey) && task.dueDate > Date() {
                            print("Adding new task from ICS: \(task.title) due \(task.dueDate)")
                            var newTask = task
                            newTask.userId = userId
                            self.addTask(newTask)
                            tasksAdded += 1
                        }
                    }
                    
//                    print("ICS sync completed, added \(tasksAdded) tasks")
//                    NotificationManager.shared.schedulePreviewNotification(
//                        title: "ICS Synced",
//                        body: "Tasks from your calendar have been imported."
//                    )
                    completion(true)
                }
            }
    }
    
    // Add method to fetch ICS link and sync
    func fetchICSLinkAndSync(userId: String) {
        print("Fetching ICS link for user: \(userId)")
        db.collection("users").document(userId).getDocument { [weak self] (document, error) in
            guard let self = self else { return }
            if let error = error {
                print("Error fetching ICS link: \(error.localizedDescription)")
                return
            }
            
            if let document = document, document.exists, let icsLink = document.data()?["icsLink"] as? String {
                print("Retrieved ICS link: \(icsLink)")
                self.icsLink = icsLink
                self.syncICS(userId: userId)
            } else {
                print("No ICS link found for user")
            }
        }
    }
    
    // Add method to clean up old tasks
    func manualCleanup(userId: String) {
        let threeDaysAgo = Calendar.current.date(byAdding: .day, value: -3, to: Date()) ?? Date()
        
        // Tasks to clean up:
        // 1. Completed tasks older than 3 days
        // 2. Overdue tasks older than 3 days
        let tasksToClean = tasks.filter { task in
            (task.isComplete && task.dueDate < threeDaysAgo) ||
            (!task.isComplete && task.dueDate < threeDaysAgo)
        }
        
        print("Found \(tasksToClean.count) tasks to clean up")
        
        for task in tasksToClean {
            deleteTask(task)
        }
    }
}
