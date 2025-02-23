import SwiftUI

struct EventsView: View {
    @EnvironmentObject var sessionManager: SessionManager
    @EnvironmentObject var eventVM: EventViewModel
    @State private var showAddEvent = false
    @Environment(\.dismiss) var dismiss // Added to handle sheet dismissal

    var body: some View {
        NavigationView {
            List {
                ForEach(eventVM.events) { event in
                    VStack(alignment: .leading) {
                        Text(event.name)
                            .font(.headline)
                        Text(event.description)
                            .font(.subheadline)
                        Text("Starts: \(event.startDate.formatted(date: .abbreviated, time: .shortened))")
                            .font(.caption)
                    }
                }
                .onDelete(perform: deleteItems)
            }
            .navigationTitle("Events")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) { // Group buttons in toolbar
                    HStack {
                        Button(action: { showAddEvent.toggle() }) {
                            Image(systemName: "plus")
                        }
                        Button(action: { dismiss() }) { // Exit button
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.black)
                                .font(.title2)
                        }
                    }
                }
            }
            .sheet(isPresented: $showAddEvent) {
                AddEventView()
            }
        }
    }
    
    func deleteItems(offsets: IndexSet) {
        offsets.map { eventVM.events[$0] }.forEach { event in
            eventVM.deleteEvent(event)
        }
    }
}
