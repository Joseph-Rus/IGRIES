import SwiftUI

struct BlackboardCalendarView: View {
    @EnvironmentObject var taskVM: TaskViewModel
    @EnvironmentObject var sessionManager: SessionManager
    @State private var blackboardTasks: [TaskItem] = []
    @State private var isLoading = false
    @Environment(\.colorScheme) var colorScheme
    
    let icsURL = "https://calbaptist.blackboard.com/webapps/calendar/calendarFeed/02190916b6604c7ba3be7648eddd9f4f/learn.ics"
    
    // Reference to ThemeManager
    private let theme = ThemeManager.shared
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Use ThemeManager's background gradient
                theme.backgroundGradient
                    .ignoresSafeArea()
                
                VStack {
                    if isLoading {
                        ProgressView("Loading Calendar...")
                            .padding()
                            .foregroundColor(theme.textPrimary)
                    } else if blackboardTasks.isEmpty {
                        emptyStateView
                    } else {
                        List {
                            ForEach(blackboardTasks) { task in
                                taskRowView(task)
                                    .listRowBackground(Color.clear)
                                    .listRowSeparator(.hidden)
                                    .swipeActions(edge: .leading) {
                                        Button {
                                            addToTasks(task)
                                        } label: {
                                            Label("Add to Tasks", systemImage: "plus.circle")
                                        }
                                        .tint(theme.accentColor)
                                    }
                            }
                        }
                        .listStyle(PlainListStyle())
                        .scrollContentBackground(.hidden)
                    }
                    
                    Button("Fetch Blackboard Calendar") {
                        fetchBlackboardCalendar()
                    }
                    .font(theme.bodyFont())
                    .fontWeight(.semibold)
                    .foregroundColor(theme.textPrimary)
                    .padding()
                    .background(theme.taskButtonGradient)
                    .cornerRadius(theme.cornerRadiusMedium)
                    .modifier(theme.buttonShadow())
                    .padding(.bottom, 20)
                    .disabled(isLoading) // Prevent multiple taps during loading
                }
                .navigationTitle("Blackboard Calendar")
            }
        }
        .preferredColorScheme(.dark)
    }
    
    // Empty State View styled with ThemeManager
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "calendar")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 100, height: 100)
                .foregroundColor(theme.textSecondary.opacity(0.6))
            
            Text("No tasks found")
                .font(theme.titleFont())
                .foregroundColor(theme.textPrimary)
            
            Text("Tap the button below to fetch your Blackboard calendar")
                .font(theme.captionFont())
                .foregroundColor(theme.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    // Task Row View styled with ThemeManager
    private func taskRowView(_ task: TaskItem) -> some View {
        VStack(alignment: .leading, spacing: 5) {
            HStack {
                Text(task.title)
                    .font(theme.bodyFont())
                    .foregroundColor(theme.textPrimary)
                
                if let course = task.course, !course.isEmpty {
                    Text("• \(course)")
                        .font(theme.captionFont())
                        .foregroundColor(theme.secondaryAccent.opacity(0.9))
                }
            }
            
            Text("Due: \(task.dueDate.formatted(date: .abbreviated, time: .shortened))")
                .font(theme.captionFont())
                .foregroundColor(theme.textSecondary)
            
            if !task.description.isEmpty {
                Text(task.description)
                    .font(theme.captionFont(size: 12))
                    .foregroundColor(theme.textSecondary)
                    .lineLimit(2)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: theme.cornerRadiusMedium)
                .fill(theme.cardBackgroundAlt)
                .modifier(theme.standardShadow(radius: 3, x: 0, y: 2))
        )
        .padding(.horizontal)
        .padding(.vertical, 5)
    }
    
    private func fetchBlackboardCalendar() {
        isLoading = true
        let parser = ICSParser()
        
        parser.fetchAndParseICS(from: icsURL) { eventWrappers, error in
            // Check for an error
            if let error = error {
                print("Error fetching ICS: \(error.localizedDescription)")
                self.isLoading = false
                return
            }
            
            // Handle the successful case with eventWrappers
            if let eventWrappers = eventWrappers {
                self.blackboardTasks = eventWrappers.map { wrapper in
                    var task = wrapper.task
                    task.id = UUID().uuidString // Assign temporary ID for display
                    if let userId = sessionManager.currentUserId {
                        task.userId = userId
                    }
                    print("Parsed task: \(task.title), Due: \(task.dueDate), Course: \(task.course ?? "None")")
                    return task
                }
                print("Set blackboardTasks with \(self.blackboardTasks.count) tasks")
            } else {
                print("No event wrappers returned")
            }
            
            // Ensure loading state is reset
            self.isLoading = false
        }
    }
    private func addToTasks(_ task: TaskItem) {
        guard let userId = sessionManager.currentUserId else { return }
        
        // Create a new task with the current user ID and nil ID for Firestore
        var newTask = task
        newTask.userId = userId
        newTask.id = nil // Ensure Firestore generates a new ID
        
        // Add to tasks
        taskVM.addTask(newTask)
    }
}

struct BlackboardCalendarView_Previews: PreviewProvider {
    static var previews: some View {
        BlackboardCalendarView()
            .environmentObject(TaskViewModel())
            .environmentObject(SessionManager())
            .preferredColorScheme(.dark)
    }
}
