import SwiftUI

struct AddTaskView: View {
    @EnvironmentObject var sessionManager: SessionManager
    @EnvironmentObject var taskVM: TaskViewModel
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var colorScheme
    
    @State private var title = ""
    @State private var description = ""
    @State private var course = "" // New course state
    @State private var dueDate = Date()
    @State private var showValidationError = false
    
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
    
    // Title field - styled to match TodoListView
    private var titleField: some View {
        inputSection(title: "Task Title") {
            TextField("Enter task title", text: $title)
                .padding()
                .background(Color.white.opacity(0.2))
                .foregroundColor(.white)
                .cornerRadius(10)
                .shadow(color: .black.opacity(0.1), radius: 3, x: 0, y: 2)
        }
    }
    
    // Course field - new field for course info
    private var courseField: some View {
        inputSection(title: "Course") {
            TextField("Enter course name (optional)", text: $course)
                .padding()
                .background(Color.white.opacity(0.2))
                .foregroundColor(.white)
                .cornerRadius(10)
                .shadow(color: .black.opacity(0.1), radius: 3, x: 0, y: 2)
        }
    }
    
    // Description field - styled to match TodoListView
    private var descriptionField: some View {
        inputSection(title: "Description") {
            TextField("Enter task description", text: $description)
                .padding()
                .background(Color.white.opacity(0.2))
                .foregroundColor(.white)
                .cornerRadius(10)
                .shadow(color: .black.opacity(0.1), radius: 3, x: 0, y: 2)
        }
    }
    
    // Due date picker - styled to match TodoListView
    private var dueDatePicker: some View {
        inputSection(title: "Due Date") {
            DatePicker(
                "Select due date",
                selection: $dueDate,
                displayedComponents: [.date, .hourAndMinute]
            )
            .padding()
            .background(Color.white.opacity(0.2))
            .foregroundColor(.white)
            .tint(.white)
            .cornerRadius(10)
            .shadow(color: .black.opacity(0.1), radius: 3, x: 0, y: 2)
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
    
    // Create task button - styled to match TodoListView
    private var createTaskButton: some View {
        Button(action: addNewTask) {
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
    
    // Toolbar content - updated text color to white
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
            titleField
            courseField // Added course field
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
    }
    
    // Input Section Wrapper - updated text colors to white
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
    
    // Main body - added preferredColorScheme(.dark)
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
            course: course.isEmpty ? nil : course // Include course information
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
