import SwiftUI
import FirebaseFirestore

struct HomeView: View {
    @EnvironmentObject var sessionManager: SessionManager
    @EnvironmentObject var taskVM: TaskViewModel
    @EnvironmentObject var eventVM: EventViewModel
    @Environment(\.colorScheme) var colorScheme
    
    @State private var showingTasks = false
    @State private var showingEvents = false
    @State private var showingAddTask = false
    @State private var showingAddEvent = false
    
    // State for directly fetched events
    @State private var tomorrowsEvents: [EventItem] = []
    @State private var isLoadingEvents = false
    @State private var lastFilterTime = Date()
    
    // New state for weather and motivational quote
    @State private var weatherCondition: String = "sunny"
    @State private var temperature: Int = 72
    @State private var quote: String = "The secret of getting ahead is getting started."
    @State private var quoteAuthor: String = "Mark Twain"
    
    // Task completion stats
    @State private var completedTasksToday: Int = 0
    @State private var totalTasksToday: Int = 0
    
    // Button colors with refined gradients
    private let tasksButtonGradient = LinearGradient(
        gradient: Gradient(colors: [Color(hex: "36D1DC"), Color(hex: "5B86E5")]),
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    private let eventsButtonGradient = LinearGradient(
        gradient: Gradient(colors: [Color(hex: "FF416C"), Color(hex: "FF4B2B")]),
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    // Background gradient - more subtle and professional
    private var backgroundGradient: some View {
        LinearGradient(
            gradient: Gradient(colors: [
                Color(hex: "4A00E0").opacity(0.8),
                Color(hex: "8E2DE2").opacity(0.8)
            ]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }
    
    // Header section - enhanced with weather and time
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(alignment: .top) {
                VStack(alignment: .leading) {
                    Text("Hello, \(sessionManager.currentUserName ?? "User")!")
                        .font(.system(size: 26, weight: .bold))
                        .foregroundColor(.white)
                    
                    Text(Date(), style: .date)
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.9))
                }
                
                Spacer()
                
                // Weather summary
                VStack(alignment: .center) {
                    Image(systemName: weatherIcon)
                        .font(.system(size: 24))
                        .foregroundColor(.white)
                    
                    Text("\(temperature)°")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(.white)
                }
            }
            
            // Add motivational quote
            VStack(alignment: .leading, spacing: 4) {
                Text("\"\(quote)\"")
                    .font(.system(size: 14, weight: .medium, design: .serif))
                    .foregroundColor(.white.opacity(0.9))
                    .italic()
                    .padding(.top, 8)
                
                Text("— \(quoteAuthor)")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.white.opacity(0.8))
            }
            .padding(.top, 2)
            
            // Quick add buttons
            HStack(spacing: 10) {
                Button(action: { showingAddTask = true }) {
                    Label("Add Task", systemImage: "plus.circle")
                        .font(.system(size: 14, weight: .medium))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.white.opacity(0.2))
                        .cornerRadius(20)
                        .foregroundColor(.white)
                }
                
                Button(action: { showingAddEvent = true }) {
                    Label("Add Event", systemImage: "calendar.badge.plus")
                        .font(.system(size: 14, weight: .medium))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.white.opacity(0.2))
                        .cornerRadius(20)
                        .foregroundColor(.white)
                }
            }
            .padding(.top, 12)
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.2))
                .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
        )
    }
    
    // Progress Overview Section - New!
    private var progressSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Today's Progress")
                .font(.headline)
                .foregroundColor(.white)
                .padding(.bottom, 4)
            
            HStack(spacing: 15) {
                // Tasks completion stats
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                        
                        Text("Tasks")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.white)
                    }
                    
                    Text("\(completedTasksToday)/\(totalTasksToday) completed")
                        .font(.system(size: 14))
                        .foregroundColor(.white.opacity(0.8))
                    
                    // Progress bar
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            Rectangle()
                                .frame(width: geometry.size.width, height: 8)
                                .opacity(0.3)
                                .foregroundColor(.white)
                                .cornerRadius(4)
                            
                            Rectangle()
                                .frame(width: totalTasksToday > 0 ?
                                    CGFloat(completedTasksToday) / CGFloat(totalTasksToday) * geometry.size.width : 0,
                                    height: 8)
                                .foregroundColor(.green)
                                .cornerRadius(4)
                        }
                    }
                    .frame(height: 8)
                }
                .frame(maxWidth: .infinity)
                .padding(12)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.white.opacity(0.15))
                )
                
                // Calendar day progress
                VStack(alignment: .center, spacing: 6) {
                    Text("DAY")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.white.opacity(0.7))
                    
                    ZStack {
                        Circle()
                            .stroke(Color.white.opacity(0.3), lineWidth: 4)
                            .frame(width: 60, height: 60)
                        
                        Circle()
                            .trim(from: 0.0, to: dayProgress)
                            .stroke(Color(hex: "36D1DC"), lineWidth: 4)
                            .frame(width: 60, height: 60)
                            .rotationEffect(Angle(degrees: -90))
                        
                        VStack(spacing: 0) {
                            Text("\(Calendar.current.component(.day, from: Date()))")
                                .font(.system(size: 22, weight: .bold))
                                .foregroundColor(.white)
                            
                            Text(monthAbbreviation)
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(.white.opacity(0.8))
                        }
                    }
                }
                .frame(width: 80)
                .padding(12)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.white.opacity(0.15))
                )
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.2))
                .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
        )
    }
    
    // Quick Actions Section - improved with shadows and sizing
    private var quickActionsSection: some View {
        HStack(spacing: 15) {
            quickActionButton(
                title: "Tasks",
                icon: "list.bullet.rectangle",
                gradient: tasksButtonGradient,
                count: totalTasksToday
            ) {
                showingTasks = true
            }
            
            quickActionButton(
                title: "Events",
                icon: "calendar",
                gradient: eventsButtonGradient,
                count: tomorrowsEvents.count
            ) {
                showingEvents = true
            }
        }
    }
    
    // Enhanced Quick Action Button with badge count
    private func quickActionButton(
        title: String,
        icon: String,
        gradient: LinearGradient,
        count: Int,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            VStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(Color.white.opacity(0.2))
                        .frame(width: 60, height: 60)
                    
                    Image(systemName: icon)
                        .font(.system(size: 28))
                        .foregroundColor(.white)
                    
                    // Badge if there are items
                    if count > 0 {
                        Text("\(count)")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.white)
                            .padding(5)
                            .background(Color.red)
                            .clipShape(Circle())
                            .offset(x: 22, y: -22)
                    }
                }
                
                Text(title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
            }
            .frame(minWidth: 0, maxWidth: .infinity)
            .frame(height: 110)
            .padding(.vertical, 15)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(gradient)
                    .shadow(color: .black.opacity(0.3), radius: 8, x: 0, y: 4)
            )
        }
    }
    
    // Today's Tasks Section - enhanced with priority indicators
    private var todayTasksSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Today's Tasks")
                    .font(.headline)
                    .foregroundColor(.white)
                
                Spacer()
                
                NavigationLink(destination: TasksView()) {
                    Text("View All")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.white.opacity(0.8))
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
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.top, 4)
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.2))
                .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
        )
    }
    
    // Upcoming Events Preview - improved with time indicators
    private var upcomingEventsPreview: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Tomorrow's Events")
                    .font(.headline)
                    .foregroundColor(.white)
                
                Spacer()
                
                NavigationLink(destination: EventsView()) {
                    Text("View All")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.white.opacity(0.8))
                }
            }
            
            if isLoadingEvents {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    .scaleEffect(1.5)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 20)
            } else if tomorrowsEvents.isEmpty {
                emptyStateView(message: "No events tomorrow", icon: "calendar")
            } else {
                ForEach(Array(tomorrowsEvents.prefix(3).enumerated()), id: \.offset) { index, event in
                    eventRowView(event)
                }
                
                if tomorrowsEvents.count > 3 {
                    Text("+ \(tomorrowsEvents.count - 3) more")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.top, 4)
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.2))
                .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
        )
    }
    
    // Enhanced empty state view with icons
    private func emptyStateView(message: String, icon: String) -> some View {
        VStack(spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(.white.opacity(0.5))
                .padding(.bottom, 4)
            
            Text(message)
                .foregroundColor(.white.opacity(0.7))
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.bottom, 8)
        }
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.1))
        )
    }
    
    // Enhanced task row view without depending on priority property
    private func taskRowView(_ task: TaskItem) -> some View {
        HStack {
            // Task indicator using completion status instead of priority
            Circle()
                .fill(task.isComplete ? Color.green : Color.orange)
                .frame(width: 12, height: 12)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(task.title)
                    .font(.headline)
                    .foregroundColor(.white)
                
                if !task.description.isEmpty {
                    Text(task.description)
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.7))
                        .lineLimit(1)
                }
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text(task.dueDate, style: .time)
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.8))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(
                        Capsule()
                            .fill(Color.white.opacity(0.2))
                    )
                
                // Add course information if available
                if let course = task.course, !course.isEmpty {
                    Text(course)
                        .font(.caption2)
                        .foregroundColor(.white.opacity(0.7))
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.15))
                .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
        )
    }
    
    // Enhanced event row view with time formatting (adjusted for your model)
    private func eventRowView(_ event: EventItem) -> some View {
        HStack(spacing: 15) {
            // Time column with visual timeline
            VStack(spacing: 0) {
                Text(formatTime(from: event.startDate))
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white)
                
                if event.endDate != nil {
                    Rectangle()
                        .fill(Color.white.opacity(0.5))
                        .frame(width: 1, height: 20)
                
                    Text(formatTime(from: event.endDate ?? event.startDate))
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.white.opacity(0.7))
                }
            }
            .frame(width: 45)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(event.name)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                
                if !event.description.isEmpty {
                    Text(event.description)
                        .font(.system(size: 14))
                        .foregroundColor(.white.opacity(0.7))
                        .lineLimit(1)
                }
                
                // Show repeat indicator if event repeats
                if let repeatInterval = event.repeatInterval, !repeatInterval.isEmpty {
                    Text(formatRepeatInterval(repeatInterval))
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.9))
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.white.opacity(0.2))
                        .cornerRadius(4)
                }
            }
            
            Spacer()
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.15))
                .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
        )
    }
    
    // Format time from date
    private func formatTime(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    // Format the repeat interval for display
    private func formatRepeatInterval(_ interval: String) -> String {
        if interval.lowercased() == "daily" {
            return "Repeats Daily"
        } else if interval.lowercased() == "weekly" {
            return "Repeats Weekly"
        } else if interval.lowercased() == "monthly" {
            return "Repeats Monthly"
        }
        
        return "Repeats \(interval)"
    }
    
    // Task status indicator color
    private func taskStatusColor(isComplete: Bool, dueDate: Date) -> Color {
        if isComplete {
            return Color.green
        }
        
        // Check if task is overdue
        if dueDate < Date() {
            return Color.red
        }
        
        // Due today
        let calendar = Calendar.current
        if calendar.isDateInToday(dueDate) {
            return Color.orange
        }
        
        // Future task
        return Color.blue
    }
    
    // Toolbar content with search and profile
    private var toolbarContent: some ToolbarContent {
        Group {
            ToolbarItem(placement: .navigationBarLeading) {
                Text("Dashboard")
                    .font(.headline)
                    .foregroundColor(.white)
            }
            
            ToolbarItem(placement: .navigationBarTrailing) {
                HStack(spacing: 16) {
                    Button(action: {
                        // Action for search
                    }) {
                        Image(systemName: "magnifyingglass")
                            .font(.title3)
                            .foregroundColor(.white)
                    }
                    
                    NavigationLink(destination: ProfileView()) {
                        Image(systemName: "person.circle.fill")
                            .font(.title2)
                            .foregroundColor(.white)
                    }
                }
            }
        }
    }
    
    // Main content
    private var mainContent: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 20) {
                headerSection
                progressSection
                quickActionsSection
                todayTasksSection
                upcomingEventsPreview
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
            .sheet(isPresented: $showingEvents) {
                EventsView()
                    .presentedModally(true)
                    .environmentObject(sessionManager)
                    .environmentObject(eventVM)
            }
            .sheet(isPresented: $showingAddTask) {
                AddTaskView()
                    .environmentObject(sessionManager)
                    .environmentObject(taskVM)
            }
            .sheet(isPresented: $showingAddEvent) {
                // Add your event creation view here
                AddEventView()
                    .environmentObject(sessionManager)
                    .environmentObject(eventVM)
            }
            .onAppear {
                // Fetch data when view appears
                fetchTomorrowsEvents()
                updateTaskStats()
                fetchWeatherData()
                fetchDailyQuote()
                
                // Schedule notifications for events
                NotificationManager.shared.scheduleAllEventNotifications(events: eventVM.events)
            }
            .onChange(of: taskVM.tasks) { _ in
                // Update task statistics when task list changes
                updateTaskStats()
            }
        }
        .preferredColorScheme(.dark)
    }
    
    // Computed properties and helper methods
    
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
    
    // Weather icon based on condition
    private var weatherIcon: String {
        switch weatherCondition.lowercased() {
        case "sunny", "clear":
            return "sun.max.fill"
        case "cloudy", "partly cloudy":
            return "cloud.sun.fill"
        case "rainy", "rain":
            return "cloud.rain.fill"
        case "snowy", "snow":
            return "cloud.snow.fill"
        case "stormy", "thunderstorm":
            return "cloud.bolt.fill"
        default:
            return "sun.max.fill"
        }
    }
    
    // Method to fetch tomorrow's events
    private func fetchTomorrowsEvents() {
        guard !isLoadingEvents else { return }
        
        isLoadingEvents = true
        lastFilterTime = Date()
        
        let calendar = Calendar.current
        let now = Date()
        guard let tomorrow = calendar.date(byAdding: .day, value: 1, to: now) else {
            isLoadingEvents = false
            return
        }
        
        // Use eventsForDate method to get all tomorrow's events
        let allTomorrowEvents = eventVM.eventsForDate(tomorrow)
        let sortedEvents = allTomorrowEvents.sorted { $0.startDate < $1.startDate }
        
        // Deduplicate by name
        var namesSet = Set<String>()
        var uniqueEvents: [EventItem] = []
        
        for event in sortedEvents {
            if !namesSet.contains(event.name) {
                namesSet.insert(event.name)
                uniqueEvents.append(event)
            }
        }
        
        tomorrowsEvents = uniqueEvents
        isLoadingEvents = false
    }
    
    // Mock method to fetch weather data
    // In production, integrate with a real weather API
    private func fetchWeatherData() {
        // Weather conditions could be: sunny, cloudy, rainy, etc.
        let conditions = ["sunny", "cloudy", "partly cloudy", "rainy"]
        weatherCondition = conditions.randomElement() ?? "sunny"
        temperature = Int.random(in: 65...85)
    }
    
    // Mock method to fetch daily quote
    // In production, integrate with a quotes API
    private func fetchDailyQuote() {
        let quotes = [
            ("The secret of getting ahead is getting started.", "Mark Twain"),
            ("It always seems impossible until it's done.", "Nelson Mandela"),
            ("Don't watch the clock; do what it does. Keep going.", "Sam Levenson"),
            ("The future depends on what you do today.", "Mahatma Gandhi"),
            ("The only way to do great work is to love what you do.", "Steve Jobs")
        ]
        
        let selectedQuote = quotes.randomElement() ?? ("The best way to predict the future is to create it.", "Abraham Lincoln")
        quote = selectedQuote.0
        quoteAuthor = selectedQuote.1
    }
}

// MARK: - Color Extension
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
            .environmentObject(SessionManager())
            .environmentObject(TaskViewModel())
            .environmentObject(EventViewModel())
            .preferredColorScheme(.dark)
    }
}
