import Foundation
import FirebaseFirestoreSwift

// Task model
struct TaskItem: Identifiable, Codable, Equatable {
    @DocumentID var id: String?
    var userId: String      // Firebase UID of the user
    var title: String
    var description: String
    var dueDate: Date
    var isComplete: Bool = false
    
    // Equatable conformance
    static func == (lhs: TaskItem, rhs: TaskItem) -> Bool {
        return lhs.id == rhs.id &&
               lhs.userId == rhs.userId &&
               lhs.title == rhs.title &&
               lhs.description == rhs.description &&
               lhs.dueDate == rhs.dueDate &&
               lhs.isComplete == rhs.isComplete
    }
}
