import SwiftUI

struct AddEventView: View {
    @EnvironmentObject var sessionManager: SessionManager
    @EnvironmentObject var eventVM: EventViewModel
    @Environment(\.dismiss) var dismiss
    
    @State private var name = ""
    @State private var description = ""
    @State private var startDate = Date()
    @State private var endDate = Date() // New field for end date
    @State private var repeatDays: Set<String> = [] // New state for selected repeat days (M, T, W, Th, F)
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.knightGray
                    .ignoresSafeArea()
                
                VStack(spacing: 20) {
                    Text("New Event")
                        .font(.largeTitle)
                        .foregroundColor(.black)
                        .bold()
                    
                    TextField("Event Name", text: $name)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(8)
                        .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.black, lineWidth: 1))
                    
                    TextField("Description", text: $description)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(8)
                        .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.black, lineWidth: 1))
                    
                    DatePicker("Start Date", selection: $startDate, displayedComponents: [.date, .hourAndMinute])
                        .datePickerStyle(.compact)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(8)
                    
                    DatePicker("End Date", selection: $endDate, displayedComponents: [.date, .hourAndMinute])
                        .datePickerStyle(.compact)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(8)
                    
                    // Repeat Days Selection
                    VStack(spacing: 10) {
                        Text("Repeat on:")
                            .font(.headline)
                            .foregroundColor(.black)
                        
                        HStack(spacing: 10) {
                            Button(action: { toggleDay("M") }) {
                                Text("M")
                                    .padding(8)
                                    .background(repeatDays.contains("M") ? Color.babyblue : Color.white)
                                    .foregroundColor(.black)
                                    .cornerRadius(8)
                                    .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.black, lineWidth: 1))
                            }
                            Button(action: { toggleDay("T") }) {
                                Text("T")
                                    .padding(8)
                                    .background(repeatDays.contains("T") ? Color.babyblue : Color.white)
                                    .foregroundColor(.black)
                                    .cornerRadius(8)
                                    .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.black, lineWidth: 1))
                            }
                            Button(action: { toggleDay("W") }) {
                                Text("W")
                                    .padding(8)
                                    .background(repeatDays.contains("W") ? Color.babyblue : Color.white)
                                    .foregroundColor(.black)
                                    .cornerRadius(8)
                                    .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.black, lineWidth: 1))
                            }
                            Button(action: { toggleDay("Th") }) {
                                Text("Th")
                                    .padding(8)
                                    .background(repeatDays.contains("Th") ? Color.babyblue : Color.white)
                                    .foregroundColor(.black)
                                    .cornerRadius(8)
                                    .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.black, lineWidth: 1))
                            }
                            Button(action: { toggleDay("F") }) {
                                Text("F")
                                    .padding(8)
                                    .background(repeatDays.contains("F") ? Color.babyblue : Color.white)
                                    .foregroundColor(.black)
                                    .cornerRadius(8)
                                    .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.black, lineWidth: 1))
                            }
                        }
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(8)
                    .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.black, lineWidth: 1))
                    
                    Button(action: { addNewEvent() }) {
                        Text("Add Event")
                            .fontWeight(.semibold)
                            .foregroundColor(.black)
                            .padding()
                            .frame(maxWidth: 250)
                            .background(Color.babyblue)
                            .cornerRadius(10)
                            .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.black, lineWidth: 1))
                    }
                    
                    Button(action: { dismiss() }) {
                        Text("Cancel")
                            .fontWeight(.semibold)
                            .foregroundColor(.black)
                            .padding()
                            .frame(maxWidth: 250)
                            .background(Color.white)
                            .cornerRadius(10)
                            .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.black, lineWidth: 1))
                    }
                }
                .padding()
            }
        }
    }
    
    private func toggleDay(_ day: String) {
        if repeatDays.contains(day) {
            repeatDays.remove(day)
        } else {
            repeatDays.insert(day)
        }
    }
    
    func addNewEvent() {
        guard let userId = sessionManager.currentUserId else { return }
        let repeatString = repeatDays.sorted().joined() // e.g., "MTWThF"
        let newEvent = EventItem(
            userId: userId,
            name: name,
            description: description,
            startDate: startDate,
            repeatInterval: repeatString.isEmpty ? nil : repeatString, // Use nil if no days selected
            uid: nil
        )
        do {
            try eventVM.addEvent(newEvent)
            NotificationManager.shared.scheduleEventNotification(event: newEvent, remindBeforeMinutes: 30)
            dismiss()
        } catch {
            print("Error adding event:", error.localizedDescription)
        }
    }
}
