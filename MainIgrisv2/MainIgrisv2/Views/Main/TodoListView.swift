import SwiftUI
import FirebaseAuth

struct TodoListView: View {
    @EnvironmentObject var sessionManager: SessionManager
    @EnvironmentObject var taskVM: TaskViewModel
    @Environment(\.colorScheme) var colorScheme
    
    private var todoTasks: [TaskItem] {
        // Sort tasks by due date
        return taskVM.todoListTasks.sorted { task1, task2 in
            return task1.dueDate < task2.dueDate
        }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background gradient
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color.blue.opacity(0.7),
                        Color.purple.opacity(0.7)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack {
                    if todoTasks.isEmpty {
                        emptyStateView
                    } else {
                        List {
                            ForEach(todoTasks) { task in
                                todoTaskRowView(task)
                                    .listRowBackground(Color.clear)
                                    .listRowSeparator(.hidden)
                                    .swipeActions(edge: .trailing) {
                                        Button(role: .destructive) {
                                            taskVM.removeTaskFromTodoList(task)
                                        } label: {
                                            Label("Remove", systemImage: "trash")
                                        }
                                    }
                            }
                        }
                        .listStyle(PlainListStyle())
                    }
                }
                .navigationTitle("Todo List")
            }
        }
        .preferredColorScheme(.dark)
        .onAppear {
            if let userId = sessionManager.currentUserId {
                // Ensure todo list tasks are up to date
                taskVM.fetchTasks(for: userId)
            }
        }
    }
    
    // Empty State View
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "checkmark.circle")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 100, height: 100)
                .foregroundColor(.white.opacity(0.6))
            
            Text("Your todo list is empty")
                .font(.headline)
                .foregroundColor(.white)
            
            Text("Swipe right on tasks to add them here")
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.8))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    // Todo Task Row View
    private func todoTaskRowView(_ task: TaskItem) -> some View {
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
                
                if !task.description.isEmpty {
                    Text(task.description)
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.7))
                        .lineLimit(1)
                }
                
                Text("Due: \(task.dueDate, style: .date) at \(task.dueDate, style: .time)")
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
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.white.opacity(0.2))
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
}

struct TodoListView_Previews: PreviewProvider {
    static var previews: some View {
        TodoListView()
            .environmentObject(SessionManager())
            .environmentObject(TaskViewModel())
    }
}
