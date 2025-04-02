import SwiftUI
import FirebaseFirestore

struct HomeView: View {
    @EnvironmentObject var sessionManager: SessionManager
    @EnvironmentObject var taskVM: TaskViewModel
    @Environment(\.colorScheme) var colorScheme
    
    @State private var showingTasks = false
    @State private var showingAddTask = false
    @State private var showingCalendarHelp = false
    
    // State for motivational quote
    @State private var quote: String = ""
    @State private var quoteAuthor: String = ""
    
    // Task completion stats
    @State private var completedTasksToday: Int = 0
    @State private var totalTasksToday: Int = 0
    
    // Reference to ThemeManager
    private let theme = ThemeManager.shared
    
    // Background gradient - using ThemeManager
    private var backgroundGradient: some View {
        theme.backgroundGradient
            .ignoresSafeArea()
    }
    
    // Header section with ThemeManager styling
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(alignment: .top) {
                VStack(alignment: .leading) {
                    Text("Hello, \(sessionManager.currentUserName ?? "User")!")
                        .font(theme.titleFont(size: 28))
                        .foregroundColor(theme.textPrimary)
                    
                    Text(Date(), style: .date)
                        .font(theme.captionFont(size: 15))
                        .foregroundColor(theme.textSecondary)
                }
                
                Spacer()
            }
            
            // Motivational quote with ThemeManager styling
            VStack(alignment: .leading, spacing: 4) {
                Text("\"\(quote)\"")
                    .font(.system(size: 14, weight: .medium, design: .serif))
                    .foregroundColor(theme.textSecondary)
                    .italic()
                    .padding(.top, 8)
                
                Text("— \(quoteAuthor)")
                    .font(theme.captionFont(size: 12))
                    .foregroundColor(theme.secondaryAccent)
            }
            .padding(.top, 2)
            
            // Action buttons row
            HStack(spacing: 10) {
                // Quick add button - ThemeManager styling
                Button(action: { showingAddTask = true }) {
                    Label("Add Task", systemImage: "plus.circle.fill")
                        .font(theme.captionFont())
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(
                            Capsule()
                                .fill(theme.accentColor.opacity(0.2))
                        )
                        .overlay(
                            Capsule()
                                .strokeBorder(theme.accentColor.opacity(0.4), lineWidth: 1.5)
                        )
                        .foregroundColor(theme.accentColor)
                }
                
                // Calendar Help Button
                Button(action: { showingCalendarHelp = true }) {
                    Label("Calendar Help", systemImage: "calendar.badge.questionmark")
                        .font(theme.captionFont())
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(
                            Capsule()
                                .fill(theme.secondaryAccent.opacity(0.2))
                        )
                        .overlay(
                            Capsule()
                                .strokeBorder(theme.secondaryAccent.opacity(0.4), lineWidth: 1.5)
                        )
                        .foregroundColor(theme.secondaryAccent)
                }
            }
            .padding(.top, 14)
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: theme.cornerRadiusLarge)
                .fill(theme.cardBackground)
                .modifier(theme.standardShadow())
        )
    }
    
    // Progress Overview Section with ThemeManager styling
    private var progressSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Today's Progress")
                .font(theme.titleFont())
                .foregroundColor(theme.textPrimary)
            
            HStack(spacing: 18) {
                // Tasks completion stats with ThemeManager styling
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(theme.accentColor)
                        
                        Text("Tasks")
                            .font(theme.bodyFont())
                            .foregroundColor(theme.textPrimary)
                    }
                    
                    Text("\(completedTasksToday)/\(totalTasksToday) completed")
                        .font(theme.captionFont())
                        .foregroundColor(theme.textSecondary)
                    
                    // Progress bar with ThemeManager styling
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: theme.cornerRadiusSmall)
                                .frame(width: geometry.size.width, height: 8)
                                .foregroundColor(theme.progressBackground)
                            
                            RoundedRectangle(cornerRadius: theme.cornerRadiusSmall)
                                .frame(width: totalTasksToday > 0 ?
                                    CGFloat(completedTasksToday) / CGFloat(totalTasksToday) * geometry.size.width : 0,
                                       height: 8)
                                .foregroundColor(theme.accentColor)
                        }
                    }
                    .frame(height: 8)
                }
                .frame(maxWidth: .infinity)
                .padding(16)
                .background(
                    RoundedRectangle(cornerRadius: theme.cornerRadiusMedium)
                        .fill(theme.cardBackgroundAlt)
                )
                
                // Calendar day progress with ThemeManager styling
                VStack(alignment: .center, spacing: 8) {
                    Text("DAY")
                        .font(theme.captionFont(size: 12))
                        .fontWeight(.bold)
                        .foregroundColor(theme.textSecondary)
                    
                    ZStack {
                        Circle()
                            .stroke(theme.progressBackground, lineWidth: 4)
                            .frame(width: 64, height: 64)
                        
                        Circle()
                            .trim(from: 0.0, to: dayProgress)
                            .stroke(theme.accentColor, lineWidth: 4)
                            .frame(width: 64, height: 64)
                            .rotationEffect(Angle(degrees: -90))
                        
                        VStack(spacing: 0) {
                            Text("\(Calendar.current.component(.day, from: Date()))")
                                .font(theme.titleFont(size: 24))
                                .foregroundColor(theme.textPrimary)
                            
                            Text(monthAbbreviation)
                                .font(theme.captionFont(size: 12))
                                .foregroundColor(theme.textSecondary)
                        }
                    }
                }
                .frame(width: 90)
                .padding(16)
                .background(
                    RoundedRectangle(cornerRadius: theme.cornerRadiusMedium)
                        .fill(theme.cardBackgroundAlt)
                )
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: theme.cornerRadiusLarge)
                .fill(theme.cardBackground)
                .modifier(theme.standardShadow())
        )
    }
    
    // Quick Actions Section with ThemeManager styling
    private var quickActionsSection: some View {
        HStack(spacing: 15) {
            quickActionButton(
                title: "Tasks",
                icon: "list.bullet.rectangle.fill",
                gradient: theme.taskButtonGradient,
                count: totalTasksToday
            ) {
                showingTasks = true
            }
        }
    }
    
    // Enhanced Quick Action Button with ThemeManager styling
    private func quickActionButton(
        title: String,
        icon: String,
        gradient: LinearGradient,
        count: Int,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            VStack(spacing: 14) {
                ZStack {
                    Circle()
                        .fill(theme.progressBackground)
                        .frame(width: 68, height: 68)
                    
                    Image(systemName: icon)
                        .font(.system(size: 30))
                        .foregroundColor(theme.textPrimary)
                    
                    // Badge with ThemeManager styling
                    if count > 0 {
                        Text("\(count)")
                            .font(theme.captionFont(size: 13))
                            .fontWeight(.bold)
                            .foregroundColor(theme.textPrimary)
                            .padding(6)
                            .background(theme.accentColor)
                            .clipShape(Circle())
                            .overlay(
                                Circle()
                                    .stroke(theme.cardBackground, lineWidth: 2)
                            )
                            .offset(x: 25, y: -25)
                    }
                }
                
                Text(title)
                    .font(theme.titleFont())
                    .foregroundColor(theme.textPrimary)
            }
            .frame(minWidth: 0, maxWidth: .infinity)
            .frame(height: 120)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: theme.cornerRadiusLarge)
                    .fill(theme.cardGradient)
                    .modifier(theme.buttonShadow())
            )
        }
    }
    
    // Today's Tasks Section with ThemeManager styling
    private var todayTasksSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Today's Tasks")
                    .font(theme.titleFont())
                    .foregroundColor(theme.textPrimary)
                
                Spacer()
                
                NavigationLink(destination: TasksView()) {
                    Text("View All")
                        .font(theme.captionFont())
                        .foregroundColor(theme.accentColor)
                }
            }
            
            if todaysTasks.isEmpty {
                emptyStateView(message: "No tasks for today", icon: "checkmark.circle")
            } else {
                ForEach(todaysTasks.prefix(3), id: \.id) { task in
                    taskRowView(task)
                }
                
                if todaysTasks.count > 3 {
                    Text("+ \(todaysTasks.count - 3) more")
                        .font(theme.captionFont())
                        .foregroundColor(theme.textSecondary)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.top, 8)
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: theme.cornerRadiusLarge)
                .fill(theme.cardBackground)
                .modifier(theme.standardShadow())
        )
    }
    
    // Enhanced empty state view with ThemeManager styling
    private func emptyStateView(message: String, icon: String) -> some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 30))
                .foregroundColor(theme.textSecondary.opacity(0.5))
                .padding(.bottom, 4)
            
            Text(message)
                .font(theme.captionFont(size: 15))
                .foregroundColor(theme.textSecondary)
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.bottom, 8)
        }
        .padding(.vertical, 24)
        .background(
            RoundedRectangle(cornerRadius: theme.cornerRadiusMedium)
                .fill(theme.cardBackgroundAlt)
        )
    }
    
    // Enhanced task row view with ThemeManager styling
    private func taskRowView(_ task: TaskItem) -> some View {
        HStack {
            // Task indicator with ThemeManager styling
            Circle()
                .fill(taskStatusColor(isComplete: task.isComplete, dueDate: task.dueDate))
                .frame(width: 12, height: 12)
            
            VStack(alignment: .leading, spacing: 5) {
                Text(task.title)
                    .font(theme.bodyFont())
                    .foregroundColor(theme.textPrimary)
                
                if !task.description.isEmpty {
                    Text(task.description)
                        .font(theme.captionFont())
                        .foregroundColor(theme.textSecondary)
                        .lineLimit(1)
                }
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 5) {
                Text(task.dueDate, style: .time)
                    .font(theme.captionFont(size: 13))
                    .foregroundColor(theme.textSecondary)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(
                        Capsule()
                            .fill(theme.progressBackground)
                    )
                
                // Add course information with ThemeManager styling
                if let course = task.course, !course.isEmpty {
                    Text(course)
                        .font(theme.captionFont(size: 12))
                        .foregroundColor(theme.secondaryAccent)
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: theme.cornerRadiusMedium)
                .fill(theme.cardBackgroundAlt)
        )
    }
    
    // Format time from date
    private func formatTime(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    // Task status indicator color using ThemeManager
    private func taskStatusColor(isComplete: Bool, dueDate: Date) -> Color {
        if isComplete {
            return theme.accentColor
        }
        
        // Check if task is overdue
        if dueDate < Date() {
            return theme.errorColor
        }
        
        // Due today
        let calendar = Calendar.current
        if calendar.isDateInToday(dueDate) {
            return theme.warningColor
        }
        
        // Future task
        return theme.successColor
    }
    
    // Toolbar content with ThemeManager styling
    private var toolbarContent: some ToolbarContent {
        Group {
            ToolbarItem(placement: .navigationBarLeading) {
                Text("Dashboard")
                    .font(theme.titleFont())
                    .foregroundColor(theme.textPrimary)
            }
            
            ToolbarItem(placement: .navigationBarTrailing) {
                NavigationLink(destination: ProfileView()) {
                    Image(systemName: "person.circle.fill")
                        .font(.title2)
                        .foregroundColor(theme.accentColor)
                }
            }
        }
    }
    
    // Main content
    private var mainContent: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 24) {
                headerSection
                progressSection
                quickActionsSection
                todayTasksSection
            }
            .padding(16)
            .padding(.bottom, 80) // Extra padding at bottom for tab bar
        }
    }
    
    // Main body
    var body: some View {
        NavigationStack {
            ZStack {
                backgroundGradient
                mainContent
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                toolbarContent
            }
            .sheet(isPresented: $showingTasks) {
                TasksView()
                    .environmentObject(sessionManager)
                    .environmentObject(taskVM)
            }
            .sheet(isPresented: $showingAddTask) {
                AddTaskView()
                    .environmentObject(sessionManager)
                    .environmentObject(taskVM)
            }
            .sheet(isPresented: $showingCalendarHelp) {
                CalendarHelpView()
            }
            .onAppear {
                // Fetch data when view appears
                updateTaskStats()
                loadDailyQuote()
            }
            .onChange(of: taskVM.tasks) { _ in
                // Update task statistics when task list changes
                updateTaskStats()
            }
        }
        .preferredColorScheme(.dark)
    }
    
    // Update task statistics
    private func updateTaskStats() {
        let calendar = Calendar.current
        
        // Calculate completed and total tasks for today
        let todayTasks = taskVM.tasks.filter { calendar.isDate($0.dueDate, inSameDayAs: Date()) }
        completedTasksToday = todayTasks.filter { $0.isComplete }.count
        totalTasksToday = todayTasks.count
    }
    
    // Computed properties for filtering tasks
    private var todaysTasks: [TaskItem] {
        let calendar = Calendar.current
        return taskVM.tasks.filter { task in
            calendar.isDate(task.dueDate, inSameDayAs: Date()) && !task.isComplete
        }
        .sorted { $0.dueDate < $1.dueDate }
    }
    
    // Calculate day progress (what percentage of the day has passed)
    private var dayProgress: Double {
        let now = Date()
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: now)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        
        let totalSeconds = endOfDay.timeIntervalSince(startOfDay)
        let elapsedSeconds = now.timeIntervalSince(startOfDay)
        
        return min(1.0, max(0.0, elapsedSeconds / totalSeconds))
    }
    
    // Get month abbreviation
    private var monthAbbreviation: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM"
        return dateFormatter.string(from: Date())
    }
    
    // Load the daily quote from our local QuoteManager
    private func loadDailyQuote() {
        // Get today's quote
        let dailyQuote = QuoteManager.shared.getDailyQuote()
        quote = dailyQuote.text
        quoteAuthor = dailyQuote.author
    }
}

struct CalendarHelpView: View {
    @Environment(\.dismiss) var dismiss
    
    // Reference to ThemeManager
    private let theme = ThemeManager.shared
    
    var body: some View {
        ZStack {
            // Background color
            theme.darkBackground
                .ignoresSafeArea()
            
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Header
                    HStack {
                        Text("How to Link Your Blackboard Calendar")
                            .font(theme.titleFont(size: 22))
                            .foregroundColor(theme.textPrimary)
                        
                        Spacer()
                        
                        Button(action: {
                            dismiss()
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .font(.title2)
                                .foregroundColor(theme.textSecondary)
                        }
                    }
                    .padding(.bottom, 10)
                    
                    // Step 1
                    stepView(
                        number: "1",
                        title: "Open Blackboard",
                        description: "Log in to your Blackboard account using your credentials."
                    )
                    
                    // Step 2
                    stepView(
                        number: "2",
                        title: "Navigate to Calendar",
                        description: "Click on the Calendar tab in the left sidebar menu."
                    )
                    
                    // Step 3
                    stepView(
                        number: "3",
                        title: "Open Calendar Settings",
                        description: "Click on the gear icon (⚙️) in the top right corner of the calendar page."
                    )
                    
                    // Step 4
                    stepView(
                        number: "4",
                        title: "Access Sharing Options",
                        description: "Click on the three dots menu (⋯) in the top right of the settings panel."
                    )
                    
                    // Step 5
                    stepView(
                        number: "5",
                        title: "Get Share Link",
                        description: "Select 'Share Calendar' from the dropdown menu."
                    )
                    
                    // Step 6
                    stepView(
                        number: "6",
                        title: "Copy the ICS URL",
                        description: "Copy the provided calendar URL (it should end with .ics)."
                    )
                    
                    // Step 7
                    stepView(
                        number: "7",
                        title: "Paste in IGRIS App",
                        description: "Return to the IGRIS app, go to Tasks → Calendar Feed (three dots menu), and paste the URL in the field."
                    )
                    
                    Divider()
                        .background(theme.textSecondary.opacity(0.3))
                        .padding(.vertical, 8)
                    
                    Text("After saving, your Blackboard assignments will automatically sync with your IGRIS tasks.")
                        .font(theme.bodyFont())
                        .foregroundColor(theme.textPrimary)
                        .padding(.bottom, 10)
                    
                    Text("Trouble finding the option?")
                        .font(theme.bodyFont(size: 16))
                        .foregroundColor(theme.accentColor)
                        .padding(.bottom, 4)
                    
                    Text("Different institutions may have slightly different Blackboard versions. If you don't see the exact options described, look for 'Export Calendar', 'iCal Feed', or 'Subscribe' options that provide a URL.")
                        .font(theme.captionFont())
                        .foregroundColor(theme.textSecondary)
                    
                    Spacer()
                    
                    Button(action: {
                        dismiss()
                    }) {
                        Text("Got it!")
                            .font(theme.bodyFont())
                            .fontWeight(.bold)
                            .foregroundColor(Color.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(theme.accentColor)
                            .cornerRadius(theme.cornerRadiusMedium)
                    }
                    .padding(.top, 20)
                }
                .padding(24)
            }
        }
        .preferredColorScheme(.dark)
    }
    
    private func stepView(number: String, title: String, description: String) -> some View {
        HStack(alignment: .top, spacing: 16) {
            // Step number
            ZStack {
                Circle()
                    .fill(theme.accentColor)
                    .frame(width: 30, height: 30)
                
                Text(number)
                    .font(theme.bodyFont(size: 16))
                    .fontWeight(.bold)
                    .foregroundColor(theme.textPrimary)
            }
            
            VStack(alignment: .leading, spacing: 5) {
                Text(title)
                    .font(theme.bodyFont(size: 16))
                    .fontWeight(.semibold)
                    .foregroundColor(theme.textPrimary)
                
                Text(description)
                    .font(theme.captionFont())
                    .foregroundColor(theme.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(.vertical, 5)
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
            .environmentObject(SessionManager())
            .environmentObject(TaskViewModel())
            .preferredColorScheme(.dark)
    }
}
