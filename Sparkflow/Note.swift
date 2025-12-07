import Foundation
import SwiftUI

struct Note: Identifiable, Codable {
    var id: String = UUID().uuidString
    var title: String
    var content: String
    var tags: [String]
    var createdAt: Date
    var theme: String?
}

struct TagColors {
    static let colors: [String: Color] = [
        "inspiration": Color(red: 0.6, green: 0.4, blue: 0.2), // bg-amber-900/40
        "quote": Color(white: 0.4), // bg-stone-700/50
        "idea": Color(red: 0.7, green: 0.3, blue: 0.1), // bg-orange-900/30
        "journal": Color(red: 0.6, green: 0.2, blue: 0.3), // bg-rose-900/30
        "dream": Color(red: 0.2, green: 0.2, blue: 0.6), // bg-indigo-900/30
        "stoicism": Color(white: 0.3), // bg-slate-700/50
        "design": Color(white: 0.5), // bg-neutral-700/50
        "default": Color(white: 1.0).opacity(0.05) // bg-white/5
    ]

    static func color(for tag: String) -> Color {
        return colors[tag.lowercased()] ?? colors["default"]!
    }
}
