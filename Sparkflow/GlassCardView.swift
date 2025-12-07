import SwiftUI

struct GlassCardView: View {
    let note: Note
    
    // Format date like "Dec 6"
    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        return formatter.string(from: note.createdAt)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Top Row: Tags + Date
            HStack(alignment: .top) {
                // Tags Pills with colored backgrounds
                HStack(spacing: 6) {
                    ForEach(note.tags.prefix(2), id: \.self) { tag in
                        Text(tag.uppercased())
                            .font(.system(size: 9, weight: .bold))
                            .tracking(0.5)
                            .foregroundColor(Theme.textPrimary.opacity(0.9))
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(
                                RoundedRectangle(cornerRadius: 6)
                                    .fill(Theme.tagColor(for: tag))
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 6)
                                    .stroke(Theme.tagBorderColor(for: tag), lineWidth: 1)
                            )
                    }
                }
                
                Spacer()
                
                // Date
                Text(formattedDate)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(Theme.textMuted)
            }
            .padding(.bottom, 16)
            
            // Title
            Text(note.title)
                .font(.custom("PlayfairDisplay-Regular", size: 20))
                .foregroundColor(Theme.textPrimary)
                .lineLimit(2)
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.bottom, 8)
            
            // Content Preview
            Text(note.content)
                .font(.custom("PlayfairDisplay-Regular", size: 14))
                .italic()
                .foregroundColor(Theme.textSecondary)
                .lineLimit(3)
                .lineSpacing(4)
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            Spacer(minLength: 16)
        }
        .padding(20)
        .frame(minHeight: 180)
        .frame(maxWidth: .infinity)
        .background(
            ZStack {
                // The Liquid Glass Effect
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .fill(.ultraThinMaterial)
                
                // Gradient overlay for depth
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(hex: "44403c").opacity(0.25),
                                Color(hex: "292524").opacity(0.35)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                
                // Subtle top reflection
                VStack {
                    LinearGradient(
                        colors: [Color.white.opacity(0.06), Color.clear],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .frame(height: 80)
                    Spacer()
                }
                .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
            }
        )
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(
                    LinearGradient(
                        colors: [
                            .white.opacity(0.12),
                            .white.opacity(0.04),
                            .white.opacity(0.02),
                            .white.opacity(0.06)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
        )
        .shadow(color: Color.black.opacity(0.2), radius: 12, x: 0, y: 8)
    }
}

struct GlassCardView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Theme.backgroundMesh
            VStack(spacing: 16) {
                GlassCardView(note: sampleNotes[0])
                GlassCardView(note: sampleNotes[1])
            }
            .padding()
        }
    }
}
