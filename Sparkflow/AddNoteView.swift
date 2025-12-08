import SwiftUI

struct AddNoteView: View {
    @EnvironmentObject var noteStore: NoteStore
    @Environment(\.presentationMode) var presentationMode

    // MARK: - Input Fields (New Spark-Based Structure)
    @State private var spark = ""           // Required - the core idea/quote
    @State private var source = ""          // Optional - where it came from
    @State private var initialBullet = ""   // Required - first reflection
    @State private var tags: [String] = []
    
    // UI State
    @State private var isAddingTag = false
    @State private var newTagInput = ""
    @FocusState private var focusedField: Field?
    
    enum Field {
        case spark, source, bullet, tagInput
    }
    
    // All available tags from existing notes
    private var availableTags: [String] {
        var allTags = Set<String>()
        noteStore.notes.forEach { note in
            note.tags.forEach { allTags.insert($0) }
        }
        // Add some default tags if none exist
        if allTags.isEmpty {
            return ["inspiration", "quote", "idea", "journal", "dream", "stoicism", "design", "philosophy", "creativity", "mindfulness"]
        }
        return Array(allTags).sorted()
    }
    
    // Formatted current date
    private var currentDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, d MMMM"
        return formatter.string(from: Date())
    }
    
    // Validation: Can save only if Spark AND Initial Bullet are filled
    private var canSave: Bool {
        !spark.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !initialBullet.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var body: some View {
        ZStack {
            // Dark Background
            Color(hex: "0a0a0a")
                .ignoresSafeArea(edges: .all)
            
            VStack(spacing: 0) {
                // Header
                HStack {
                    Button(action: { presentationMode.wrappedValue.dismiss() }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(Theme.textMuted)
                            .frame(width: 40, height: 40)
                            .background(Circle().fill(Color.white.opacity(0.05)))
                    }
                    
                    Spacer()
                    
                    // Save Button
                    Button(action: {
                        saveNote()
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Text("Save")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 10)
                            .background(
                                Capsule()
                                    .fill(
                                        LinearGradient(
                                            colors: [Theme.accentLight, Theme.accent],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                            )
                            .shadow(color: Theme.accentGlow.opacity(0.4), radius: 8, x: 0, y: 4)
                    }
                    .disabled(!canSave)
                    .opacity(canSave ? 1 : 0.5)
                }
                .padding(.horizontal, 24)
                .padding(.top, 20)
                
                // Date
                Text(currentDate)
                    .font(.system(size: 12, weight: .regular))
                    .foregroundColor(Theme.textMuted)
                    .padding(.top, 4)
                
                // Title - "Capture a spark"
                Text("Capture a spark")
                    .font(.custom("PlayfairDisplay-Regular", size: 24))
                    .foregroundColor(Theme.textPrimary)
                .padding(.top, 2)
                .padding(.bottom, 20)
                
                // Book/Journal Card
                ScrollView {
                    VStack(alignment: .leading, spacing: 0) {
                        // MARK: - Spark Input (Primary, Most Prominent)
                        VStack(alignment: .leading, spacing: 6) {
                            Text("SPARK")
                                .font(.system(size: 10, weight: .bold))
                                .tracking(1)
                                .foregroundColor(Theme.accent.opacity(0.8))
                            
                            ZStack(alignment: .topLeading) {
                                if spark.isEmpty {
                                    Text("A quote, idea, or thought worth keeping...")
                                        .font(.custom("PlayfairDisplay-Regular", size: 22))
                                        .foregroundColor(Color(hex: "a8a29e"))
                                        .allowsHitTesting(false)
                                }
                                
                                TextEditor(text: $spark)
                                    .font(.custom("PlayfairDisplay-Regular", size: 22))
                                    .foregroundColor(Theme.textDark)
                                    .scrollContentBackground(.hidden)
                                    .background(Color.clear)
                                    .frame(minHeight: 60, maxHeight: 120)
                                    .focused($focusedField, equals: .spark)
                            }
                        }
                        .padding(.horizontal, 24)
                        .padding(.top, 24)
                        .padding(.bottom, 12)
                        
                        // MARK: - Source Input (Optional, Subtle)
                        VStack(alignment: .leading, spacing: 4) {
                            HStack(spacing: 4) {
                                Image(systemName: "link")
                                    .font(.system(size: 9, weight: .medium))
                                Text("SOURCE")
                                    .font(.system(size: 10, weight: .medium))
                                    .tracking(0.5)
                                Text("(optional)")
                                    .font(.system(size: 9, weight: .regular))
                                    .italic()
                            }
                            .foregroundColor(Color(hex: "8c7b64").opacity(0.7))
                            
                            TextField("Book, person, or origin...", text: $source)
                                .font(.system(size: 14))
                                .foregroundColor(Theme.textDark.opacity(0.8))
                                .focused($focusedField, equals: .source)
                        }
                        .padding(.horizontal, 24)
                        .padding(.bottom, 16)
                        
                        Divider()
                            .background(Color(hex: "d4d0c8"))
                            .padding(.horizontal, 24)
                        
                        // MARK: - Tags Row
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                // +TAG button or input field
                                if isAddingTag {
                                    HStack(spacing: 4) {
                                        TextField("NEW TAG", text: $newTagInput)
                                            .font(.system(size: 9, weight: .bold))
                                            .tracking(0.5)
                                            .textCase(.uppercase)
                                            .foregroundColor(Color(hex: "8c7b64"))
                                            .textInputAutocapitalization(.characters)
                                            .autocorrectionDisabled()
                                            .frame(width: 55)
                                            .focused($focusedField, equals: .tagInput)
                                            .onChange(of: newTagInput) { _, newValue in
                                                newTagInput = newValue.uppercased()
                                            }
                                            .onSubmit {
                                                addNewTag()
                                            }
                                        
                                        Button(action: addNewTag) {
                                            Image(systemName: "checkmark")
                                                .font(.system(size: 8, weight: .bold))
                                                .foregroundColor(Theme.accent)
                                        }
                                        
                                        Button(action: {
                                            withAnimation(.easeInOut(duration: 0.2)) {
                                                isAddingTag = false
                                                newTagInput = ""
                                            }
                                        }) {
                                            Image(systemName: "xmark")
                                                .font(.system(size: 8, weight: .bold))
                                                .foregroundColor(Color(hex: "8c7b64").opacity(0.6))
                                        }
                                    }
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 6)
                                    .background(
                                        RoundedRectangle(cornerRadius: 4)
                                            .fill(Color(hex: "8c7b64").opacity(0.1))
                                    )
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 4)
                                            .stroke(Color(hex: "8c7b64").opacity(0.4), lineWidth: 1)
                                    )
                                } else {
                                    Button(action: {
                                        withAnimation(.easeInOut(duration: 0.2)) {
                                            isAddingTag = true
                                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                                focusedField = .tagInput
                                            }
                                        }
                                    }) {
                                        HStack(spacing: 4) {
                                            Image(systemName: "plus")
                                                .font(.system(size: 9, weight: .bold))
                                            Text("TAG")
                                                .font(.system(size: 9, weight: .bold))
                                                .tracking(0.5)
                                        }
                                        .foregroundColor(Color(hex: "8c7b64").opacity(0.7))
                                        .padding(.horizontal, 10)
                                        .padding(.vertical, 6)
                                        .background(
                                            RoundedRectangle(cornerRadius: 4)
                                                .stroke(Color(hex: "8c7b64").opacity(0.3), lineWidth: 1)
                                        )
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                                
                                // Divider after +TAG
                                if !tags.isEmpty || !availableTags.filter({ !tags.contains($0) }).isEmpty {
                                    Rectangle()
                                        .fill(Color(hex: "8c7b64").opacity(0.3))
                                        .frame(width: 1, height: 16)
                                }
                                
                                // Selected tags first (with X to remove)
                                ForEach(tags, id: \.self) { tag in
                                    HStack(spacing: 4) {
                                        Text(tag.uppercased())
                                            .font(.system(size: 9, weight: .bold))
                                            .tracking(0.5)
                                        
                                        Button(action: { 
                                            withAnimation(.easeInOut(duration: 0.2)) {
                                                tags.removeAll { $0 == tag }
                                            }
                                        }) {
                                            Image(systemName: "xmark")
                                                .font(.system(size: 8, weight: .bold))
                                        }
                                    }
                                    .foregroundColor(Color(hex: "8c7b64"))
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 6)
                                    .background(
                                        RoundedRectangle(cornerRadius: 4)
                                            .fill(Color(hex: "8c7b64").opacity(0.1))
                                    )
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 4)
                                            .stroke(Color(hex: "8c7b64").opacity(0.4), lineWidth: 1)
                                    )
                                }
                                
                                // Divider between selected and available
                                if !tags.isEmpty && !availableTags.filter({ !tags.contains($0) }).isEmpty {
                                    Rectangle()
                                        .fill(Color(hex: "8c7b64").opacity(0.3))
                                        .frame(width: 1, height: 16)
                                }
                                
                                // Available tags to add (not already selected)
                                ForEach(availableTags.filter { !tags.contains($0) }, id: \.self) { tag in
                                    Button(action: {
                                        withAnimation(.easeInOut(duration: 0.2)) {
                                            tags.insert(tag, at: 0)
                                        }
                                    }) {
                                        Text(tag.uppercased())
                                            .font(.system(size: 9, weight: .bold))
                                            .tracking(0.5)
                                            .foregroundColor(Color(hex: "8c7b64").opacity(0.7))
                                            .padding(.horizontal, 10)
                                            .padding(.vertical, 6)
                                            .background(
                                                RoundedRectangle(cornerRadius: 4)
                                                    .stroke(Color(hex: "8c7b64").opacity(0.3), lineWidth: 1)
                                            )
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                            }
                            .padding(.horizontal, 24)
                            .padding(.vertical, 12)
                        }
                        
                        Divider()
                            .background(Color(hex: "d4d0c8"))
                            .padding(.horizontal, 24)
                        
                        // MARK: - Initial Bullet (Required First Reflection)
                        VStack(alignment: .leading, spacing: 6) {
                            HStack(spacing: 6) {
                                Circle()
                                    .fill(Theme.accent)
                                    .frame(width: 6, height: 6)
                                Text("YOUR FIRST REFLECTION")
                                    .font(.system(size: 10, weight: .bold))
                                    .tracking(0.5)
                                    .foregroundColor(Color(hex: "8c7b64"))
                            }
                            
                            ZStack(alignment: .topLeading) {
                                if initialBullet.isEmpty {
                                    Text("What does this spark mean to you right now?")
                                        .font(.custom("Georgia", size: 15))
                                        .italic()
                                        .foregroundColor(Color(hex: "a8a29e"))
                                        .allowsHitTesting(false)
                                }
                                
                                TextEditor(text: $initialBullet)
                                    .font(.custom("Georgia", size: 15))
                                    .foregroundColor(Theme.textDark)
                                    .scrollContentBackground(.hidden)
                                    .background(Color.clear)
                                    .frame(minHeight: 80, maxHeight: 150)
                                    .focused($focusedField, equals: .bullet)
                            }
                        }
                        .padding(.horizontal, 24)
                        .padding(.top, 16)
                        .padding(.bottom, 20)
                    }
                }
                .frame(maxWidth: .infinity)
                .frame(height: 460)
                .background(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .fill(Color(hex: "e8e4dc"))
                )
                .overlay(
                    // Binding shadow on left
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
                .overlay(
                    // Timestamp at absolute bottom-right of card
                    VStack {
                        Spacer()
                        HStack {
                            Spacer()
                            Text(timestampPreview())
                                .font(.system(size: 9, weight: .medium))
                                .foregroundColor(Color(hex: "8c7b64").opacity(0.5))
                        }
                        .padding(.horizontal, 24)
                        .padding(.bottom, 16)
                    }
                )
                .shadow(color: Color.black.opacity(0.3), radius: 20, x: 0, y: 10)
                .padding(.horizontal, 24)
                
                Spacer()
                    .frame(height: 20)
                
                // Entry Dots Panel
                AddNoteEntryDotsView(notes: noteStore.notes)
                    .padding(.horizontal, 24)
                    .padding(.bottom, 24)
            }
        }
        .onTapGesture {
            // Dismiss keyboard when tapping outside
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        }
        .gesture(
            DragGesture()
                .onEnded { value in
                    // Swipe down to dismiss
                    if value.translation.height > 100 {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
        )
        .onAppear {
            // Focus spark field on appear
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                focusedField = .spark
            }
        }
    }
    
    // MARK: - Helper Functions
    
    private func timestampPreview() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, yyyy 'at' h:mm a"
        return formatter.string(from: Date())
    }
    
    private func addNewTag() {
        let trimmed = newTagInput.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        if !trimmed.isEmpty && !tags.contains(trimmed) {
            withAnimation(.easeInOut(duration: 0.2)) {
                tags.insert(trimmed, at: 0)
                isAddingTag = false
                newTagInput = ""
            }
        }
    }
    
    private func saveNote() {
        let trimmedSpark = spark.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedSource = source.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedBullet = initialBullet.trimmingCharacters(in: .whitespacesAndNewlines)
        
        let newNote = Note(
            spark: trimmedSpark,
            source: trimmedSource.isEmpty ? nil : trimmedSource,
            tags: tags,
            initialBullet: trimmedBullet
        )
        
        noteStore.notes.insert(newNote, at: 0)
        noteStore.save()
    }
}

// MARK: - Entry Dots View (Updated for Spark-based notes)
struct AddNoteEntryDotsView: View {
    let notes: [Note]
    
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
                Text("\(notes.count) sparks")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(Theme.textMuted)
                Spacer()
            }
            
            // Dots - Horizontal scroll with tighter spacing
            if notes.isEmpty {
                Text("Your first spark awaits!")
                    .font(.system(size: 12))
                    .italic()
                    .foregroundColor(Theme.textMuted.opacity(0.6))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 4)
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    LazyHGrid(rows: [
                        GridItem(.fixed(8), spacing: 2),
                        GridItem(.fixed(8), spacing: 2)
                    ], spacing: 2) {
                        ForEach(sortedNotes) { note in
                            Circle()
                                .fill(dotColor(for: note))
                                .frame(width: 8, height: 8)
                        }
                    }
                    .padding(.horizontal, 2)
                }
                .frame(height: 22)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .liquidGlass(cornerRadius: 16, intensity: 0.5)
    }
    
    private func dotColor(for note: Note) -> Color {
        guard let firstTag = note.tags.first else {
            return Color.white.opacity(0.3)
        }
        
        switch firstTag.lowercased() {
        case "inspiration": return Color(hex: "F59E0B")
        case "quote": return Color(hex: "a8a29e")
        case "idea": return Color(hex: "ea580c")
        case "journal": return Color(hex: "f472b6")
        case "dream": return Color(hex: "818cf8")
        case "stoicism": return Color(hex: "9ca3af")
        case "design": return Color(hex: "a3a3a3")
        case "philosophy": return Color(hex: "a78bfa")
        case "creativity": return Color(hex: "fb923c")
        case "mindfulness": return Color(hex: "4ade80")
        default: return Color(hex: "D97706")
        }
    }
}

struct AddNoteView_Previews: PreviewProvider {
    static var previews: some View {
        AddNoteView()
            .environmentObject(NoteStore())
    }
}
