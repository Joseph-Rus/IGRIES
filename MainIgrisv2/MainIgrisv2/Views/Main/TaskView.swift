import SwiftUI
import FirebaseAuth

struct TasksView: View {
    @EnvironmentObject var sessionManager: SessionManager
    @EnvironmentObject var taskVM: TaskViewModel
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var colorScheme
    
    @State private var showAddTask = false
    @State private var showICSFeed = false
    @State private var selectedFilter: TaskFilter = .all
    
    enum TaskFilter {
        case all, active, completed
    }
    
    private var filteredTasks: [TaskItem] {
        // First filter by selected filter
        let tasks = switch selectedFilter {
        case .all:
            taskVM.tasks
        case .active:
            taskVM.tasks.filter { !$0.isComplete }
        case .completed:
            taskVM.tasks.filter { $0.isComplete }
        }
        
        // Then sort by due date (closest due dates first)
        return tasks.sorted { task1, task2 in
            return task1.dueDate < task2.dueDate
        }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Updated gradient to match TodoListView
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color.blue.opacity(0.7),
                        Color.purple.opacity(0.7)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack(spacing: 15) {
                    // Filter Segment Control
                    Picker("Filter", selection: $selectedFilter) {
                        Text("All").tag(TaskFilter.all)
                        Text("Active").tag(TaskFilter.active)
                        Text("Completed").tag(TaskFilter.completed)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding(.horizontal)
                    .padding(.top, 10)
                    
                    // Tasks List without upcoming due dates section
                    if filteredTasks.isEmpty {
                        emptyStateView
                    } else {
                        List {
                            // All tasks - removed the Upcoming Due Dates section
                            Section {
                                ForEach(filteredTasks) { task in
                                    taskRowView(task)
                                        .listRowBackground(Color.clear)
                                        .listRowSeparator(.hidden)
                                        .swipeActions(edge: .trailing) {
                                            Button(role: .destructive) {
                                                if let taskId = task.id {
                                                    taskVM.deleteTask(task)
                                                }
                                            } label: {
                                                Label("Delete", systemImage: "trash")
                                            }
                                        }
                                        .swipeActions(edge: .leading) {
                                            Button {
                                                taskVM.addTaskToTodoList(task)
                                            } label: {
                                                Label("Todo", systemImage: "text.badge.plus")
                                            }
                                            .tint(.blue)
                                        }
                                }
                            }
                        }
                        .listStyle(InsetGroupedListStyle())
                        .scrollContentBackground(.hidden) // Transparent background for list
                    }
                }
                .navigationTitle("Tasks")
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button(action: { dismiss() }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.white.opacity(0.7))
                        }
                    }
                    
                    ToolbarItem(placement: .navigationBarTrailing) {
                        HStack {
                            Button(action: { showICSFeed.toggle() }) {
                                Image(systemName: "calendar.badge.plus")
                                    .foregroundColor(.white)
                            }
                            
                            Button(action: { showAddTask.toggle() }) {
                                Image(systemName: "plus.circle.fill")
                                    .foregroundColor(.white)
                            }
                        }
                    }
                }
                .sheet(isPresented: $showAddTask) {
                    AddTaskView()
                        .environmentObject(sessionManager)
                        .environmentObject(taskVM)
                }
                .sheet(isPresented: $showICSFeed) {
                    ICSFeedView()
                        .environmentObject(sessionManager)
                        .environmentObject(taskVM)
                }
            }
        }
        .preferredColorScheme(.dark) // Match TodoListView dark mode
        .onAppear {
            NotificationManager.shared.requestPermission()
            if let userId = Auth.auth().currentUser?.uid {
                taskVM.fetchTasks(for: userId)
                taskVM.fetchICSLinkAndSync(userId: userId)
                NotificationManager.shared.scheduleAllTaskNotifications(tasks: taskVM.tasks, remindBeforeMinutes: 30)
            }
        }
        .onChange(of: taskVM.tasks) { _, newTasks in
            NotificationManager.shared.scheduleAllTaskNotifications(tasks: newTasks, remindBeforeMinutes: 30)
        }
    }
    
    // Empty State View - styled to match TodoListView
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "list.bullet.clipboard")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 100, height: 100)
                .foregroundColor(.white.opacity(0.6))
            
            Text("No tasks yet")
                .font(.headline)
                .foregroundColor(.white)
            
            Text("Tap the '+' button to add a new task")
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.8))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    // Task Row View - styled to match TodoListView
    private func taskRowView(_ task: TaskItem) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 5) {
                HStack {
                    Text(task.title)
                        .font(.headline)
                        .foregroundColor(.white)
                        .strikethrough(task.isComplete)
                    
                    if let course = task.course, !course.isEmpty {
                        Text("• \(course)")
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.9))
                    }
                }
                
                Text(task.description)
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.7))
                    .lineLimit(1)
                
                Text("Due: \(task.dueDate, style: .date)")
                    .font(.caption)
                    .foregroundColor(isDueDateClose(task.dueDate) ? .red : .white.opacity(0.7))
            }
            
            Spacer()
            
            // Completion Toggle
            Button(action: {
                taskVM.toggleTaskCompletion(task)
            }) {
                Image(systemName: task.isComplete ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(task.isComplete ? .green : .white.opacity(0.7))
                    .imageScale(.large)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 10) // Changed to match TodoListView
                .fill(Color.white.opacity(0.2)) // Changed to match TodoListView
                .shadow(color: .black.opacity(0.1), radius: 3, x: 0, y: 2)
        )
        .padding(.horizontal)
        .padding(.vertical, 5)
    }
    
    // Check if due date is within the next 24 hours
    private func isDueDateClose(_ date: Date) -> Bool {
        let timeUntilDue = date.timeIntervalSince(Date())
        return timeUntilDue > 0 && timeUntilDue < 24 * 60 * 60 // Less than 24 hours
    }
    
    // Delete Items Function
    private func deleteItems(offsets: IndexSet) {
        offsets.map { filteredTasks[$0] }.forEach { task in
            taskVM.deleteTask(task)
        }
    }
}

struct TasksView_Preview: PreviewProvider {
    static var previews: some View {
        TasksView()
            .environmentObject(SessionManager())
            .environmentObject(TaskViewModel())
            .preferredColorScheme(.dark)
    }
}
