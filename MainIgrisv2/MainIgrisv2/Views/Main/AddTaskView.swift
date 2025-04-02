import SwiftUI

struct AddTaskView: View {
    @EnvironmentObject var sessionManager: SessionManager
    @EnvironmentObject var taskVM: TaskViewModel
    @Environment(\.dismiss) var dismiss
    
    // Theme reference
    private let theme = ThemeManager.shared
    
    @State private var title = ""
    @State private var description = ""
    @State private var course = ""
    @State private var dueDate = Date()
    @State private var showValidationError = false
    
    // Background view - using ThemeManager gradient
    private var backgroundView: some View {
        ZStack {
            theme.backgroundGradient
                .ignoresSafeArea()
            
            // Add subtle pattern overlay for more depth
            Color.white
                .opacity(0.03)
                .ignoresSafeArea()
        }
    }
    
    // Title field - updated with ThemeManager styling
    private var titleField: some View {
        inputSection(title: "Task Title") {
            TextField("Enter task title", text: $title)
                .padding()
                .background(theme.cardBackgroundAlt)
                .foregroundColor(theme.textPrimary)
                .cornerRadius(theme.cornerRadiusMedium)
                .overlay(
                    RoundedRectangle(cornerRadius: theme.cornerRadiusMedium)
                        .stroke(theme.accentColor.opacity(0.3), lineWidth: 1)
                )
                .modifier(theme.standardShadow())
        }
    }
    
    // Course field - updated with ThemeManager styling
    private var courseField: some View {
        inputSection(title: "Course") {
            TextField("Enter course name (optional)", text: $course)
                .padding()
                .background(theme.cardBackgroundAlt)
                .foregroundColor(theme.textPrimary)
                .cornerRadius(theme.cornerRadiusMedium)
                .overlay(
                    RoundedRectangle(cornerRadius: theme.cornerRadiusMedium)
                        .stroke(theme.secondaryAccent.opacity(0.3), lineWidth: 1)
                )
                .modifier(theme.standardShadow())
        }
    }
    
    // Description field - updated with ThemeManager styling
    private var descriptionField: some View {
        inputSection(title: "Description") {
            TextField("Enter task description", text: $description)
                .padding()
                .background(theme.cardBackgroundAlt)
                .foregroundColor(theme.textPrimary)
                .cornerRadius(theme.cornerRadiusMedium)
                .overlay(
                    RoundedRectangle(cornerRadius: theme.cornerRadiusMedium)
                        .stroke(theme.secondaryAccent.opacity(0.3), lineWidth: 1)
                )
                .modifier(theme.standardShadow())
        }
    }
    
    // Due date picker - updated with ThemeManager styling
    private var dueDatePicker: some View {
        inputSection(title: "Due Date") {
            DatePicker(
                "Select due date",
                selection: $dueDate,
                displayedComponents: [.date, .hourAndMinute]
            )
            .padding()
            .background(theme.cardBackgroundAlt)
            .foregroundColor(theme.textPrimary)
            .tint(theme.accentColor)
            .cornerRadius(theme.cornerRadiusMedium)
            .overlay(
                RoundedRectangle(cornerRadius: theme.cornerRadiusMedium)
                    .stroke(theme.accentColor.opacity(0.3), lineWidth: 1)
            )
            .modifier(theme.standardShadow(radius: 8))
        }
    }
    
    // Validation error message - updated with ThemeManager styling
    private var validationErrorMessage: some View {
        Group {
            if showValidationError {
                Text("Please enter a task title")
                    .foregroundColor(theme.errorColor)
                    .font(theme.captionFont())
                    .padding(.horizontal, 4)
            }
        }
    }
    
    // Create task button - updated with ThemeManager styling
    private var createTaskButton: some View {
        Button(action: addNewTask) {
            Text("Create Task")
                .font(theme.bodyFont(size: 18))
                .fontWeight(.semibold)
                .foregroundColor(theme.textPrimary)
                .frame(maxWidth: .infinity)
                .padding()
                .background(theme.taskButtonGradient)
                .cornerRadius(theme.cornerRadiusLarge)
                .modifier(theme.buttonShadow())
                .overlay(
                    RoundedRectangle(cornerRadius: theme.cornerRadiusLarge)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
        }
        .padding(.top, 20)
        .padding(.bottom, 30)
    }
    
    // Toolbar content - updated with ThemeManager styling
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .navigationBarLeading) {
            Button("Cancel") {
                dismiss()
            }
            .foregroundColor(theme.textPrimary)
        }
    }
    
    // Main form content
    private var formContent: some View {
        VStack(spacing: 20) {
            titleField
            courseField
            descriptionField
            dueDatePicker
            validationErrorMessage
            Spacer(minLength: 20)
            createTaskButton
        }
        .padding(.top, 10)
        .navigationTitle("New Task")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            toolbarContent
        }
        .toolbarColorScheme(.dark, for: .navigationBar)
    }
    
    // Input Section Wrapper - updated with ThemeManager styling
    private func inputSection<Content: View>(
        title: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(theme.titleFont(size: 16))
                .foregroundColor(theme.textPrimary)
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
                        .padding(.horizontal, 16)
                }
            }
        }
        .preferredColorScheme(.dark)
    }
    
    func addNewTask() {
        // Validate title
        guard !title.trimmingCharacters(in: .whitespaces).isEmpty else {
            showValidationError = true
            return
        }
        
        guard let userId = sessionManager.currentUserId else { return }
        
        let newTask = TaskItem(
            id: nil,
            userId: userId,
            title: title,
            description: description,
            dueDate: dueDate,
            isComplete: false,
            course: course.isEmpty ? nil : course
        )
        
        taskVM.addTask(newTask)
        dismiss()
    }
}

struct AddTaskView_Previews: PreviewProvider {
    static var previews: some View {
        AddTaskView()
            .environmentObject(SessionManager())
            .environmentObject(TaskViewModel())
            .preferredColorScheme(.dark)
    }
}
