import SwiftUI
import FirebaseAuth

struct TasksView: View {
    @EnvironmentObject var sessionManager: SessionManager
    @EnvironmentObject var taskVM: TaskViewModel
    @Environment(\.dismiss) var dismiss
    @State private var showAddTask = false
    @State private var showICSFeed = false
    
    var body: some View {
        NavigationView {
            List {
                ForEach(taskVM.tasks) { task in
                    VStack(alignment: .leading, spacing: 8) {
                        Text(task.title)
                            .font(.headline)
                            .foregroundColor(.black)
                        Text(task.description)
                            .font(.subheadline)
                            .foregroundColor(.black.opacity(0.8))
                        Text("Due: \(task.dueDate.formatted(date: .abbreviated, time: .shortened))")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    .padding()
                    .background(cardColor(for: task.dueDate))
                    .cornerRadius(15)
                    .shadow(color: .black.opacity(0.2), radius: 5, x: 0, y: 2)
                    .swipeActions(edge: .trailing) {
                        Button(role: .destructive) {
                            taskVM.deleteTask(task)
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
                    .swipeActions(edge: .leading) {
                        Button {
                            taskVM.markTaskComplete(task)
                        } label: {
                            Label("Complete", systemImage: "checkmark")
                        }
                        .tint(.green)
                    }
                }
                .onDelete(perform: deleteItems)
            }
            .navigationTitle("Tasks")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack {
                        Button(action: { showAddTask.toggle() }) {
                            Image(systemName: "plus")
                        }
                        Button(action: { showICSFeed.toggle() }) {
                            Text("Add ICS")
                                .fontWeight(.semibold)
                                .foregroundColor(.black)
                        }
                        Button(action: { dismiss() }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.black)
                                .font(.title2)
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
    }
    
    private func cardColor(for dueDate: Date) -> Color {
        let now = Date()
        let daysUntilDue = Calendar.current.dateComponents([.day], from: now, to: dueDate).day ?? 0
        switch daysUntilDue {
        case ..<0: return Color(red: 1.0, green: 0.8, blue: 0.8)
        case 0..<2: return Color(red: 1.0, green: 0.9, blue: 0.8)
        default: return Color(red: 0.8, green: 1.0, blue: 0.8)
        }
    }
    
    func deleteItems(offsets: IndexSet) {
        offsets.map { taskVM.tasks[$0] }.forEach { task in
            taskVM.deleteTask(task)
        }
    }
}

struct TasksView_Preview: PreviewProvider {
    static var previews: some View {
        TasksView()
            .environmentObject(SessionManager())
            .environmentObject(TaskViewModel())
    }
}
