import SwiftUI

struct AddEventView: View {
    @EnvironmentObject var sessionManager: SessionManager
    @EnvironmentObject var eventVM: EventViewModel
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var colorScheme
    
    @State private var name = ""
    @State private var description = ""
    @State private var startDate = Date()
    @State private var endDate = Date().addingTimeInterval(3600) // Default to 1 hour later
    @State private var repeatDays: Set<String> = []
    @State private var showValidationError = false
    @State private var isAllDay = false
    @State private var repeatOption = "Does not repeat"
    
    private let repeatOptions = ["Does not repeat", "Daily", "Weekly", "Monthly", "Annually"]
    @State private var showCustomRepeatOptions = false
    
    private let weekdays = [
        ("M", "Monday"),
        ("T", "Tuesday"),
        ("W", "Wednesday"),
        ("Th", "Thursday"),
        ("F", "Friday")
    ]
    
    // Background view - updated to match TodoListView gradient
    private var backgroundView: some View {
        LinearGradient(
            gradient: Gradient(colors: [
                Color.blue.opacity(0.7),
                Color.purple.opacity(0.7)
            ]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }
    
    // Event name field - styled to match TodoListView
    private var eventNameField: some View {
        inputSection(title: "Event Title") {
            TextField("Enter Event title", text: $name)
                .padding()
                .background(Color.white.opacity(0.2))
                .cornerRadius(10)
                .foregroundColor(.white)
                .shadow(color: .black.opacity(0.1), radius: 3, x: 0, y: 2)
        }
    }
    
    // Description field - styled to match TodoListView
    private var descriptionField: some View {
        inputSection(title: "Description") {
            TextField("Enter task description", text: $description)
                .padding()
                .background(Color.white.opacity(0.2))
                .cornerRadius(10)
                .foregroundColor(.white)
                .shadow(color: .black.opacity(0.1), radius: 3, x: 0, y: 2)
        }
    }
    
    // All day toggle - styled to match TodoListView
    private var allDayToggle: some View {
        inputSection(title: "Duration") {
            Toggle("All Day", isOn: $isAllDay)
                .padding()
                .background(Color.white.opacity(0.2))
                .cornerRadius(10)
                .foregroundColor(.white)
                .shadow(color: .black.opacity(0.1), radius: 3, x: 0, y: 2)
                .onChange(of: isAllDay) { newValue in
                    if newValue {
                        // Set start and end to beginning and end of day
                        let calendar = Calendar.current
                        startDate = calendar.startOfDay(for: startDate)
                        endDate = calendar.date(bySettingHour: 23, minute: 59, second: 59, of: startDate) ?? startDate
                    }
                }
        }
    }
    
    // Start date picker - styled to match TodoListView
    private var startDatePicker: some View {
        inputSection(title: "Starts") {
            DatePicker(
                isAllDay ? "Start date" : "Start date and time",
                selection: $startDate,
                displayedComponents: isAllDay ? [.date] : [.date, .hourAndMinute]
            )
            .padding()
            .background(Color.white.opacity(0.2))
            .cornerRadius(10)
            .foregroundColor(.white)
            .tint(.white)
            .shadow(color: .black.opacity(0.1), radius: 3, x: 0, y: 2)
            .onChange(of: startDate) { newValue in
                // Ensure end date is after start date
                if endDate < newValue {
                    endDate = newValue.addingTimeInterval(3600) // Add 1 hour
                }
            }
        }
    }
    
    // End date picker - styled to match TodoListView
    private var endDatePicker: some View {
        inputSection(title: "Ends") {
            DatePicker(
                isAllDay ? "End date" : "End date and time",
                selection: $endDate,
                in: startDate...,
                displayedComponents: isAllDay ? [.date] : [.date, .hourAndMinute]
            )
            .padding()
            .background(Color.white.opacity(0.2))
            .cornerRadius(10)
            .foregroundColor(.white)
            .tint(.white)
            .shadow(color: .black.opacity(0.1), radius: 3, x: 0, y: 2)
        }
    }
    
    // Repeat options - styled to match TodoListView
    private var repeatOptionsView: some View {
        inputSection(title: "Repeat") {
            Menu {
                ForEach(repeatOptions, id: \.self) { option in
                    Button(option) {
                        repeatOption = option
                        if option == "Weekly" {
                            showCustomRepeatOptions = true
                        } else {
                            showCustomRepeatOptions = false
                        }
                    }
                }
                
                Button("Custom...") {
                    showCustomRepeatOptions = true
                }
            } label: {
                HStack {
                    Text(repeatOption)
                        .foregroundColor(.white)
                    Spacer()
                    Image(systemName: "chevron.down")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                }
                .contentShape(Rectangle())
                .padding()
                .background(Color.white.opacity(0.2))
                .cornerRadius(10)
                .shadow(color: .black.opacity(0.1), radius: 3, x: 0, y: 2)
            }
            .buttonStyle(BorderlessButtonStyle())
            
            if showCustomRepeatOptions {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Repeat on:")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.7))
                        .padding(.top, 8)
                    
                    dayButtonsRow
                }
                .padding(.top, 8)
            }
        }
    }
    
    // Day buttons row - styled to match TodoListView
    private var dayButtonsRow: some View {
        HStack(spacing: 12) {
            ForEach(weekdays, id: \.0) { day in
                dayButton(for: day)
            }
        }
    }
    
    // Day button - styled to match TodoListView
    private func dayButton(for day: (String, String)) -> some View {
        Button(action: { toggleDay(day.0) }) {
            VStack(spacing: 4) {
                Text(day.0)
                    .fontWeight(.bold)
                    .font(.system(size: 16))
            }
            .frame(width: 40, height: 40)
            .background(
                repeatDays.contains(day.0)
                ? AnyView(
                    LinearGradient(
                        gradient: Gradient(colors: [.blue, .purple.opacity(0.8)]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                : AnyView(Color.white.opacity(0.2))
            )
            .foregroundColor(repeatDays.contains(day.0) ? .white : .white.opacity(0.7))
            .cornerRadius(20)
            .shadow(color: repeatDays.contains(day.0) ? .blue.opacity(0.3) : .clear, radius: 3, x: 0, y: 2)
        }
    }
    
    // Time zone button - styled to match TodoListView
    private var timeZoneButton: some View {
        Button(action: {
            // Time zone action
        }) {
            Text("Time zone")
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.9))
                .padding(.horizontal, 4)
        }
    }
    
    // Validation error message
    private var validationErrorMessage: some View {
        Group {
            if showValidationError {
                Text("Please enter a task title")
                    .foregroundColor(.red)
                    .font(.caption)
                    .padding(.horizontal, 4)
            }
        }
    }
    
    // Create task button - styled to match TodoListView gradient
    private var createTaskButton: some View {
        Button(action: addNewEvent) {
            Text("Create Task")
                .fontWeight(.semibold)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: [.blue, .purple]),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .cornerRadius(12)
                .shadow(color: .black.opacity(0.3), radius: 4, x: 0, y: 2)
        }
        .padding(.bottom, 30)
    }
    
    // Toolbar content
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .navigationBarLeading) {
            Button("Cancel") {
                dismiss()
            }
            .foregroundColor(.white)
        }
    }
    
    // Main form content
    private var formContent: some View {
        VStack(spacing: 20) {
            eventNameField
            descriptionField
            allDayToggle
            startDatePicker
            endDatePicker
            HStack {
                timeZoneButton
                Spacer()
            }
            repeatOptionsView
            validationErrorMessage
            Spacer(minLength: 20)
            createTaskButton
        }
        .padding(.top, 10)
        .padding(.horizontal, 16)
        .navigationTitle("New Task")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            toolbarContent
        }
    }
    
    // Input Section Wrapper - updated to match TodoListView style
    private func inputSection<Content: View>(
        title: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
                .foregroundColor(.white)
                .padding(.horizontal, 4)
            
            content()
        }
        .padding(.bottom, 4)
    }
    
    // Main body
    var body: some View {
        NavigationStack {
            ZStack {
                backgroundView
                ScrollView {
                    formContent
                }
            }
        }
        .preferredColorScheme(.dark)
    }
    
    // Day Toggle Function
    private func toggleDay(_ day: String) {
        if repeatDays.contains(day) {
            repeatDays.remove(day)
        } else {
            repeatDays.insert(day)
        }
    }
    
    // Add New Event Function
    func addNewEvent() {
        // Validate name
        guard !name.trimmingCharacters(in: .whitespaces).isEmpty else {
            showValidationError = true
            return
        }
        
        guard let userId = sessionManager.currentUserId else { return }
        
        // Ensure end date is after start date
        let finalEndDate = endDate < startDate ? startDate : endDate
        
        // Create repeat interval string based on selected option
        var repeatString = ""
        
        if repeatOption != "Does not repeat" {
            if repeatOption == "Daily" {
                repeatString = "daily"
            } else if repeatOption == "Monthly" {
                repeatString = "monthly"
            } else if repeatOption == "Annually" {
                repeatString = "yearly"
            } else if repeatOption == "Weekly" || showCustomRepeatOptions {
                // If custom days are selected, use those
                if !repeatDays.isEmpty {
                    repeatString = repeatDays.sorted().joined()
                } else {
                    // Default to current day of week if none selected
                    let calendar = Calendar.current
                    let weekday = calendar.component(.weekday, from: startDate)
                    let dayMap = [1: "Su", 2: "M", 3: "T", 4: "W", 5: "Th", 6: "F", 7: "Sa"]
                    repeatString = dayMap[weekday] ?? ""
                }
            }
        }
        
        let newEvent = EventItem(
            userId: userId,
            name: name,
            description: description,
            startDate: startDate,
            endDate: finalEndDate,
            repeatInterval: repeatString.isEmpty ? nil : repeatString,
            uid: nil
        )
        
        do {
            try eventVM.addEvent(newEvent)
            NotificationManager.shared.scheduleEventNotification(event: newEvent, remindBeforeMinutes: 30)
            dismiss()
        } catch {
            print("Error adding event: \(error.localizedDescription)")
            // Could add error handling UI here
        }
    }
}

struct AddEventView_Previews: PreviewProvider {
    static var previews: some View {
        AddEventView()
            .environmentObject(SessionManager())
            .environmentObject(EventViewModel())
            .preferredColorScheme(.dark)
    }
}
