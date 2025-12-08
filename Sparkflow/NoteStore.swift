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
    
    // MARK: - Add New Bullet (Append-Only)
    // This is the ONLY way to modify an existing note's reflections
    func addBullet(to noteId: String, text: String) {
        if let index = notes.firstIndex(where: { $0.id == noteId }) {
            let newBullet = Bullet(text: text, timestamp: Date())
            notes[index].bullets.append(newBullet)
            save()
        }
    }
    
    // MARK: - Delete Note
    func deleteNote(id: String) {
        notes.removeAll { $0.id == id }
        save()
    }
    
    // MARK: - Clear All Data (for fresh start)
    func clearAllData() {
        notes = []
        save()
    }
    
    // MARK: - Reset to Demo Data
    func resetToDemoData() {
        notes = sampleNotes
        notes.sort { $0.createdAt > $1.createdAt }
        save()
    }
}

// MARK: - Demo/Template Data for UI Validation
let sampleNotes: [Note] = {
    let calendar = Calendar.current
    let now = Date()
    
    // Helper to create dates in the past
    func daysAgo(_ days: Int) -> Date {
        calendar.date(byAdding: .day, value: -days, to: now) ?? now
    }
    
    func hoursAgo(_ hours: Int, from date: Date = Date()) -> Date {
        calendar.date(byAdding: .hour, value: -hours, to: date) ?? date
    }
    
    return [
        // Entry 1: Stoicism quote with multiple reflections over time
        Note(
            spark: "It is not that we have a short time to live, but that we waste a lot of it.",
            source: "Seneca, On the Shortness of Life",
            tags: ["stoicism", "quote", "philosophy"],
            bullets: [
                Bullet(text: "This hit me hard today. I spent 3 hours scrolling through social media and felt empty afterward.", timestamp: daysAgo(14)),
                Bullet(text: "Started tracking my time this week. Eye-opening how much I give to things that don't matter.", timestamp: daysAgo(7)),
                Bullet(text: "One month in — I've reclaimed about 2 hours daily. Reading more, worrying less.", timestamp: daysAgo(1))
            ],
            createdAt: daysAgo(14)
        ),
        
        // Entry 2: Design insight with evolving understanding
        Note(
            spark: "Design is not just what it looks like and feels like. Design is how it works.",
            source: "Steve Jobs",
            tags: ["design", "inspiration"],
            bullets: [
                Bullet(text: "Working on the app redesign. Need to remember this — function first, beauty follows.", timestamp: daysAgo(10)),
                Bullet(text: "User testing revealed my 'beautiful' navigation confused everyone. Back to basics.", timestamp: daysAgo(3))
            ],
            createdAt: daysAgo(10)
        ),
        
        // Entry 3: Personal idea/insight (no source)
        Note(
            spark: "The best ideas come when I stop trying to have them.",
            source: nil,
            tags: ["idea", "creativity", "mindfulness"],
            bullets: [
                Bullet(text: "Noticed this pattern while showering. My brain finally relaxes and connects dots.", timestamp: daysAgo(21)),
                Bullet(text: "Started taking walks without podcasts. Just silence. More ideas in one week than the whole month before.", timestamp: daysAgo(12)),
                Bullet(text: "Maybe productivity isn't about doing more. It's about creating space for clarity.", timestamp: daysAgo(5)),
                Bullet(text: "Read about 'diffuse mode' thinking. Science confirms what I felt intuitively.", timestamp: daysAgo(1))
            ],
            createdAt: daysAgo(21)
        ),
        
        // Entry 4: Dream/reflection
        Note(
            spark: "I dreamed of a library where every book was a life I could have lived.",
            source: nil,
            tags: ["dream", "journal"],
            bullets: [
                Bullet(text: "Woke up feeling both melancholy and free. So many paths, but this one is mine.", timestamp: daysAgo(8))
            ],
            createdAt: daysAgo(8)
        ),
        
        // Entry 5: Quote about learning
        Note(
            spark: "In the beginner's mind there are many possibilities, but in the expert's there are few.",
            source: "Shunryu Suzuki, Zen Mind, Beginner's Mind",
            tags: ["philosophy", "mindfulness", "quote"],
            bullets: [
                Bullet(text: "Starting to learn Swift. Feeling overwhelmed but also excited by not knowing.", timestamp: daysAgo(30)),
                Bullet(text: "Six months into coding — I catch myself dismissing 'naive' approaches. Must stay curious.", timestamp: daysAgo(5))
            ],
            createdAt: daysAgo(30)
        ),
        
        // Entry 6: Personal observation
        Note(
            spark: "Every person I meet knows something I don't.",
            source: "Bill Nye",
            tags: ["inspiration", "philosophy"],
            bullets: [
                Bullet(text: "Had coffee with a stranger today. Learned about bee migration patterns. Fascinating.", timestamp: daysAgo(4))
            ],
            createdAt: daysAgo(4)
        ),
        
        // Entry 7: Recent spark
        Note(
            spark: "The obstacle is the way.",
            source: "Marcus Aurelius (via Ryan Holiday)",
            tags: ["stoicism", "quote"],
            bullets: [
                Bullet(text: "Facing a major setback at work. Instead of resisting, asking: what can this teach me?", timestamp: hoursAgo(6, from: now))
            ],
            createdAt: hoursAgo(6, from: now)
        )
    ]
}()
