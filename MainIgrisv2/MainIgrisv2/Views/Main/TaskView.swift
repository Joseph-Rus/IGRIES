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
    @State private var showCleanupAlert = false
    @State private var cleanupPerformed = false
    
    // Reference to ThemeManager
    private let theme = ThemeManager.shared
    
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
                // Background gradient - using ThemeManager
                theme.backgroundGradient
                    .ignoresSafeArea()
                
                VStack(spacing: 20) {
                    // Filter Segment Control - styled with ThemeManager
                    Picker("Filter", selection: $selectedFilter) {
                        Text("All")
                            .foregroundColor(theme.textPrimary)
                            .font(theme.captionFont(size: 14)) // Smaller font to match image
                            .frame(minWidth: 60) // Set a minimum width for "All"
                            .tag(TaskFilter.all)
                        Text("Active")
                            .foregroundColor(theme.textPrimary)
                            .font(theme.captionFont(size: 14))
                            .frame(minWidth: 80) // Slightly wider for "Active"
                            .tag(TaskFilter.active)
                        Text("Completed")
                            .foregroundColor(theme.textPrimary)
                            .font(theme.captionFont(size: 14))
                            .frame(minWidth: 100) // Wider for "Completed"
                            .tag(TaskFilter.completed)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding(.horizontal, 12) // Adjusted padding to match image
                    .padding(.top, 12)
                    .padding(.bottom, 12)
                    .tint(theme.textPrimary) // Force text color to white
                    .accentColor(theme.accentColor) // Selected segment color
                    .background(
                        RoundedRectangle(cornerRadius: theme.cornerRadiusMedium)
                            .fill(theme.cardBackgroundAlt)
                    )
                    .preferredColorScheme(.dark) // Ensure dark mode rendering
                    
                    // Tasks List
                    if filteredTasks.isEmpty {
                        emptyStateView
                    } else {
                        List {
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
                                            .tint(theme.accentColor)
                                        }
                                }
                            }
                        }
                        .listStyle(InsetGroupedListStyle())
                        .scrollContentBackground(.hidden)
                    }
                }
                .navigationTitle("Tasks")
                .navigationBarBackButtonHidden(true)
                .toolbar {
                    ToolbarItem(placement: .principal) {
                        Text("Tasks")
                            .font(theme.titleFont())
                            .foregroundColor(theme.textPrimary)
                    }
                    
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Menu {
                            Button(action: { showAddTask.toggle() }) {
                                Label("Add Task", systemImage: "plus.circle.fill")
                                    .foregroundColor(theme.accentColor)
                            }
                            
                            Button(action: { showICSFeed.toggle() }) {
                                Label("Calendar Feed", systemImage: "calendar.badge.plus")
                                    .foregroundColor(theme.accentColor)
                            }
                            
                            Button(action: { showCleanupAlert = true }) {
                                Label("Clean Up Old Tasks", systemImage: "trash.circle.fill")
                                    .foregroundColor(theme.accentColor)
                            }
                        } label: {
                            Image(systemName: "ellipsis.circle.fill")
                                .font(.system(size: 22))
                                .foregroundColor(theme.accentColor)
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
                .alert("Clean Up Old Tasks", isPresented: $showCleanupAlert) {
                    Button("Cancel", role: .cancel) {}
                    Button("Clean Up", role: .destructive) {
                        if let userId = sessionManager.currentUserId {
                            taskVM.manualCleanup(userId: userId)
                            cleanupPerformed = true
                        }
                    }
                } message: {
                    Text("This will remove completed or overdue tasks that are older than 3 days. This action cannot be undone.")
                }
                .alert("Cleanup Complete", isPresented: $cleanupPerformed) {
                    Button("OK", role: .cancel) {}
                } message: {
                    Text("Old tasks have been removed.")
                }
            }
        }
        .preferredColorScheme(.dark)
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
    
    // Empty State View with ThemeManager styling
    private var emptyStateView: some View {
        VStack(spacing: 24) {
            Image(systemName: "list.bullet.clipboard")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 90, height: 90)
                .foregroundColor(theme.secondaryAccent.opacity(0.5))
                .modifier(theme.standardShadow(radius: 10, x: 0, y: 5))
            
            Text("No tasks yet")
                .font(theme.titleFont(size: 20))
                .foregroundColor(theme.textPrimary)
            
            Text("Tap the '+' button to add a new task")
                .font(theme.bodyFont())
                .foregroundColor(theme.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    // Task Row View with ThemeManager styling
    private func taskRowView(_ task: TaskItem) -> some View {
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
                
                HStack {
                    Image(systemName: "calendar")
                        .font(.system(size: 12))
                        .foregroundColor(isDueDateClose(task.dueDate) ? theme.errorColor : theme.textSecondary)
                    
                    Text(task.dueDate, style: .date)
                        .font(theme.captionFont(size: 12))
                        .foregroundColor(isDueDateClose(task.dueDate) ? theme.errorColor : theme.textSecondary)
                }
                .padding(.top, 2)
            }
            
            Spacer()
            
            // Completion Toggle with ThemeManager styling
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
                            .foregroundColor(theme.textPrimary)
                    }
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: theme.cornerRadiusMedium)
                .fill(theme.cardBackgroundAlt)
                .modifier(theme.standardShadow(radius: 5, x: 0, y: 3))
        )
        .padding(.horizontal)
        .padding(.vertical, 4)
    }
    
    // Check if due date is within the next 24 hours
    private func isDueDateClose(_ date: Date) -> Bool {
        let timeUntilDue = date.timeIntervalSince(Date())
        return timeUntilDue > 0 && timeUntilDue < 24 * 60 * 60 // Less than 24 hours
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
