import SwiftUI

struct EventsView: View {
    @EnvironmentObject var sessionManager: SessionManager
    @EnvironmentObject var eventVM: EventViewModel
    @Environment(\.dismiss) var dismiss
    @State private var showAddEvent = false

    var body: some View {
        NavigationView {
            List {
                ForEach(eventVM.events) { event in
                    VStack(alignment: .leading, spacing: 8) {
                        Text(event.name)
                            .font(.headline)
                            .foregroundColor(.black)
                        Text(event.description)
                            .font(.subheadline)
                            .foregroundColor(.black.opacity(0.8))
                        Text("Starts: \(event.startDate.formatted(date: .abbreviated, time: .shortened))")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    .padding()
                    .background(cardColor(for: event.startDate))
                    .cornerRadius(15)
                    .shadow(color: .black.opacity(0.2), radius: 5, x: 0, y: 2)
                    .swipeActions(edge: .trailing) {
                        Button(role: .destructive) {
                            eventVM.deleteEvent(event)
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
                }
                .onDelete(perform: deleteItems)
            }
            .navigationTitle("Events")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack {
                        Button(action: { showAddEvent.toggle() }) {
                            Image(systemName: "plus")
                        }
                        Button(action: { dismiss() }) {
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
            .onAppear {
                NotificationManager.shared.requestPermission()
                NotificationManager.shared.scheduleAllEventNotifications(events: eventVM.events, remindBeforeMinutes: 30)
            }
            .onChange(of: eventVM.events) { _, newEvents in
                NotificationManager.shared.scheduleAllEventNotifications(events: newEvents, remindBeforeMinutes: 30)
            }
        }
    }
    
    private func cardColor(for startDate: Date) -> Color {
        let now = Date()
        let daysUntilStart = Calendar.current.dateComponents([.day], from: now, to: startDate).day ?? 0
        switch daysUntilStart {
        case ..<0: return Color(red: 1.0, green: 0.8, blue: 0.8)
        case 0..<2: return Color(red: 1.0, green: 0.9, blue: 0.8)
        default: return Color(red: 0.8, green: 1.0, blue: 0.8)
        }
    }
    
    func deleteItems(offsets: IndexSet) {
        offsets.map { eventVM.events[$0] }.forEach { event in
            eventVM.deleteEvent(event)
        }
    }
}
