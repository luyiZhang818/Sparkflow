import SwiftUI

struct JournalView: View {
    let note: Note
    private let pages: [String]
    @Environment(\.presentationMode) var presentationMode
    @State private var currentPage = 0
    
    // Formatted date for display
    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, d MMMM yyyy"
        return formatter.string(from: note.createdAt)
    }

    init(note: Note) {
        self.note = note
        // Chunk content into pages (smaller chunks for better mobile display)
        self.pages = note.content.chunked(into: 500).map { String($0) }
    }

    var body: some View {
        ZStack {
            // Dark Background - matching Journal.png
            Color(hex: "0a0a0a").ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Custom Nav Bar
                HStack {
                    // Settings/Filter icon on right
                    Spacer()
                    
                    Button(action: { presentationMode.wrappedValue.dismiss() }) {
                        Image(systemName: "slider.horizontal.3")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(Theme.textMuted)
                            .frame(width: 40, height: 40)
                            .background(
                                Circle()
                                    .fill(Color.white.opacity(0.05))
                            )
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 12)
                
                // Date Header
                Text(formattedDate)
                    .font(.system(size: 13, weight: .regular))
                    .foregroundColor(Theme.textMuted)
                    .padding(.top, 8)
                
                // Title
                Text("Browse your dreams")
                    .font(.custom("PlayfairDisplay-Regular", size: 28))
                    .foregroundColor(Theme.textPrimary)
                    .padding(.top, 8)
                    .padding(.bottom, 24)
                
                // The Book/Page View
                TabView(selection: $currentPage) {
                    ForEach(pages.indices, id: \.self) { index in
                        JournalPageView(
                            content: pages[index],
                            date: formattedDate,
                            pageNumber: index + 1,
                            totalPages: pages.count,
                            isFirstPage: index == 0
                        )
                        .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .frame(maxHeight: .infinity)
                
                Spacer()
                    .frame(height: 20)
                
                // Search Bar at bottom
                HStack(spacing: 12) {
                    Text("Search your dreams...")
                        .font(.system(size: 14))
                        .foregroundColor(Theme.textMuted)
                    
                    Spacer()
                    
                    // AI Sparkle icon
                    Image(systemName: "sparkles")
                        .font(.system(size: 14))
                        .foregroundColor(Theme.textMuted)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 14)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.white.opacity(0.05))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.white.opacity(0.08), lineWidth: 1)
                )
                .padding(.horizontal, 24)
                .padding(.bottom, 16)
                
                // Mini Calendar Row
                CalendarRowView()
                    .padding(.horizontal, 24)
                    .padding(.bottom, 40)
            }
        }
        .navigationBarHidden(true)
        .gesture(
            DragGesture()
                .onEnded { value in
                    if value.translation.height > 100 {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
        )
    }
}

// Individual Page View - matching Journal.png paper card style
struct JournalPageView: View {
    let content: String
    let date: String
    let pageNumber: Int
    let totalPages: Int
    let isFirstPage: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Date Header on first page
            if isFirstPage {
                Text(date)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(Theme.textMuted)
                    .padding(.bottom, 16)
            }
            
            // Content - Serif italic text
            Text(content)
                .font(.custom("Georgia", size: 17))
                .lineSpacing(8)
                .foregroundColor(Theme.textDark)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            Spacer()
            
            // Footer
            HStack {
                Text("Tap to edit")
                    .font(.system(size: 12))
                    .foregroundColor(Theme.textMuted.opacity(0.6))
                
                Spacer()
                
                Text("\(pageNumber) / \(totalPages)")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(Theme.textMuted)
            }
        }
        .padding(24)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            ZStack {
                // Paper background - warm cream color
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(Color(hex: "e8e4dc"))
                
                // Subtle paper texture gradient
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.3),
                                Color.clear,
                                Color.black.opacity(0.02)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }
        )
        .overlay(
            // Subtle paper edge shadow on left (like binding)
            HStack {
                LinearGradient(
                    colors: [Color.black.opacity(0.08), Color.clear],
                    startPoint: .leading,
                    endPoint: .trailing
                )
                .frame(width: 8)
                Spacer()
            }
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        )
        .shadow(color: Color.black.opacity(0.3), radius: 20, x: 0, y: 10)
        .padding(.horizontal, 24)
    }
}

// Mini Calendar Row
struct CalendarRowView: View {
    let days = ["Mon", "Tue", "Wed", "Thur", "Fri", "Sat", "Sun"]
    let currentDayIndex = 2 // Wednesday as example (matching reference)
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(0..<7, id: \.self) { index in
                VStack(spacing: 6) {
                    Text(days[index])
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(Theme.textMuted)
                    
                    Text("\(index + 1)")
                        .font(.system(size: 12, weight: index == currentDayIndex ? .bold : .regular))
                        .foregroundColor(index == currentDayIndex ? Theme.textPrimary : Theme.textMuted)
                        .frame(width: 28, height: 28)
                        .background(
                            Circle()
                                .fill(index == currentDayIndex ? Color.white.opacity(0.1) : Color.clear)
                        )
                }
                .frame(maxWidth: .infinity)
            }
        }
    }
}

// Reusable Page Component mimicking the paper look (kept for compatibility)
struct BookPageView<Content: View>: View {
    let content: Content
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        ZStack {
            // Paper Layer
            RoundedRectangle(cornerRadius: 16)
                .fill(Theme.paper)
                .shadow(color: .black.opacity(0.3), radius: 10, x: 5, y: 5)
            
            // "Binding" Gradient on the left
            HStack {
                LinearGradient(colors: [.black.opacity(0.1), .clear], startPoint: .leading, endPoint: .trailing)
                    .frame(width: 20)
                Spacer()
            }
            .mask(RoundedRectangle(cornerRadius: 16))
            
            // Content
            content
                .padding(30)
        }
        .padding(.horizontal, 30)
        .rotation3DEffect(.degrees(0), axis: (x: 0, y: 1, z: 0))
    }
}

// Helper to split string into chunks for pagination
extension String {
    func chunked(into size: Int) -> [SubSequence] {
        var chunks: [SubSequence] = []
        var from = startIndex
        while from < endIndex {
            let to = index(from, offsetBy: size, limitedBy: endIndex) ?? endIndex
            chunks.append(self[from..<to])
            from = to
        }
        return chunks
    }
}

struct JournalView_Previews: PreviewProvider {
    static var previews: some View {
        JournalView(note: sampleNotes[1])
    }
}
