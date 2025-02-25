import SwiftUI

struct AddTaskView: View {
    @EnvironmentObject var sessionManager: SessionManager
    @EnvironmentObject var taskVM: TaskViewModel
    @Environment(\.dismiss) var dismiss
    
    @State private var title = ""
    @State private var description = ""
    @State private var dueDate = Date()
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.knightGray
                    .ignoresSafeArea()
                VStack(spacing: 20) {
                    Text("New Task")
                        .font(.largeTitle)
                        .foregroundColor(.black)
                        .bold()
                    
                    TextField("Task Title", text: $title)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(8)
                        .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.black, lineWidth: 1))
                    
                    TextField("Description", text: $description)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(8)
                        .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.black, lineWidth: 1))
                    
                    DatePicker("Due Date", selection: $dueDate, displayedComponents: [.date, .hourAndMinute])
                        .datePickerStyle(.compact)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(8)
                    
                    Button(action: { addNewTask() }) {
                        Text("Add Task")
                            .fontWeight(.semibold)
                            .foregroundColor(.black)
                            .padding()
                            .frame(maxWidth: 250)
                            .background(Color.babyblue)
                            .cornerRadius(10)
                            .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.black, lineWidth: 1))
                    }
                    
                    Button(action: { dismiss() }) {
                        Text("Cancel")
                            .fontWeight(.semibold)
                            .foregroundColor(.black)
                            .padding()
                            .frame(maxWidth: 250)
                            .background(Color.white)
                            .cornerRadius(10)
                            .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.black, lineWidth: 1))
                    }
                }
                .padding()
            }
        }
    }
    
    func addNewTask() {
        guard let userId = sessionManager.currentUserId else { return }
        let newTask = TaskItem(
            id: nil,
            userId: userId,
            title: title,
            description: description,
            dueDate: dueDate,
            isComplete: false
        )
        taskVM.addTask(newTask)
        dismiss()
    }
}
