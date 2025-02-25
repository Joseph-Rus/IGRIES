import SwiftUI

struct MinimalSpeechView: View {
    @EnvironmentObject var sessionManager: SessionManager
    @EnvironmentObject var taskVM: TaskViewModel
    @EnvironmentObject var eventVM: EventViewModel
    
    @StateObject private var speechManager = IGRISSpeechManager()
    @State private var showingTasks = false
    @State private var showingEvents = false
    @State private var pdfURL: URL?
    @State private var saveMessage: String?
    @State private var showingSavePicker = false
    @State private var isProcessing = false
    @State private var showWelcomeMessage = true
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.knightGray
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    if showWelcomeMessage && !speechManager.isRecording {
                        Text("Welcome to IGRIS, \(sessionManager.currentUserName ?? "User")!")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .transition(.opacity)
                    }
                    
                    if !speechManager.transcribedText.isEmpty {
                        ScrollView {
                            Text(speechManager.isRecording ? "Live Transcription: \(speechManager.transcribedText)" : "Final Transcription: \(speechManager.transcribedText)")
                                .font(.subheadline)
                                .foregroundColor(.white)
                                .padding()
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .lineLimit(nil)
                        }
                        .frame(maxHeight: .infinity)
                    }
                    
                    if isProcessing {
                        Text("Processing transcription and generating detailed notes PDF...")
                            .font(.subheadline)
                            .foregroundColor(.white)
                            .padding()
                    }
                    
                    if let message = saveMessage {
                        Text(message)
                            .font(.subheadline)
                            .foregroundColor(.white)
                            .padding()
                    }
                    
                    if let error = speechManager.errorMessage {
                        Text(error)
                            .font(.subheadline)
                            .foregroundColor(.red)
                            .padding()
                            .multilineTextAlignment(.center)
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        if speechManager.isRecording {
                            isProcessing = true
                            let transcription = speechManager.stopRecording()
                            if !transcription.isEmpty {
                                processTranscriptionAndGeneratePDF(
                                    transcription: transcription,
                                    email: sessionManager.currentUserEmail,
                                    apiKey: UserDefaults.standard.string(forKey: "OpenAIAPIKey"),
                                    onSuccess: { url in
                                        pdfURL = url
                                        showingSavePicker = true
                                        saveMessage = "PDF generated with detailed structured notes"
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                                            saveMessage = nil
                                            isProcessing = false
                                        }
                                    },
                                    onFailure: { errorMessage in
                                        saveMessage = errorMessage
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                                            saveMessage = nil
                                            isProcessing = false
                                        }
                                    }
                                )
                            } else {
                                saveMessage = "No transcription captured"
                                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                                    saveMessage = nil
                                    isProcessing = false
                                }
                            }
                        } else {
                            showWelcomeMessage = false
                            speechManager.startRecording()
                        }
                    }) {
                        Image(systemName: "mic.fill")
                            .font(.system(size: 24))
                            .foregroundColor(.white)
                            .frame(width: 60, height: 60)
                            .background(speechManager.isRecording ? Color.red : Color.blue)
                            .clipShape(Circle())
                            .overlay(
                                Circle()
                                    .stroke(Color.white, lineWidth: 2)
                            )
                    }
                    .padding()
                }
                .background(Color.knightGray)
            }
            .toolbarBackground(.knightGray, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Menu {
                        Button("Tasks") { showingTasks = true }
                        Button("Events") { showingEvents = true }
                        Button("Settings", action: {})
                    } label: {
                        Image(systemName: "line.horizontal.3")
                            .font(.title2)
                            .foregroundColor(.black)
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink(destination: ProfileView()) {
                        Image(systemName: "person.circle.fill")
                            .font(.title2)
                            .foregroundColor(.black)
                    }
                }
            }
            .sheet(isPresented: $showingTasks) {
                TasksView()
                    .environmentObject(sessionManager)
                    .environmentObject(taskVM)
            }
            .sheet(isPresented: $showingEvents) {
                EventsView()
                    .environmentObject(sessionManager)
                    .environmentObject(eventVM)
            }
            .fileExporter(
                isPresented: $showingSavePicker,
                document: pdfURL.map { PDFDocument(url: $0) },
                contentType: .pdf,
                defaultFilename: "DetailedNotes_\(Date().timeIntervalSince1970)"
            ) { result in
                switch result {
                case .success(let url):
                    saveMessage = "PDF saved to: \(url.lastPathComponent)"
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                        saveMessage = nil
                        isProcessing = false
                    }
                case .failure(let error):
                    saveMessage = "Error saving PDF: \(error.localizedDescription)"
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                        saveMessage = nil
                        isProcessing = false
                    }
                }
            }
            .onAppear {
                if let userId = sessionManager.currentUserId {
                    eventVM.fetchEvents(for: userId)
                    taskVM.fetchTasks(for: userId)
                }
                showWelcomeMessage = true
            }
        }
    }
}

struct MinimalSpeechView_Previews: PreviewProvider {
    static var previews: some View {
        MinimalSpeechView()
            .environmentObject(SessionManager())
            .environmentObject(TaskViewModel())
            .environmentObject(EventViewModel())
    }
}
