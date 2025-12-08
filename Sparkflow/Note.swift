import Foundation
import SwiftUI

// MARK: - Bullet Model
struct Bullet: Identifiable, Codable, Equatable {
    var id: String = UUID().uuidString
    var text: String
    var timestamp: Date
    
    init(text: String, timestamp: Date = Date()) {
        self.text = text
        self.timestamp = timestamp
    }
}

// MARK: - Note Model (Spark-Based)
struct Note: Identifiable, Codable {
    var id: String = UUID().uuidString
    var spark: String                    // Required - the core idea/quote
    var source: String?                  // Optional - where it came from
    var tags: [String]
    var bullets: [Bullet]                // Timestamped reflections (append-only)
    var createdAt: Date
    var theme: String?
    
    // Convenience initializer for creating a new note with initial bullet
    init(
        id: String = UUID().uuidString,
        spark: String,
        source: String? = nil,
        tags: [String],
        initialBullet: String,
        createdAt: Date = Date(),
        theme: String? = nil
    ) {
        self.id = id
        self.spark = spark
        self.source = source
        self.tags = tags
        self.bullets = [Bullet(text: initialBullet, timestamp: createdAt)]
        self.createdAt = createdAt
        self.theme = theme
    }
    
    // Full initializer with bullets array
    init(
        id: String = UUID().uuidString,
        spark: String,
        source: String? = nil,
        tags: [String],
        bullets: [Bullet],
        createdAt: Date = Date(),
        theme: String? = nil
    ) {
        self.id = id
        self.spark = spark
        self.source = source
        self.tags = tags
        self.bullets = bullets
        self.createdAt = createdAt
        self.theme = theme
    }
    
    // Number of reflections/bullets
    var bulletCount: Int {
        bullets.count
    }
}

// MARK: - Tag Colors
struct TagColors {
    static let colors: [String: Color] = [
        "inspiration": Color(red: 0.6, green: 0.4, blue: 0.2), // bg-amber-900/40
        "quote": Color(white: 0.4), // bg-stone-700/50
        "idea": Color(red: 0.7, green: 0.3, blue: 0.1), // bg-orange-900/30
        "journal": Color(red: 0.6, green: 0.2, blue: 0.3), // bg-rose-900/30
        "dream": Color(red: 0.2, green: 0.2, blue: 0.6), // bg-indigo-900/30
        "stoicism": Color(white: 0.3), // bg-slate-700/50
        "design": Color(white: 0.5), // bg-neutral-700/50
        "philosophy": Color(red: 0.4, green: 0.3, blue: 0.5), // purple-ish
        "creativity": Color(red: 0.8, green: 0.4, blue: 0.3), // warm coral
        "mindfulness": Color(red: 0.3, green: 0.5, blue: 0.4), // teal
        "default": Color(white: 1.0).opacity(0.05) // bg-white/5
    ]

    static func color(for tag: String) -> Color {
        return colors[tag.lowercased()] ?? colors["default"]!
    }
}
