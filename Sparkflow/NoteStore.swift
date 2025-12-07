import Foundation
import Combine

@MainActor
class NoteStore: ObservableObject {
    @Published var notes: [Note] = []

    private static func fileURL() throws -> URL {
        try FileManager.default.url(for: .documentDirectory,
                                       in: .userDomainMask,
                                       appropriateFor: nil,
                                       create: false)
            .appendingPathComponent("notes.data")
    }

    func load() {
        do {
            let fileURL = try Self.fileURL()
            let data = try Data(contentsOf: fileURL)
            notes = try JSONDecoder().decode([Note].self, from: data)
            notes.sort { $0.createdAt > $1.createdAt } // Sort by most recent first
        } catch {
            // If loading fails, use sample data and sort them
            notes = sampleNotes
            notes.sort { $0.createdAt > $1.createdAt }
        }
    }

    func save() {
        do {
            let fileURL = try Self.fileURL()
            let data = try JSONEncoder().encode(notes)
            try data.write(to: fileURL, options: [.atomic, .completeFileProtection])
        } catch {
            print("Unable to save notes: \(error.localizedDescription)")
        }
    }
}

let sampleNotes = [
    Note(title: "On the Shortness of Life", content: "It is not that we have a short time to live, but that we waste a lot of it.", tags: ["stoicism", "quote"], createdAt: Date()),
    Note(title: "Design Principle", content: "Form follows function.", tags: ["design", "inspiration"], createdAt: Date()),
    Note(title: "My Great Idea", content: "A mobile app that helps you organize your thoughts and inspirations.", tags: ["idea"], createdAt: Date()),
]



