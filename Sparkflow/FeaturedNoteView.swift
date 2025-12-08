import SwiftUI

struct FeaturedNoteView: View {
    let note: Note

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
            Text("\"\(note.spark)\"")
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
            if let source = note.source, !source.isEmpty {
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
            Text("Tap to revisit this spark")
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
                // With source
                FeaturedNoteView(note: sampleNotes[0])
                    .padding()
                
                // Without source
                FeaturedNoteView(note: sampleNotes[2])
                    .padding()
            }
        }
    }
}
