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
    
    func updateNote(id: String, content: String) {
        if let index = notes.firstIndex(where: { $0.id == id }) {
            notes[index].content = content
            save()
        }
    }
    
    func updateNote(id: String, title: String? = nil, content: String? = nil, tags: [String]? = nil) {
        if let index = notes.firstIndex(where: { $0.id == id }) {
            if let title = title {
                notes[index].title = title
            }
            if let content = content {
                notes[index].content = content
            }
            if let tags = tags {
                notes[index].tags = tags
            }
            save()
        }
    }
    
    func deleteNote(id: String) {
        notes.removeAll { $0.id == id }
        save()
    }
}

let sampleNotes = [
    Note(title: "On the Shortness of Life", content: "It is not that we have a short time to live, but that we waste a lot of it.", tags: ["stoicism", "quote"], createdAt: Date()),
    Note(title: "Design Principle", content: "Form follows function.", tags: ["design", "inspiration"], createdAt: Date()),
    Note(title: "My Great Idea", content: "A mobile app that helps you organize your thoughts and inspirations.", tags: ["idea"], createdAt: Date()),
]



