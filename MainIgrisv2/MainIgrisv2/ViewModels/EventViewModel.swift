import SwiftUI
import FirebaseFirestoreSwift
import FirebaseFirestore

class EventViewModel: ObservableObject {
    @Published var events: [EventItem] = []
    private let db = Firestore.firestore()
    private var listenerRegistration: ListenerRegistration?
    
    func fetchEvents(for userId: String) {
        listenerRegistration?.remove()
        listenerRegistration = db.collection("events")
            .whereField("userId", isEqualTo: userId)
            .addSnapshotListener { snapshot, error in
                if let error = error {
                    print("Error fetching events: \(error.localizedDescription)")
                    return
                }
                guard let docs = snapshot?.documents else { return }
                self.events = docs.compactMap { try? $0.data(as: EventItem.self) }
                NotificationManager.shared.scheduleAllEventNotifications(events: self.events, remindBeforeMinutes: 30)
            }
    }
    
    func addEvent(_ event: EventItem) throws {
        _ = try db.collection("events").addDocument(from: event)
        NotificationManager.shared.scheduleEventNotification(event: event, remindBeforeMinutes: 30)
    }
    
    func updateEvent(_ event: EventItem) throws {
        guard let id = event.id else { return }
        try db.collection("events").document(id).setData(from: event)
        NotificationManager.shared.cancelNotification(for: event) // Cancel old notification
        NotificationManager.shared.scheduleEventNotification(event: event, remindBeforeMinutes: 30) // Schedule new one
    }
    
    func deleteEvent(_ event: EventItem) {
        guard let id = event.id else { return }
        db.collection("events").document(id).delete()
        NotificationManager.shared.cancelNotification(for: event)
    }
}
