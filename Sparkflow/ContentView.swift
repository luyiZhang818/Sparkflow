import SwiftUI

struct ContentView: View {
    @EnvironmentObject var noteStore: NoteStore
    @State private var isAddingNote = false
    @State private var searchText = ""
    @State private var featuredNote: Note?
    @State private var selectedTag: String? = nil
    
    // Collect all unique tags from notes
    var allTags: [String] {
        var tags = Set<String>()
        noteStore.notes.forEach { note in
            note.tags.forEach { tags.insert($0) }
        }
        return Array(tags).sorted()
    }
    
    // Filtered notes based on search and tag
    var filteredNotes: [Note] {
        noteStore.notes.filter { note in
            let matchesSearch = searchText.isEmpty || 
                note.title.localizedCaseInsensitiveContains(searchText) ||
                note.content.localizedCaseInsensitiveContains(searchText)
            let matchesTag = selectedTag == nil || note.tags.contains(selectedTag!)
            return matchesSearch && matchesTag
        }
    }

    var body: some View {
        NavigationView {
            ZStack {
                // Global Background
                Theme.backgroundMesh
                
                VStack(alignment: .leading, spacing: 0) {
                    
                    // Header
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Commonplace")
                                .font(.custom("PlayfairDisplay-Regular", size: 34))
                                .italic()
                                .foregroundColor(Theme.textPrimary)
                            Text("Curate your mind.")
                                .font(.system(size: 13, weight: .regular))
                                .tracking(0.5)
                                .foregroundColor(Theme.textMuted)
                        }
                        Spacer()
                        
                        // Orange Accent Add Button
                        Button(action: { isAddingNote = true }) {
                            Image(systemName: "plus")
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundColor(.white)
                                .frame(width: 48, height: 48)
                                .background(
                                    Circle()
                                        .fill(
                                            LinearGradient(
                                                colors: [Theme.accentLight, Theme.accent],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            )
                                        )
                                )
                                .shadow(color: Theme.accentGlow.opacity(0.5), radius: 12, x: 0, y: 6)
                                .overlay(Circle().stroke(Color.white.opacity(0.2), lineWidth: 1))
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 20)
                    .padding(.bottom, 24)

                    // Scrollable Content
                    ScrollView(.vertical, showsIndicators: false) {
                        VStack(spacing: 24) {
                            // Featured Note
                            if let featuredNote = featuredNote {
                                FeaturedNoteView(note: featuredNote)
                                    .onTapGesture {
                                        // Navigate to journal - handled differently if needed
                                    }
                            }
                            
                            // Search & Filter Card
                            VStack(spacing: 12) {
                                // Search Bar
                                HStack(spacing: 12) {
                                    Image(systemName: "magnifyingglass")
                                        .foregroundColor(Theme.textMuted)
                                        .font(.system(size: 16))
                                    TextField("Search entries...", text: $searchText)
                                        .foregroundColor(Theme.textPrimary)
                                        .accentColor(Theme.accent)
                                        .font(.system(size: 15))
                                }
                                .padding(.horizontal, 16)
                                .padding(.vertical, 14)
                                
                                Divider()
                                    .background(Color.white.opacity(0.05))
                                
                                // Tag Filter Pills
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 8) {
                                        // All Button
                                        TagFilterButton(
                                            tag: "All",
                                            isSelected: selectedTag == nil,
                                            action: { selectedTag = nil }
                                        )
                                        
                                        ForEach(allTags, id: \.self) { tag in
                                            TagFilterButton(
                                                tag: tag.capitalized,
                                                isSelected: selectedTag == tag,
                                                action: {
                                                    selectedTag = selectedTag == tag ? nil : tag
                                                }
                                            )
                                        }
                                    }
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 12)
                                }
                            }
                            .background(
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(Color(hex: "292524").opacity(0.6))
                                    .background(
                                        RoundedRectangle(cornerRadius: 20)
                                            .fill(.ultraThinMaterial)
                                    )
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(Color.white.opacity(0.05), lineWidth: 1)
                            )
                            
                            // Notes List
                            LazyVStack(spacing: 16) {
                                ForEach(filteredNotes) { note in
                                    NavigationLink(destination: JournalView(note: note)) {
                                        GlassCardView(note: note)
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                            }
                            
                            if filteredNotes.isEmpty {
                                VStack(spacing: 8) {
                                    Text("No thoughts found.")
                                        .font(.custom("PlayfairDisplay-Regular", size: 18))
                                        .italic()
                                        .foregroundColor(Theme.textMuted)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 60)
                            }
                        }
                        .padding(.horizontal, 24)
                        .padding(.bottom, 40)
                    }
                }
            }
            .navigationBarHidden(true)
            .onAppear {
                if !noteStore.notes.isEmpty {
                    featuredNote = noteStore.notes.randomElement()
                }
            }
            .sheet(isPresented: $isAddingNote) {
                AddNoteView()
                    .environmentObject(noteStore)
            }
        }
        .navigationViewStyle(.stack)
    }
}

// Tag Filter Button Component
struct TagFilterButton: View {
    let tag: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(tag)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(isSelected ? Color(hex: "fef3c7") : Theme.textMuted)
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(isSelected ? Theme.accent.opacity(0.15) : Color.clear)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(isSelected ? Theme.accent.opacity(0.3) : Color.clear, lineWidth: 1)
                )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(NoteStore())
    }
}
