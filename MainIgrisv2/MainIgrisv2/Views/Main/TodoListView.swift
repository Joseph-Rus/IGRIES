import SwiftUI
import FirebaseAuth

struct TodoListView: View {
    @EnvironmentObject var sessionManager: SessionManager
    @EnvironmentObject var taskVM: TaskViewModel
    @Environment(\.colorScheme) var colorScheme
    
    private let theme = ThemeManager.shared
    
    // Simple state variables to control sorting and filtering
    @State private var selectedSortIndex = 0 // 0: dueDate, 1: priority, 2: title
    @State private var showCompleted: Bool = true
    
    var body: some View {
        NavigationStack {
            ZStack {
                theme.backgroundGradient
                    .ignoresSafeArea()
                
                VStack {
                    if sortAndFilterTasks().isEmpty {
                        emptyStateView
                    } else {
                        taskListView
                    }
                }
                .navigationTitle("Todo List")
                .toolbar {
                    ToolbarItem(placement: .principal) {
                        Text("Todo List")
                            .font(theme.titleFont())
                            .foregroundColor(theme.textPrimary)
                    }
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Menu {
                            // Sort options
                            Picker("Sort By", selection: $selectedSortIndex) {
                                Text("Due Date").tag(0)
                                Text("Priority").tag(1)
                                Text("Title").tag(2)
                            }
                            // Show/hide completed tasks
                            Toggle("Show Completed", isOn: $showCompleted)
                        } label: {
                            Image(systemName: "ellipsis.circle")
                        }
                    }
                }
            }
        }
        .preferredColorScheme(.dark)
        .onAppear {
            if let userId = sessionManager.currentUserId {
                taskVM.fetchTasks(for: userId)
            }
        }
    }
    
    // Extract the task list view for better readability
    private var taskListView: some View {
        List {
            ForEach(sortAndFilterTasks()) { task in
                TodoTaskRowView(task: task, theme: theme, taskVM: taskVM)
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
                    .swipeActions(edge: .trailing) {
                        Button(role: .destructive) {
                            taskVM.removeTaskFromTodoList(task)
                        } label: {
                            Label("Remove", systemImage: "trash")
                        }
                    }
                    .swipeActions(edge: .leading) {
                        Button {
                            print("Edit task: \(task.title)")
                        } label: {
                            Label("Edit", systemImage: "pencil")
                        }
                        .tint(.blue)
                    }
            }
        }
        .listStyle(PlainListStyle())
        .scrollContentBackground(.hidden)
    }
    
    // Simplify the sorting and filtering logic into a single function
    private func sortAndFilterTasks() -> [TaskItem] {
        // Step 1: Filter tasks based on completion status
        let filteredTasks = showCompleted ?
            taskVM.todoListTasks :
            taskVM.todoListTasks.filter { !$0.isComplete }
        
        // Step 2: Sort the filtered tasks based on selected option
        switch selectedSortIndex {
        case 0: // Due Date
            return filteredTasks.sorted { $0.dueDate < $1.dueDate }
        case 1: // Priority
            return filteredTasks.sorted { $0.priority.rawValue > $1.priority.rawValue }
        case 2: // Title
            return filteredTasks.sorted { $0.title < $1.title }
        default:
            return filteredTasks
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 24) {
            Image(systemName: "checkmark.circle.fill")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 90, height: 90)
                .foregroundColor(theme.secondaryAccent.opacity(0.5))
                .modifier(theme.standardShadow(radius: 10, x: 0, y: 5))
            
            Text("Your todo list is empty")
                .font(theme.titleFont(size: 20))
                .foregroundColor(theme.textPrimary)
            
            Text("Swipe right on tasks to add them here")
                .font(theme.bodyFont())
                .foregroundColor(theme.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// Separate struct for task row view
struct TodoTaskRowView: View {
    let task: TaskItem
    let theme: ThemeManager
    let taskVM: TaskViewModel
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(task.title)
                        .font(theme.bodyFont())
                        .foregroundColor(task.isComplete ? theme.textSecondary : theme.textPrimary)
                        .strikethrough(task.isComplete)
                    
                    if let course = task.course, !course.isEmpty {
                        Text("• \(course)")
                            .font(theme.captionFont())
                            .foregroundColor(theme.secondaryAccent.opacity(0.9))
                    }
                }
                
                if !task.description.isEmpty {
                    Text(task.description)
                        .font(theme.captionFont())
                        .foregroundColor(theme.textSecondary)
                        .lineLimit(1)
                }
                
                HStack(spacing: 12) {
                    HStack(spacing: 4) {
                        Image(systemName: "calendar")
                            .font(.system(size: 12))
                            .foregroundColor(isDueDateClose(task.dueDate) ? theme.errorColor : theme.textSecondary)
                        Text(task.dueDate, style: .date)
                            .font(theme.captionFont(size: 12))
                            .foregroundColor(isDueDateClose(task.dueDate) ? theme.errorColor : theme.textSecondary)
                    }
                    HStack(spacing: 4) {
                        Image(systemName: "clock")
                            .font(.system(size: 12))
                            .foregroundColor(isDueDateClose(task.dueDate) ? theme.errorColor : theme.textSecondary)
                        Text(task.dueDate, style: .time)
                            .font(theme.captionFont(size: 12))
                            .foregroundColor(isDueDateClose(task.dueDate) ? theme.errorColor : theme.textSecondary)
                    }
                }
                .padding(.top, 2)
            }
            Spacer()
            Button(action: {
                taskVM.toggleTaskCompletion(task)
            }) {
                ZStack {
                    Circle()
                        .stroke(task.isComplete ? theme.accentColor : theme.textSecondary.opacity(0.5), lineWidth: 1.5)
                        .frame(width: 24, height: 24)
                    if task.isComplete {
                        Circle()
                            .fill(theme.accentColor)
                            .frame(width: 16, height: 16)
                        Image(systemName: "checkmark")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(.white)
                    }
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: theme.cornerRadiusMedium)
                .fill(theme.cardBackgroundAlt)
                .modifier(theme.standardShadow())
        )
        .padding(.horizontal)
        .padding(.vertical, 4)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(task.title), \(task.isComplete ? "completed" : "not completed"), due \(task.dueDate, style: .date) at \(task.dueDate, style: .time)")
    }
    
    private func isDueDateClose(_ date: Date) -> Bool {
        let timeUntilDue = date.timeIntervalSince(Date())
        return timeUntilDue > 0 && timeUntilDue < 24 * 60 * 60
    }
}
