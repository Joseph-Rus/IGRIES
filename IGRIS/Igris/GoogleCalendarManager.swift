import SwiftUI

class GoogleCalendarManagerSwift: ObservableObject {
    @Published var isSignedIn = false
    @Published var calendarEvents: [GTLRCalendar_Event] = []

    private let manager = GoogleCalendarManager.shared()

    func signIn() {
        manager.signInWithCompletion { success, error in
            DispatchQueue.main.async {
                self.isSignedIn = success
                if success { self.fetchEvents() }
            }
        }
    }

    func signOut() {
        manager.signOut()
        DispatchQueue.main.async {
            self.isSignedIn = false
            self.calendarEvents = []
        }
    }

    func fetchEvents() {
        manager.fetchEventsWithCompletion { events, error in
            DispatchQueue.main.async {
                self.calendarEvents = events ?? []
            }
        }
    }

    func addEvent(summary: String, description: String?, startDate: Date, endDate: Date) {
        manager.addEventWithSummary(summary, description: description, startDate: startDate, endDate: endDate) { success, error in
            if success {
                self.fetchEvents()
            }
        }
    }
}
#Preview {
    GoogleCalendarManagerSwift()
}