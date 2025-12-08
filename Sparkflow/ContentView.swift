import SwiftUI

struct ContentView: View {
    @EnvironmentObject var noteStore: NoteStore
    @State private var isAddingNote = false
    @State private var searchText = ""
    @State private var featuredNote: Note?
    @State private var selectedTag: String? = nil
    @State private var noteToDelete: Note? = nil
    @State private var showDeleteConfirmation = false
    @State private var selectedNoteForReading: Note? = nil
    
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
            VStack(alignment: .leading, spacing: 0) {
                
                // Header
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Sparkflow")
                            .font(.custom("PlayfairDisplay-Regular", size: 34))
                            .italic()
                            .foregroundColor(Theme.textPrimary)
                        Text("Curate your mind.")
                            .font(.system(size: 13, weight: .regular))
                            .tracking(0.5)
                            .foregroundColor(Theme.textMuted)
                    }
                    Spacer()
                    
                    // Orange Accent Add Button with Liquid Glass
                    Button(action: { isAddingNote = true }) {
                        Image(systemName: "plus")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(width: 48, height: 48)
                            .background(
                                ZStack {
                                    Circle()
                                        .fill(
                                            LinearGradient(
                                                colors: [Theme.accentLight, Theme.accent],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            )
                                        )
                                    
                                    VStack {
                                        Circle()
                                            .fill(
                                                LinearGradient(
                                                    colors: [.white.opacity(0.4), .clear],
                                                    startPoint: .top,
                                                    endPoint: .center
                                                )
                                            )
                                            .frame(height: 24)
                                        Spacer()
                                    }
                                    .frame(width: 48, height: 48)
                                    .clipShape(Circle())
                                }
                            )
                            .overlay(
                                Circle()
                                    .stroke(
                                        LinearGradient(
                                            colors: [.white.opacity(0.5), .white.opacity(0.1)],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        ),
                                        lineWidth: 1
                                    )
                            )
                            .shadow(color: Theme.accentGlow.opacity(0.5), radius: 12, x: 0, y: 6)
                    }
                    .buttonStyle(LiquidGlassButtonStyle())
                }
                .padding(.horizontal, 24)
                .padding(.top, 20)
                .padding(.bottom, 16)
                
                // Search & Filter Card - Fixed at top (outside ScrollView)
                VStack(spacing: 12) {
                    // Search Bar
                    HStack(spacing: 12) {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(Theme.textSecondary)
                            .font(.system(size: 16, weight: .medium))
                        TextField("Search entries...", text: $searchText)
                            .foregroundColor(Theme.textPrimary)
                            .accentColor(Theme.accent)
                            .font(.system(size: 15))
                        
                        if !searchText.isEmpty {
                            Button(action: { searchText = "" }) {
                                Image(systemName: "xmark.circle.fill")
                                    .font(.system(size: 16))
                                    .foregroundColor(Theme.textSecondary)
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 14)
                    
                    Divider()
                        .background(Color.white.opacity(0.08))
                    
                    // Tag Filter Pills
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            TagFilterButton(
                                tag: "All",
                                isSelected: selectedTag == nil,
                                action: {
                                    withAnimation(.easeInOut(duration: 0.2)) {
                                        selectedTag = nil
                                    }
                                }
                            )
                            
                            ForEach(allTags, id: \.self) { tag in
                                TagFilterButton(
                                    tag: tag.capitalized,
                                    isSelected: selectedTag == tag,
                                    action: {
                                        withAnimation(.easeInOut(duration: 0.2)) {
                                            selectedTag = selectedTag == tag ? nil : tag
                                        }
                                    }
                                )
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                    }
                }
                .liquidGlassPanel()
                .padding(.horizontal, 24)
                .padding(.bottom, 16)

                // Scrollable Content
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 24) {
                        // Featured Note
                        if let featuredNote = featuredNote {
                            FeaturedNoteView(note: featuredNote)
                                .onTapGesture {
                                    selectedNoteForReading = featuredNote
                                }
                        }
                        
                        // Notes List
                        LazyVStack(spacing: 16) {
                            ForEach(filteredNotes) { note in
                                Button(action: {
                                    selectedNoteForReading = note
                                }) {
                                    GlassCardView(note: note)
                                }
                                .buttonStyle(PlainButtonStyle())
                                .contextMenu {
                                    Button(role: .destructive) {
                                        noteToDelete = note
                                        showDeleteConfirmation = true
                                    } label: {
                                        Label("Delete Entry", systemImage: "trash")
                                    }
                                }
                                .onLongPressGesture {
                                    let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
                                    impactFeedback.impactOccurred()
                                    noteToDelete = note
                                    showDeleteConfirmation = true
                                }
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
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Theme.dashboardBackground)
            .navigationBarHidden(true)
            .onAppear {
                if !noteStore.notes.isEmpty {
                    featuredNote = noteStore.notes.randomElement()
                }
            }
            .sheet(isPresented: $isAddingNote) {
                AddNoteView()
                    .environmentObject(noteStore)
                    .presentationDetents([.fraction(0.93)])
                    .presentationDragIndicator(.hidden)
                    .presentationCornerRadius(32)
                    .interactiveDismissDisabled(false)
            }
            .sheet(item: $selectedNoteForReading) { note in
                JournalView(note: note)
                    .environmentObject(noteStore)
                    .presentationDetents([.fraction(0.93)])
                    .presentationDragIndicator(.hidden)
                    .presentationCornerRadius(32)
                    .interactiveDismissDisabled(false)
            }
            .alert("Delete Entry", isPresented: $showDeleteConfirmation) {
                Button("Cancel", role: .cancel) {
                    noteToDelete = nil
                }
                Button("Delete", role: .destructive) {
                    if let note = noteToDelete {
                        withAnimation {
                            noteStore.deleteNote(id: note.id)
                            // Update featured note if it was deleted
                            if featuredNote?.id == note.id {
                                featuredNote = noteStore.notes.first
                            }
                        }
                        noteToDelete = nil
                    }
                }
            } message: {
                Text("Are you sure you want to delete \"\(noteToDelete?.title ?? "this entry")\"? This action cannot be undone.")
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
