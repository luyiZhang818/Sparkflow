//
//  Theme.swift
//  Sparkflow
//
//  Created by Luyi Zhang on 12/6/25.
//


import SwiftUI

// Extension to handle Hex colors easily
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

struct Theme {
    // Core Colors
    static let bgDark = Color(hex: "0c0a09") // Warm Black
    static let bgWarm = Color(hex: "1c1917") // Warm dark gray
    static let paper = Color(hex: "FFFCF0")  // Warm off-white paper
    static let paperLines = Color(hex: "E5E5E0") // Subtle line color
    
    // Accent Colors
    static let accent = Color(hex: "D97706") // Amber/Orange accent
    static let accentLight = Color(hex: "F59E0B") // Lighter amber
    static let accentGlow = Color(hex: "92400E") // Deep amber for shadows
    
    // Text Colors
    static let textPrimary = Color(hex: "f5f5f4") // Warm white
    static let textSecondary = Color(hex: "a8a29e") // Stone gray
    static let textMuted = Color(hex: "78716c") // Muted stone
    static let textDark = Color(hex: "2A1B15") // Dark brown for paper
    
    // Tag Colors (matching web app)
    static func tagColor(for tag: String) -> Color {
        switch tag.lowercased() {
        case "inspiration": return Color(hex: "92400E").opacity(0.6)
        case "quote": return Color(hex: "57534e").opacity(0.7)
        case "idea": return Color(hex: "c2410c").opacity(0.5)
        case "journal": return Color(hex: "9f1239").opacity(0.5)
        case "dream": return Color(hex: "3730a3").opacity(0.5)
        case "stoicism": return Color(hex: "374151").opacity(0.7)
        case "design": return Color(hex: "525252").opacity(0.7)
        default: return Color.white.opacity(0.1)
        }
    }
    
    static func tagBorderColor(for tag: String) -> Color {
        switch tag.lowercased() {
        case "inspiration": return Color(hex: "F59E0B").opacity(0.3)
        case "quote": return Color(hex: "a8a29e").opacity(0.3)
        case "idea": return Color(hex: "ea580c").opacity(0.3)
        case "journal": return Color(hex: "fb7185").opacity(0.3)
        case "dream": return Color(hex: "818cf8").opacity(0.3)
        case "stoicism": return Color(hex: "9ca3af").opacity(0.3)
        case "design": return Color(hex: "a3a3a3").opacity(0.3)
        default: return Color.white.opacity(0.1)
        }
    }
    
    // The "Liquid" Border Gradient
    static let glassBorder = LinearGradient(
        colors: [
            .white.opacity(0.6),
            .white.opacity(0.1),
            .white.opacity(0.05),
            .white.opacity(0.3)
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    // Subtle glass fill gradient
    static let glassFill = LinearGradient(
        colors: [
            Color(hex: "44403c").opacity(0.4),
            Color(hex: "292524").opacity(0.4)
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    // The ambient background mesh
    static var backgroundMesh: some View {
        ZStack {
            Color(hex: "1c1917").ignoresSafeArea()
            
            // Radial Glows - Warmer amber tones
            RadialGradient(colors: [Color(hex: "92400E").opacity(0.15), .clear], center: .topLeading, startRadius: 0, endRadius: 600)
                .ignoresSafeArea()
            RadialGradient(colors: [Color(hex: "78350f").opacity(0.12), .clear], center: .bottomTrailing, startRadius: 0, endRadius: 500)
                .ignoresSafeArea()
            RadialGradient(colors: [Color(hex: "451a03").opacity(0.1), .clear], center: .center, startRadius: 100, endRadius: 400)
                .ignoresSafeArea()
        }
    }
}