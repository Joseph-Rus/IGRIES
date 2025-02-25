//import Speech
//import AVFoundation
//
//class SpeechManager: ObservableObject {
//    @Published var isRecording = false
//    @Published var transcribedText = ""
//    @Published var errorMessage: String?
//    
//    private let audioEngine = AVAudioEngine()
//    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))
//    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
//    private var recognitionTask: SFSpeechRecognitionTask?
//    private var accumulatedTranscription = ""
//    private var isCleaningUp = false // Prevent overlapping start/stop
//    
//    // Maximum transcription length (optional, adjust as needed)
//    private let maxTranscriptionLength = 10000 // Characters
//    
//    init() {
//        requestPermissions()
//    }
//    
//    func requestPermissions() {
//        SFSpeechRecognizer.requestAuthorization { [weak self] status in
//            DispatchQueue.main.async {
//                switch status {
//                case .authorized:
//                    print("Speech recognition authorized")
//                case .denied:
//                    self?.errorMessage = "Speech recognition denied. Please enable it in Settings > Privacy > Speech Recognition."
//                case .restricted:
//                    self?.errorMessage = "Speech recognition is restricted on this device."
//                case .notDetermined:
//                    self?.errorMessage = "Speech recognition authorization not determined."
//                @unknown default:
//                    self?.errorMessage = "Unknown speech recognition authorization status."
//                }
//            }
//        }
//        
//        AVAudioSession.sharedInstance().requestRecordPermission { [weak self] granted in
//            DispatchQueue.main.async {
//                if granted {
//                    print("Microphone access granted")
//                } else {
//                    self?.errorMessage = "Microphone access denied. Please enable it in Settings > Privacy > Microphone."
//                }
//            }
//        }
//    }
//    
//    func startRecording() {
//        guard !isRecording, !isCleaningUp else {
//            print("Already recording or cleaning up")
//            return
//        }
//        
//        guard let recognizer = speechRecognizer, recognizer.isAvailable else {
//            errorMessage = "Speech recognition is not available. Please check your internet connection or device settings."
//            print("Speech recognizer unavailable")
//            return
//        }
//        
//        let speechAuthStatus = SFSpeechRecognizer.authorizationStatus()
//        let micAuthStatus = AVAudioSession.sharedInstance().recordPermission
//        guard speechAuthStatus == .authorized, micAuthStatus == .granted else {
//            errorMessage = "Required permissions not granted. Please enable Speech Recognition and Microphone in Settings."
//            print("Permissions not granted - Speech: \(speechAuthStatus.rawValue), Mic: \(micAuthStatus.rawValue)")
//            return
//        }
//        
//        accumulatedTranscription = ""
//        transcribedText = ""
//        errorMessage = nil
//        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
//        guard let request = recognitionRequest else {
//            errorMessage = "Failed to initialize speech recognition."
//            print("Failed to create recognition request")
//            return
//        }
//        
//        let supportedLocales = SFSpeechRecognizer.supportedLocales()
//        let isOnDeviceSupported = supportedLocales.contains(Locale(identifier: "en-US"))
//        request.requiresOnDeviceRecognition = isOnDeviceSupported
//        request.shouldReportPartialResults = true
//        request.taskHint = .dictation
//        
//        let audioSession = AVAudioSession.sharedInstance()
//        do {
//            try audioSession.setCategory(.record, mode: .measurement, options: [])
//            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
//            print("Audio session activated")
//        } catch {
//            errorMessage = "Failed to set up audio session. Please try again."
//            print("Failed to set up audio session: \(error.localizedDescription)")
//            return
//        }
//        
//        let inputNode = audioEngine.inputNode
//        inputNode.removeTap(onBus: 0)
//        let recordingFormat = inputNode.outputFormat(forBus: 0)
//        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
//            request.append(buffer)
//        }
//        
//        audioEngine.prepare()
//        do {
//            try audioEngine.start()
//            isRecording = true
//            print("Recording started successfully")
//        } catch {
//            errorMessage = "Failed to start recording. Please check your microphone."
//            print("Audio engine failed to start: \(error.localizedDescription)")
//            isRecording = false
//            cleanup()
//            return
//        }
//        
//        recognitionTask = recognizer.recognitionTask(with: request) { [weak self] result, error in
//            guard let self = self else { return }
//            
//            if let error = error {
//                let nsError = error as NSError
//                print("Recognition error: \(error.localizedDescription), Domain: \(nsError.domain), Code: \(nsError.code)")
//                if nsError.domain == "kAFAssistantErrorDomain" && nsError.code == 1101 {
//                    self.errorMessage = "Local speech recognition failed. Ensure Dictation is enabled in Settings > General > Keyboard."
//                } else {
//                    self.errorMessage = "Speech recognition error: \(error.localizedDescription)"
//                }
//                _ = self.stopRecording()
//                return
//            }
//            
//            if let result = result {
//                DispatchQueue.main.async {
//                    let newText = result.bestTranscription.formattedString
//                    if !newText.isEmpty && self.accumulatedTranscription.count < self.maxTranscriptionLength {
//                        let addition = (self.accumulatedTranscription.isEmpty ? "" : " ") + newText
//                        if (self.accumulatedTranscription.count + addition.count) <= self.maxTranscriptionLength {
//                            self.accumulatedTranscription += addition
//                            self.transcribedText = self.accumulatedTranscription
//                            print("Live transcription update: \(self.transcribedText)")
//                        } else {
//                            self.errorMessage = "Transcription limit reached. Stopping recording."
//                            _ = self.stopRecording()
//                        }
//                    }
//                }
//            }
//        }
//    }
//    
//    func stopRecording() -> String {
//        guard isRecording else { return transcribedText }
//        
//        isCleaningUp = true
//        isRecording = false
//        audioEngine.stop()
//        recognitionRequest?.endAudio()
//        
//        if recognitionRequest?.requiresOnDeviceRecognition ?? false {
//            recognitionTask?.finish()
//        } else {
//            recognitionTask?.cancel()
//        }
//        
//        audioEngine.inputNode.removeTap(onBus: 0)
//        
//        do {
//            try AVAudioSession.sharedInstance().setActive(false)
//            print("Audio session deactivated")
//        } catch {
//            errorMessage = "Failed to deactivate audio session: \(error.localizedDescription)"
//            print("Failed to deactivate audio session: \(error.localizedDescription)")
//        }
//        
//        let finalTranscription = transcribedText.trimmingCharacters(in: .whitespacesAndNewlines)
//        cleanup()
//        isCleaningUp = false
//        print("Stopped recording, final transcription: \(finalTranscription)")
//        return finalTranscription
//    }
//    
//    private func cleanup() {
//        recognitionRequest = nil
//        recognitionTask = nil
//        print("Cleaned up recognition resources")
//    }
//}
