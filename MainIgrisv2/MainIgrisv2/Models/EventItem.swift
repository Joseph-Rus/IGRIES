import Foundation
import FirebaseFirestoreSwift

// Event model
struct EventItem: Identifiable, Codable, Equatable {
    @DocumentID var id: String? = nil
    var userId: String
    var name: String
    var description: String
    var startDate: Date
    var endDate: Date?
    var repeatInterval: String?
    var uid: String?

    // Custom initializer matching your desired argument labels
    init(id: String? = nil,
         userId: String,
         name: String,
         description: String,
         startDate: Date,
         endDate: Date? = nil,
         repeatInterval: String? = nil,
         uid: String? = nil) {
        self.id = id
        self.userId = userId
        self.name = name
        self.description = description
        self.startDate = startDate
        self.endDate = endDate
        self.repeatInterval = repeatInterval
        self.uid = uid
    }
    
    // Equatable conformance
    static func == (lhs: EventItem, rhs: EventItem) -> Bool {
        return lhs.id == rhs.id &&
               lhs.userId == rhs.userId &&
               lhs.name == rhs.name &&
               lhs.description == rhs.description &&
               lhs.startDate == rhs.startDate &&
               lhs.endDate == rhs.endDate &&
               lhs.repeatInterval == rhs.repeatInterval &&
               lhs.uid == rhs.uid
    }
}
