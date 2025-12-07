//
//  Theme.swift
//  Sparkflow
//
//  Created by Luyi Zhang on 12/6/25.
//
//  Adopting Liquid Glass design from Apple's documentation:
//  https://developer.apple.com/documentation/technologyoverviews/adopting-liquid-glass


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

// MARK: - Liquid Glass View Modifier
// Custom implementation based on Apple's Liquid Glass design language
struct LiquidGlassModifier: ViewModifier {
    var cornerRadius: CGFloat = 24
    var tint: Color = .clear
    var intensity: Double = 1.0
    
    func body(content: Content) -> some View {
        content
            .background(
                ZStack {
                    // Base glass layer with blur
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .fill(.ultraThinMaterial)
                        .opacity(0.7 * intensity)
                    
                    // Tint layer
                    if tint != .clear {
                        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                            .fill(tint.opacity(0.1 * intensity))
                    }
                    
                    // Specular highlight - top edge reflection
                    VStack(spacing: 0) {
                        LinearGradient(
                            colors: [
                                .white.opacity(0.25 * intensity),
                                .white.opacity(0.08 * intensity),
                                .clear
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                        .frame(height: cornerRadius * 3)
                        Spacer()
                    }
                    .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
                }
            )
            // Liquid border with gradient
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(
                        LinearGradient(
                            colors: [
                                .white.opacity(0.5 * intensity),
                                .white.opacity(0.15 * intensity),
                                .white.opacity(0.05 * intensity),
                                .white.opacity(0.2 * intensity)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            )
            // Soft shadow for depth
            .shadow(color: .black.opacity(0.2 * intensity), radius: 16, x: 0, y: 8)
    }
}

// MARK: - Glass Button Style
struct LiquidGlassButtonStyle: ButtonStyle {
    var tint: Color = .clear
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .opacity(configuration.isPressed ? 0.8 : 1.0)
            .animation(.easeInOut(duration: 0.15), value: configuration.isPressed)
    }
}

// MARK: - View Extension for Liquid Glass
extension View {
    func liquidGlass(
        cornerRadius: CGFloat = 24,
        tint: Color = .clear,
        intensity: Double = 1.0
    ) -> some View {
        self.modifier(LiquidGlassModifier(
            cornerRadius: cornerRadius,
            tint: tint,
            intensity: intensity
        ))
    }
    
    func liquidGlassCard() -> some View {
        self.modifier(LiquidGlassModifier(cornerRadius: 24, intensity: 0.8))
    }
    
    func liquidGlassPanel() -> some View {
        self.modifier(LiquidGlassModifier(cornerRadius: 20, intensity: 0.6))
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
    
    // The ambient background mesh - Warm orange/brown gradient (fallback)
    static var backgroundMesh: some View {
        ZStack {
            // Base warm gradient - lighter tones
            LinearGradient(
                colors: [
                    Color(hex: "2d1f1a"),  // Warm dark brown
                    Color(hex: "1a1210"),  // Deep warm black
                    Color(hex: "181010")   // Bottom dark
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            // Large ambient glow - top left (warm orange)
            RadialGradient(
                colors: [Color(hex: "c2410c").opacity(0.25), .clear],
                center: .topLeading,
                startRadius: 0,
                endRadius: 500
            )
            .ignoresSafeArea()
            
            // Secondary glow - top right (amber)
            RadialGradient(
                colors: [Color(hex: "b45309").opacity(0.18), .clear],
                center: UnitPoint(x: 0.8, y: 0.1),
                startRadius: 0,
                endRadius: 400
            )
            .ignoresSafeArea()
            
            // Bottom accent glow
            RadialGradient(
                colors: [Color(hex: "78350f").opacity(0.15), .clear],
                center: .bottomTrailing,
                startRadius: 0,
                endRadius: 450
            )
            .ignoresSafeArea()
            
            // Subtle noise/texture overlay
            Rectangle()
                .fill(Color.white.opacity(0.015))
                .ignoresSafeArea()
        }
    }
    
    // Dashboard background with image
    static var dashboardBackground: some View {
        GeometryReader { geometry in
            Image("DashboardBackground")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: geometry.size.width, height: geometry.size.height)
                .clipped()
        }
        .ignoresSafeArea()
    }
}