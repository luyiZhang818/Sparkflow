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
            HStack(alignment: .top, spacing: 12) {
                // Tags Pills with colored backgrounds - All tags with horizontal scroll
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
                
                // Date - fixed on the right
                Text(formattedDate)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(Theme.textMuted)
                    .fixedSize()
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
        .liquidGlass(cornerRadius: 24, intensity: 0.85)
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
