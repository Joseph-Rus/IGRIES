import Foundation

class ICSParser {
    func fetchAndParseICS(from urlString: String, completion: @escaping ([EventItem]) -> Void) {
        guard let url = URL(string: urlString) else {
            completion([])
            return
        }
        URLSession.shared.dataTask(with: url) { data, response, error in
            var events: [EventItem] = []
            if let data = data, let icsContent = String(data: data, encoding: .utf8) {
                events = self.parseICS(icsContent: icsContent)
            }
            DispatchQueue.main.async {
                completion(events)
            }
        }.resume()
    }
    
    func parseICS(icsContent: String) -> [EventItem] {
        var events: [EventItem] = []
        let lines = icsContent.components(separatedBy: "\n")
        var currentEvent: [String: String] = [:]
        var lastKey: String? = nil
        var isEvent = false
        var seenEvents = Set<String>() // deduplication key: uid + "_" + dtStart
        
        for rawLine in lines {
            let trimmedLine = rawLine.trimmingCharacters(in: .whitespacesAndNewlines)
            if trimmedLine == "BEGIN:VEVENT" {
                isEvent = true
                currentEvent = [:]
                lastKey = nil
            } else if trimmedLine == "END:VEVENT" {
                isEvent = false
                lastKey = nil
                guard let summary = currentEvent["SUMMARY"],
                      let dtStart = currentEvent["DTSTART"] else { continue }
                let uid = currentEvent["UID"] ?? summary
                let dedupeKey = uid + "_" + dtStart
                if seenEvents.contains(dedupeKey) {
                    continue
                } else {
                    seenEvents.insert(dedupeKey)
                }
                let formatter = DateFormatter()
                var startDate: Date?
                if dtStart.contains("Z") {
                    formatter.dateFormat = "yyyyMMdd'T'HHmmss'Z'"
                    formatter.timeZone = TimeZone(abbreviation: "UTC")
                    startDate = formatter.date(from: dtStart)
                } else {
                    formatter.dateFormat = "yyyyMMdd'T'HHmmss"
                    formatter.timeZone = TimeZone.current
                    startDate = formatter.date(from: dtStart)
                }
                guard let validDate = startDate else { continue }
                let event = EventItem(
                    userId: "blackboard",
                    name: summary,
                    description: currentEvent["DESCRIPTION"] ?? "",
                    startDate: validDate,
                    repeatInterval: nil,
                    uid: currentEvent["UID"]
                )
                events.append(event)
            } else if isEvent {
                if trimmedLine.first == " " {
                    if let key = lastKey, let lastValue = currentEvent[key] {
                        currentEvent[key] = lastValue + trimmedLine
                    }
                } else if let colonIndex = trimmedLine.firstIndex(of: ":") {
                    let keyWithParams = String(trimmedLine[..<colonIndex])
                    let keyComponents = keyWithParams.components(separatedBy: ";")
                    let key = keyComponents.first ?? keyWithParams
                    let value = String(trimmedLine[trimmedLine.index(after: colonIndex)...])
                    currentEvent[key] = value
                    lastKey = key
                }
            }
        }
        return events
    }
}
