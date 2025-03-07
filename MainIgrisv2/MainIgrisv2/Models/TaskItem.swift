import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

enum TaskPriority: String, Codable, Equatable {
    case low = "low"
    case medium = "medium"
    case high = "high"
}

struct TaskItem: Identifiable, Codable, Equatable {
    @DocumentID var id: String?
    var userId: String
    var title: String
    var description: String
    var dueDate: Date
    var isComplete: Bool
    var course: String?
    var addedToTodoList: Bool
    var priority: TaskPriority
    
    init(id: String? = nil,
         userId: String,
         title: String,
         description: String,
         dueDate: Date,
         isComplete: Bool = false,
         course: String? = nil,
         addedToTodoList: Bool = false,
         priority: TaskPriority = .medium) {
        
        self.id = id
        self.userId = userId
        self.title = title
        self.description = description
        self.dueDate = dueDate
        self.isComplete = isComplete
        self.course = course
        self.addedToTodoList = addedToTodoList
        self.priority = priority
    }
    
    // For manual Firestore document conversion if needed
    init?(document: QueryDocumentSnapshot) {
        let data = document.data()
        
        guard
            let userId = data["userId"] as? String,
            let title = data["title"] as? String,
            let timestamp = data["dueDate"] as? Timestamp
        else {
            return nil
        }
        
        self.id = document.documentID
        self.userId = userId
        self.title = title
        self.description = data["description"] as? String ?? ""
        self.dueDate = timestamp.dateValue()
        self.isComplete = data["isComplete"] as? Bool ?? false
        self.course = data["course"] as? String
        self.addedToTodoList = data["addedToTodoList"] as? Bool ?? false
        
        if let priorityString = data["priority"] as? String,
           let priority = TaskPriority(rawValue: priorityString) {
            self.priority = priority
        } else {
            self.priority = .medium
        }
    }
    
    // Convert to Firestore data dictionary if needed
    func toFirestoreData() -> [String: Any] {
        var data: [String: Any] = [
            "userId": userId,
            "title": title,
            "description": description,
            "dueDate": Timestamp(date: dueDate),
            "isComplete": isComplete,
            "addedToTodoList": addedToTodoList,
            "priority": priority.rawValue
        ]
        
        if let course = course {
            data["course"] = course
        }
        
        return data
    }
    
    // MARK: - Equatable
    static func == (lhs: TaskItem, rhs: TaskItem) -> Bool {
        // Compare all relevant properties
        lhs.id == rhs.id &&
        lhs.userId == rhs.userId &&
        lhs.title == rhs.title &&
        lhs.description == rhs.description &&
        lhs.dueDate == rhs.dueDate &&
        lhs.isComplete == rhs.isComplete &&
        lhs.course == rhs.course &&
        lhs.addedToTodoList == rhs.addedToTodoList &&
        lhs.priority == rhs.priority
    }
}

// For notification identifier creation
extension TaskItem {
    var notificationIdentifier: String {
        return "task_\(id ?? UUID().uuidString)"
    }
    
    // Format display time
    func formattedTime() -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: dueDate)
    }
    
    // Format display date
    func formattedDate() -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: dueDate)
    }
    
    // Check if task is overdue
    var isOverdue: Bool {
        !isComplete && dueDate < Date()
    }
    
    // Check if task is due today
    var isDueToday: Bool {
        Calendar.current.isDateInToday(dueDate)
    }
}
