import SwiftUI

struct FeaturedNoteView: View {
    let note: Note?  // Optional - nil means show placeholder
    
    // Placeholder spark for zero-entry state
    private var displaySpark: String {
        note?.spark ?? "Jot down your first spark."
    }
    
    private var displaySource: String? {
        if let note = note {
            return note.source
        }
        return "Dev Team"  // Placeholder source
    }
    
    private var isPlaceholder: Bool {
        note == nil
    }

    var body: some View {
        VStack(spacing: 0) {
            Spacer()
            
            // Quote Icon - Orange Circle
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Theme.accentLight, Theme.accent],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 44, height: 44)
                    .shadow(color: Theme.accentGlow.opacity(0.4), radius: 10, x: 0, y: 4)
                
                Image(systemName: "sparkle")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white)
            }
            .padding(.bottom, 24)
            
            // MARK: - Spark Content (Primary Display)
            Text("\"\(displaySpark)\"")
                .font(.custom("PlayfairDisplay-Regular", size: 22))
                .italic()
                .foregroundColor(Theme.textPrimary)
                .multilineTextAlignment(.center)
                .lineSpacing(6)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.horizontal, 8)

            Spacer()
                .frame(height: 20)
            
            // MARK: - Source Label (Only if available)
            if let source = displaySource, !source.isEmpty {
                Text(source.uppercased())
                    .font(.system(size: 11, weight: .bold))
                    .tracking(2)
                    .foregroundColor(Theme.accent)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity, alignment: .center)
            }
            
            Spacer()
                .frame(height: 16)
            
            // MARK: - Microcopy / Call to Action
            Text(isPlaceholder ? "Tap + to capture your first thought" : "Tap to revisit this spark")
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(Theme.textMuted.opacity(0.7))
                .italic()
            
            Spacer()
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 28)
        .frame(minHeight: 280)
        .frame(maxWidth: .infinity)
        .liquidGlass(cornerRadius: 32, intensity: 1.0)
    }
}

// MARK: - Preview
struct FeaturedNoteView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Theme.backgroundMesh
            VStack(spacing: 20) {
                // Placeholder (zero entries)
                FeaturedNoteView(note: nil)
                    .padding()
                
                // With source
                FeaturedNoteView(note: sampleNotes[0])
                    .padding()
            }
        }
    }
}
