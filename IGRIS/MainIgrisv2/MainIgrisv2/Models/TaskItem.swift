import Foundation
import FirebaseFirestoreSwift

// Task model
struct TaskItem: Identifiable, Codable {
    @DocumentID var id: String?
    var userId: String      // Firebase UID of the user
    var title: String
    var description: String
    var dueDate: Date
    var isComplete: Bool = false
}
