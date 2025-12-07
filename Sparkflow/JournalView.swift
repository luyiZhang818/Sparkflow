import SwiftUI

struct JournalView: View {
    let note: Note
    @EnvironmentObject var noteStore: NoteStore
    @Environment(\.presentationMode) var presentationMode
    @State private var currentPage = 0
    @State private var searchText = ""
    @State private var isEditing = false
    @State private var editedTitle: String = ""
    @State private var editedContent: String = ""
    @State private var editedTags: [String] = []
    
    // Computed pages based on current content (edited or original)
    private var pages: [String] {
        let content = isEditing ? editedContent : note.content
        return content.chunked(into: 500).map { String($0) }
    }
    
    // Current title (edited or original)
    private var currentTitle: String {
        isEditing ? editedTitle : note.title
    }
    
    // Current tags (edited or original)
    private var currentTags: [String] {
        isEditing ? editedTags : note.tags
    }
    
    // Formatted date for display
    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, d MMMM yyyy"
        return formatter.string(from: note.createdAt)
    }
    
    // Search results - find matching text ranges
    private var searchResults: [Range<String.Index>] {
        guard !searchText.isEmpty else { return [] }
        let contentToSearch = isEditing ? editedContent : note.content
        var ranges: [Range<String.Index>] = []
        var searchStart = contentToSearch.startIndex
        while let range = contentToSearch.range(of: searchText, options: .caseInsensitive, range: searchStart..<contentToSearch.endIndex) {
            ranges.append(range)
            searchStart = range.upperBound
        }
        return ranges
    }
    
    // Count of search matches
    private var matchCount: Int {
        searchResults.count
    }

    init(note: Note) {
        self.note = note
        _editedTitle = State(initialValue: note.title)
        _editedContent = State(initialValue: note.content)
        _editedTags = State(initialValue: note.tags)
    }

    var body: some View {
        ZStack {
            // Dark Background for sheet presentation - covers entire view including safe areas
            Color(hex: "0a0a0a")
                .ignoresSafeArea(edges: .all)
            
            VStack(spacing: 0) {
                // Custom Nav Bar
                HStack {
                    Spacer()
                    
                    // Close button (X)
                    Button(action: { presentationMode.wrappedValue.dismiss() }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(Theme.textMuted)
                            .frame(width: 40, height: 40)
                            .background(
                                Circle()
                                    .fill(Color.white.opacity(0.05))
                            )
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 24)
                
                // Date Header
                Text(formattedDate)
                    .font(.system(size: 13, weight: .regular))
                    .foregroundColor(Theme.textMuted)
                    .padding(.top, 8)
                
                // Title - Reading mode
                Text("Revisit your spark")
                    .font(.custom("PlayfairDisplay-Regular", size: 28))
                    .italic()
                    .foregroundColor(Theme.textPrimary)
                    .padding(.top, 8)
                    .padding(.bottom, 24)
                
                // The Book/Page View
                if isEditing {
                    // Edit Mode - Full text editor
                    JournalEditView(
                        note: note,
                        title: $editedTitle,
                        content: $editedContent,
                        tags: $editedTags,
                        onDone: {
                            // Save all edited fields
                            noteStore.updateNote(
                                id: note.id,
                                title: editedTitle,
                                content: editedContent,
                                tags: editedTags
                            )
                            isEditing = false
                        }
                    )
                } else {
                    // Read Mode - Paginated view
                    TabView(selection: $currentPage) {
                        ForEach(pages.indices, id: \.self) { index in
                            JournalPageView(
                                title: currentTitle,
                                tags: currentTags,
                                content: pages[index],
                                date: formattedDate,
                                pageNumber: index + 1,
                                totalPages: pages.count,
                                isFirstPage: index == 0,
                                searchText: searchText,
                                onTapToEdit: {
                                    isEditing = true
                                }
                            )
                            .tag(index)
                        }
                    }
                    .tabViewStyle(.page(indexDisplayMode: .never))
                    .frame(maxHeight: .infinity)
                }
                
                Spacer()
                    .frame(height: 20)
                
                // Search Bar at bottom - Liquid Glass
                HStack(spacing: 12) {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(Theme.textSecondary)
                    
                    TextField("Search your spark...", text: $searchText)
                        .font(.system(size: 15))
                        .foregroundColor(Theme.textPrimary)
                        .accentColor(Theme.accent)
                    
                    if !searchText.isEmpty {
                        // Show match count
                        Text("\(matchCount) found")
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundColor(Theme.accent)
                        
                        Button(action: { searchText = "" }) {
                            Image(systemName: "xmark.circle.fill")
                                .font(.system(size: 16))
                                .foregroundColor(Theme.textSecondary)
                        }
                    } else {
                        // AI Sparkle icon
                        Image(systemName: "sparkles")
                            .font(.system(size: 14))
                            .foregroundColor(Theme.accent.opacity(0.7))
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
                .liquidGlass(cornerRadius: 16, intensity: 0.7)
                .padding(.horizontal, 24)
                .padding(.bottom, 16)
                
                // Entry Dots Panel - Visual representation of journal entries
                EntryDotsView(notes: noteStore.notes, currentNoteId: note.id)
                    .padding(.horizontal, 24)
                    .padding(.bottom, 40)
            }
        }
        .navigationBarHidden(true)
        .gesture(
            DragGesture()
                .onEnded { value in
                    if value.translation.height > 100 && !isEditing {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
        )
    }
}

// Individual Page View - matching Journal.png paper card style
struct JournalPageView: View {
    let title: String
    let tags: [String]
    let content: String
    let date: String
    let pageNumber: Int
    let totalPages: Int
    let isFirstPage: Bool
    let searchText: String
    let onTapToEdit: () -> Void
    
    // Highlight search matches in the content
    private func highlightedContent() -> Text {
        guard !searchText.isEmpty else {
            return Text(content)
                .font(.custom("Georgia", size: 17))
                .foregroundColor(Theme.textDark)
        }
        
        var result = Text("")
        var remaining = content
        
        while let range = remaining.range(of: searchText, options: .caseInsensitive) {
            // Add text before match
            let beforeMatch = String(remaining[..<range.lowerBound])
            result = result + Text(beforeMatch)
                .font(.custom("Georgia", size: 17))
                .foregroundColor(Theme.textDark)
            
            // Add highlighted match
            let match = String(remaining[range])
            result = result + Text(match)
                .font(.custom("Georgia", size: 17))
                .foregroundColor(Color(hex: "92400E"))
                .bold()
                .underline()
            
            remaining = String(remaining[range.upperBound...])
        }
        
        // Add remaining text
        result = result + Text(remaining)
            .font(.custom("Georgia", size: 17))
            .foregroundColor(Theme.textDark)
        
        return result
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header on first page - Title, Tags, Date
            if isFirstPage {
                // Title
                Text(title)
                    .font(.custom("PlayfairDisplay-Regular", size: 22))
                    .foregroundColor(Theme.textDark)
                    .padding(.bottom, 8)
                
                // Tags Row
                if !tags.isEmpty {
                    HStack(spacing: 6) {
                        ForEach(tags.prefix(3), id: \.self) { tag in
                            Text(tag.uppercased())
                                .font(.system(size: 9, weight: .bold))
                                .tracking(0.5)
                                .foregroundColor(Color(hex: "8c7b64"))
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(
                                    RoundedRectangle(cornerRadius: 4)
                                        .stroke(Color(hex: "8c7b64").opacity(0.4), lineWidth: 1)
                                )
                        }
                    }
                    .padding(.bottom, 8)
                }
                
                // Date
                Text(date)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(Theme.textMuted)
                    .padding(.bottom, 16)
                
                Divider()
                    .background(Color(hex: "d4d0c8"))
                    .padding(.bottom, 16)
            }
            
            // Content - Serif italic text with search highlighting
            highlightedContent()
                .lineSpacing(8)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            Spacer()
            
            // Footer
            HStack {
                Button(action: onTapToEdit) {
                    HStack(spacing: 4) {
                        Image(systemName: "pencil")
                            .font(.system(size: 10))
                        Text("Tap to edit")
                            .font(.system(size: 12))
                    }
                    .foregroundColor(Theme.accent.opacity(0.8))
                }
                
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
        .contentShape(Rectangle())
        .onTapGesture {
            onTapToEdit()
        }
    }
}

// Edit View - Full screen text editor with title and tags
struct JournalEditView: View {
    let note: Note
    @Binding var title: String
    @Binding var content: String
    @Binding var tags: [String]
    let onDone: () -> Void
    
    @State private var tagInput: String = ""
    @FocusState private var focusedField: EditField?
    
    enum EditField {
        case title, content
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Editable Title
            TextField("Title", text: $title)
                .font(.custom("PlayfairDisplay-Regular", size: 20))
                .foregroundColor(Theme.textDark)
                .padding(.horizontal, 24)
                .padding(.top, 24)
                .padding(.bottom, 8)
                .focused($focusedField, equals: .title)
            
            // Tags Row
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(tags, id: \.self) { tag in
                        HStack(spacing: 4) {
                            Text(tag.uppercased())
                                .font(.system(size: 9, weight: .bold))
                                .tracking(0.5)
                            
                            Button(action: { tags.removeAll { $0 == tag } }) {
                                Image(systemName: "xmark")
                                    .font(.system(size: 8, weight: .bold))
                            }
                        }
                        .foregroundColor(Color(hex: "8c7b64"))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(
                            RoundedRectangle(cornerRadius: 4)
                                .stroke(Color(hex: "8c7b64").opacity(0.4), lineWidth: 1)
                        )
                    }
                    
                    // Add Tag Input
                    HStack(spacing: 4) {
                        TextField("+TAG", text: $tagInput)
                            .font(.system(size: 9, weight: .bold))
                            .foregroundColor(Color(hex: "8c7b64"))
                            .frame(width: 50)
                            .onSubmit { addTag() }
                        
                        Button(action: addTag) {
                            Image(systemName: "plus")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundColor(Color(hex: "8c7b64"))
                        }
                    }
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 8)
            }
            
            Divider()
                .background(Color(hex: "d4d0c8"))
                .padding(.horizontal, 24)
            
            // Editable Content
            TextEditor(text: $content)
                .font(.custom("Georgia", size: 17))
                .foregroundColor(Theme.textDark)
                .lineSpacing(8)
                .scrollContentBackground(.hidden)
                .background(Color.clear)
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
                .focused($focusedField, equals: .content)
            
            // Done button
            HStack {
                Spacer()
                Button(action: onDone) {
                    Text("Done")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 10)
                        .background(
                            Capsule()
                                .fill(Theme.accent)
                        )
                }
                .padding(.trailing, 24)
                .padding(.bottom, 16)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color(hex: "e8e4dc"))
        )
        .overlay(
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
        .onAppear {
            focusedField = .content
        }
    }
    
    private func addTag() {
        let trimmed = tagInput.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        if !trimmed.isEmpty && !tags.contains(trimmed) {
            tags.append(trimmed)
            tagInput = ""
        }
    }
}

// Entry Dots Panel - Visual representation of all journal entries
struct EntryDotsView: View {
    let notes: [Note]
    let currentNoteId: String
    
    // Sort notes by their first tag color to group same colors together
    private var sortedNotes: [Note] {
        notes.sorted { note1, note2 in
            let tag1 = note1.tags.first?.lowercased() ?? "zzz"
            let tag2 = note2.tags.first?.lowercased() ?? "zzz"
            return tag1 < tag2
        }
    }
    
    var body: some View {
        VStack(spacing: 10) {
            // Label
            HStack {
                Text("\(notes.count) entries")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(Theme.textMuted)
                Spacer()
            }
            
            // Dots - Horizontal scroll with tighter spacing
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHGrid(rows: [
                    GridItem(.fixed(8), spacing: 2),
                    GridItem(.fixed(8), spacing: 2)
                ], spacing: 2) {
                    ForEach(sortedNotes) { note in
                        Circle()
                            .fill(dotColor(for: note))
                            .frame(width: 8, height: 8)
                            .overlay(
                                Circle()
                                    .stroke(note.id == currentNoteId ? Color.white : Color.clear, lineWidth: 1.5)
                            )
                            .shadow(
                                color: note.id == currentNoteId ? Color.white.opacity(0.4) : Color.clear,
                                radius: 3, x: 0, y: 0
                            )
                    }
                }
                .padding(.horizontal, 2)
            }
            .frame(height: 22)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .liquidGlass(cornerRadius: 16, intensity: 0.5)
    }
    
    // Get color for dot based on first tag
    private func dotColor(for note: Note) -> Color {
        guard let firstTag = note.tags.first else {
            return Color.white.opacity(0.3)
        }
        
        // Return tag-specific colors
        switch firstTag.lowercased() {
        case "inspiration":
            return Color(hex: "F59E0B") // Amber
        case "quote":
            return Color(hex: "a8a29e") // Stone
        case "idea":
            return Color(hex: "ea580c") // Orange
        case "journal":
            return Color(hex: "f472b6") // Rose/Pink
        case "dream":
            return Color(hex: "818cf8") // Indigo/Purple
        case "stoicism":
            return Color(hex: "9ca3af") // Gray
        case "design":
            return Color(hex: "a3a3a3") // Neutral
        default:
            return Color(hex: "D97706") // Default amber
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
            .environmentObject(NoteStore())
    }
}
