import SwiftUI

struct FeaturedNoteView: View {
    let note: Note
    @State private var displayedQuote: String = ""
    
    private func getRandomSentence() -> String {
        let sentences = note.content.components(separatedBy: CharacterSet(charactersIn: ".?!"))
        let validSentences = sentences.filter { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
        let sentence = validSentences.randomElement()?.trimmingCharacters(in: .whitespacesAndNewlines) ?? note.content
        // Truncate if too long
        if sentence.count > 180 {
            return String(sentence.prefix(180)) + "..."
        }
        return sentence
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
                
                Image(systemName: "quote.opening")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
            }
            .padding(.bottom, 24)
            
            // Quote Content
            Text("\"\(displayedQuote)\"")
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
            
            // Source Label - Uppercase tracking
            Text(note.title.uppercased())
                .font(.system(size: 11, weight: .bold))
                .tracking(2)
                .foregroundColor(Theme.accent)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity, alignment: .center)
            
            Spacer()
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 28)
        .frame(minHeight: 280)
        .frame(maxWidth: .infinity)
        .background(
            ZStack {
                // The Liquid Glass Effect
                RoundedRectangle(cornerRadius: 32, style: .continuous)
                    .fill(.ultraThinMaterial)
                
                // Subtle gradient overlay
                RoundedRectangle(cornerRadius: 32, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(hex: "44403c").opacity(0.3),
                                Color(hex: "292524").opacity(0.4)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                
                // Top reflection
                VStack {
                    RoundedRectangle(cornerRadius: 32, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [Color.white.opacity(0.08), Color.clear],
                                startPoint: .top,
                                endPoint: .center
                            )
                        )
                        .frame(height: 140)
                    Spacer()
                }
                .clipShape(RoundedRectangle(cornerRadius: 32, style: .continuous))
            }
        )
        .overlay(
            RoundedRectangle(cornerRadius: 32, style: .continuous)
                .stroke(
                    LinearGradient(
                        colors: [
                            .white.opacity(0.15),
                            .white.opacity(0.05),
                            .white.opacity(0.02),
                            .white.opacity(0.08)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
        )
        .shadow(color: Color.black.opacity(0.25), radius: 20, x: 0, y: 12)
        .onAppear {
            displayedQuote = getRandomSentence()
        }
    }
}

struct FeaturedNoteView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Theme.backgroundMesh
            FeaturedNoteView(note: sampleNotes[0])
                .padding()
        }
    }
}

