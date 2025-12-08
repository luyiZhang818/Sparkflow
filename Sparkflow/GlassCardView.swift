import SwiftUI

struct GlassCardView: View {
    let note: Note
    
    // Format date like "Dec 6"
    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        return formatter.string(from: note.createdAt)
    }
    
    // Number of bullets capped at 3 for display
    private var displayDotCount: Int {
        min(note.bulletCount, 3)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Top Row: Tags + Date + Bullet Dots
            HStack(alignment: .top, spacing: 12) {
                // Tags Pills with colored backgrounds
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 6) {
                        ForEach(note.tags, id: \.self) { tag in
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
                }
                
                Spacer()
                
                // Bullet Count Dots
                HStack(spacing: 4) {
                    ForEach(0..<displayDotCount, id: \.self) { _ in
                        Circle()
                            .fill(Theme.accent)
                            .frame(width: 6, height: 6)
                    }
                }
                .padding(.trailing, 4)
                
                // Date - fixed on the right
                Text(formattedDate)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(Theme.textMuted)
                    .fixedSize()
            }
            .padding(.bottom, 16)
            
            // MARK: - Spark (Primary visible text - replaces title)
            Text(note.spark)
                .font(.custom("PlayfairDisplay-Regular", size: 18))
                .foregroundColor(Theme.textPrimary)
                .lineLimit(4)
                .lineSpacing(4)
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            Spacer(minLength: 16)
            
            // MARK: - Source (if available, subtle display)
            if let source = note.source, !source.isEmpty {
                HStack(spacing: 4) {
                    Image(systemName: "link")
                        .font(.system(size: 9, weight: .medium))
                    Text(source)
                        .font(.system(size: 11, weight: .medium))
                        .lineLimit(1)
                }
                .foregroundColor(Theme.accent.opacity(0.8))
                .padding(.top, 8)
            }
        }
        .padding(20)
        .frame(minHeight: 160)
        .frame(maxWidth: .infinity)
        .liquidGlass(cornerRadius: 24, intensity: 0.85)
    }
}

// MARK: - Preview
struct GlassCardView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Theme.backgroundMesh
            VStack(spacing: 16) {
                GlassCardView(note: sampleNotes[0])
                GlassCardView(note: sampleNotes[2])
            }
            .padding()
        }
    }
}
