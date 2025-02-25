import Foundation

// If createPDF is in a separate file, import it (adjust based on your project structure)
// import PDFGenerator // Uncomment and adjust if needed

func processTranscriptionAndGeneratePDF(
    transcription: String,
    email: String?,
    apiKey: String?,
    onSuccess: @escaping (URL) -> Void,
    onFailure: @escaping (String) -> Void
) {
    guard let email = email, !email.isEmpty else {
        onFailure("No user email available")
        return
    }
    
    guard let apiKey = apiKey, !apiKey.isEmpty else {
        onFailure("No OpenAI API key set. Please set it in Profile.")
        return
    }
    
    Task {
        do {
            let detailedNotes = try await generateDetailedNotesWithGPT4(text: transcription, apiKey: apiKey)
            let pdfData = createPDF(from: transcription, email: email, detailedNotes: detailedNotes)
            let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let fileName = "DetailedNotes_\(Date().timeIntervalSince1970).pdf"
            let fileURL = documentsURL.appendingPathComponent(fileName)
            
            try pdfData.write(to: fileURL)
            onSuccess(fileURL)
        } catch {
            onFailure("Error processing transcription: \(error.localizedDescription)")
        }
    }
}

private func generateDetailedNotesWithGPT4(text: String, apiKey: String) async throws -> String {
    let openAIEndpoint = "https://api.openai.com/v1/chat/completions"
    let maxTokensPerRequest = 4000
    
    let url = URL(string: openAIEndpoint)!
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    
    let prompt = """
    Please create detailed notes from the following text. Structure the output with:
    1. A Table of Contents with section titles
    2. Clear section headers
    3. Organized content under each section
    4. Use bullet points where appropriate
    
    Text to process:
    \(text)
    """
    
    let words = text.components(separatedBy: .whitespacesAndNewlines)
    var chunks: [[String]] = []
    var currentChunk: [String] = []
    var currentLength = 0
    
    for word in words {
        let wordLength = word.count + 1
        if currentLength + wordLength <= maxTokensPerRequest / 2 {
            currentChunk.append(word)
            currentLength += wordLength
        } else {
            if !currentChunk.isEmpty {
                chunks.append(currentChunk)
            }
            currentChunk = [word]
            currentLength = wordLength
        }
    }
    if !currentChunk.isEmpty {
        chunks.append(currentChunk)
    }
    
    var fullNotes = ""
    for chunk in chunks {
        let chunkText = chunk.joined(separator: " ")
        let payload: [String: Any] = [
            "model": "gpt-4",
            "messages": [
                ["role": "system", "content": "You are a helpful assistant that creates detailed, structured notes."],
                ["role": "user", "content": prompt.replacingOccurrences(of: text, with: chunkText)]
            ],
            "max_tokens": 1000,
            "temperature": 0.3
        ]
        
        request.httpBody = try JSONSerialization.data(withJSONObject: payload)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        
        let json = try JSONSerialization.jsonObject(with: data) as! [String: Any]
        let choices = json["choices"] as! [[String: Any]]
        let message = choices[0]["message"] as! [String: Any]
        let chunkNotes = message["content"] as! String
        fullNotes += chunkNotes + "\n\n"
    }
    
    return fullNotes.trimmingCharacters(in: .whitespacesAndNewlines)
}
