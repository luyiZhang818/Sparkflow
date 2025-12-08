import SwiftUI

struct JournalView: View {
    let note: Note
    @EnvironmentObject var noteStore: NoteStore
    @Environment(\.presentationMode) var presentationMode
    @State private var isAddingBullet = false
    @State private var newBulletText = ""
    @FocusState private var isBulletInputFocused: Bool
    
    // Formatted date for display
    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, d MMMM yyyy"
        return formatter.string(from: note.createdAt)
    }

    var body: some View {
        ZStack {
            // Dark Background
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
                .padding(.top, 20)
                
                // Date Header
                Text(formattedDate)
                    .font(.system(size: 12, weight: .regular))
                    .foregroundColor(Theme.textMuted)
                    .padding(.top, 4)
                
                // Title
                Text("Revisit your spark")
                    .font(.custom("PlayfairDisplay-Regular", size: 24))
                    .foregroundColor(Theme.textPrimary)
                    .padding(.top, 2)
                    .padding(.bottom, 20)
                
                // The Journal Card
                VStack(alignment: .leading, spacing: 0) {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 0) {
                            // MARK: - Spark (Primary, Most Prominent - READONLY, Quote Style)
                            VStack(spacing: 8) {
                                Text("\"\(note.spark)\"")
                                    .font(.custom("PlayfairDisplay-Regular", size: 22))
                                    .italic()
                                    .foregroundColor(Theme.textDark)
                                    .lineSpacing(6)
                                    .multilineTextAlignment(.center)
                                    .frame(maxWidth: .infinity)
                            }
                            .padding(.horizontal, 24)
                            .padding(.top, 24)
                            .padding(.bottom, 8)
                            
                            // MARK: - Source (Subtle, READONLY, Centered)
                            if let source = note.source, !source.isEmpty {
                                HStack(spacing: 4) {
                                    Text("—")
                                        .font(.system(size: 12, weight: .medium))
                                    Text(source)
                                        .font(.system(size: 12, weight: .semibold))
                                        .tracking(0.5)
                                }
                                .foregroundColor(Theme.accent.opacity(0.9))
                                .frame(maxWidth: .infinity)
                                .padding(.bottom, 12)
                            }
                            
                            // MARK: - Tags (READONLY display)
                            if !note.tags.isEmpty {
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 6) {
                                        ForEach(note.tags, id: \.self) { tag in
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
                                    .padding(.horizontal, 24)
                                }
                                .padding(.bottom, 16)
                            }
                            
                            Divider()
                                .background(Color(hex: "d4d0c8"))
                                .padding(.horizontal, 24)
                            
                            // MARK: - Bullet Timeline Header
                            HStack {
                                Text("REFLECTIONS")
                                    .font(.system(size: 10, weight: .bold))
                                    .tracking(1)
                                    .foregroundColor(Color(hex: "8c7b64").opacity(0.8))
                                
                                Spacer()
                                
                                Text("\(note.bullets.count) thought\(note.bullets.count == 1 ? "" : "s")")
                                    .font(.system(size: 10, weight: .medium))
                                    .foregroundColor(Color(hex: "8c7b64").opacity(0.6))
                            }
                            .padding(.horizontal, 24)
                            .padding(.top, 16)
                            .padding(.bottom, 12)
                            
                            // MARK: - Add New Bullet Section (At TOP - newest first)
                            if isAddingBullet {
                                HStack(alignment: .top, spacing: 8) {
                                    // Continuous timeline running full height
                                    VStack(spacing: 0) {
                                        Circle()
                                            .fill(Theme.accent)
                                            .frame(width: 8, height: 8)
                                        Rectangle()
                                            .fill(Color(hex: "8c7b64").opacity(0.3))
                                            .frame(width: 2)
                                            .frame(maxHeight: .infinity)
                                    }
                                    .frame(width: 20)
                                    
                                    // Content area
                                    VStack(alignment: .leading, spacing: 8) {
                                        Text("NOW")
                                            .font(.system(size: 10, weight: .bold))
                                            .tracking(0.5)
                                            .foregroundColor(Theme.accent)
                                        
                                        ZStack(alignment: .topLeading) {
                                            if newBulletText.isEmpty {
                                                Text("Add your new reflection...")
                                                    .font(.custom("Georgia", size: 15))
                                                    .italic()
                                                    .foregroundColor(Color(hex: "a8a29e"))
                                                    .allowsHitTesting(false)
                                            }
                                            
                                            TextEditor(text: $newBulletText)
                                                .font(.custom("Georgia", size: 15))
                                                .foregroundColor(Theme.textDark)
                                                .scrollContentBackground(.hidden)
                                                .background(Color.clear)
                                                .frame(minHeight: 60, maxHeight: 100)
                                                .focused($isBulletInputFocused)
                                        }
                                        
                                        // Action buttons
                                        HStack {
                                            Spacer()
                                            
                                            Button(action: {
                                                withAnimation(.easeInOut(duration: 0.2)) {
                                                    isAddingBullet = false
                                                    newBulletText = ""
                                                }
                                            }) {
                                                Text("Cancel")
                                                    .font(.system(size: 12, weight: .medium))
                                                    .foregroundColor(Theme.textMuted)
                                                    .padding(.horizontal, 16)
                                                    .padding(.vertical, 8)
                                            }
                                            
                                            Button(action: saveBullet) {
                                                Text("Add")
                                                    .font(.system(size: 12, weight: .semibold))
                                                    .foregroundColor(.white)
                                                    .padding(.horizontal, 20)
                                                    .padding(.vertical, 8)
                                                    .background(
                                                        Capsule()
                                                            .fill(Theme.accent)
                                                    )
                                            }
                                            .disabled(newBulletText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                                            .opacity(newBulletText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? 0.5 : 1)
                                        }
                                    }
                                }
                                .padding(.horizontal, 24)
                            }
                            
                            // MARK: - Bullet Timeline (Newest → Oldest)
                            VStack(alignment: .leading, spacing: 0) {
                                let reversedBullets = Array(note.bullets.reversed())
                                ForEach(Array(reversedBullets.enumerated()), id: \.element.id) { index, bullet in
                                    BulletTimelineItem(
                                        bullet: bullet,
                                        isFirst: index == 0 && !isAddingBullet,
                                        isLast: index == reversedBullets.count - 1,
                                        hasNewBulletAbove: index == 0 && isAddingBullet
                                    )
                                }
                            }
                            .padding(.horizontal, 24)
                            .padding(.bottom, 16)
                        }
                    }
                    
                    // MARK: - Footer with Add Reflection Button
                    if !isAddingBullet {
                        HStack {
                            Button(action: {
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    isAddingBullet = true
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                        isBulletInputFocused = true
                                    }
                                }
                            }) {
                                HStack(spacing: 6) {
                                    Image(systemName: "plus.circle.fill")
                                        .font(.system(size: 14))
                                    Text("Add reflection")
                                        .font(.system(size: 13, weight: .medium))
                                }
                                .foregroundColor(Theme.accent)
                            }
                            
                            Spacer()
                        }
                        .padding(.horizontal, 24)
                        .padding(.vertical, 16)
                        .background(
                            Rectangle()
                                .fill(Color(hex: "e8e4dc"))
                                .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: -4)
                        )
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
                .shadow(color: Color.black.opacity(0.3), radius: 20, x: 0, y: 10)
                .padding(.horizontal, 24)
                
                Spacer()
                    .frame(height: 20)
                
                // Entry Dots Panel
                EntryDotsView(notes: noteStore.notes, currentNoteId: note.id)
                    .padding(.horizontal, 24)
                    .padding(.bottom, 24)
            }
        }
        .navigationBarHidden(true)
        .gesture(
            DragGesture()
                .onEnded { value in
                    if value.translation.height > 100 && !isAddingBullet {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
        )
        .onTapGesture {
            // Dismiss keyboard when tapping outside
            if isAddingBullet {
                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
            }
        }
    }
    
    // MARK: - Save New Bullet
    private func saveBullet() {
        let trimmedText = newBulletText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedText.isEmpty else { return }
        
        noteStore.addBullet(to: note.id, text: trimmedText)
        
        withAnimation(.easeInOut(duration: 0.2)) {
            isAddingBullet = false
            newBulletText = ""
        }
    }
}

// MARK: - Bullet Timeline Item
struct BulletTimelineItem: View {
    let bullet: Bullet
    let isFirst: Bool
    let isLast: Bool
    var hasNewBulletAbove: Bool = false
    
    private var formattedTimestamp: String {
        let formatter = DateFormatter()
        let calendar = Calendar.current
        
        if calendar.isDateInToday(bullet.timestamp) {
            formatter.dateFormat = "'Today at' h:mm a"
        } else if calendar.isDateInYesterday(bullet.timestamp) {
            formatter.dateFormat = "'Yesterday at' h:mm a"
        } else if calendar.isDate(bullet.timestamp, equalTo: Date(), toGranularity: .year) {
            formatter.dateFormat = "MMM d 'at' h:mm a"
        } else {
            formatter.dateFormat = "MMM d, yyyy"
        }
        
        return formatter.string(from: bullet.timestamp)
    }
    
    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            // Timeline indicator
            VStack(spacing: 0) {
                // Top line (hidden for first item unless there's a new bullet input above)
                Rectangle()
                    .fill((isFirst && !hasNewBulletAbove) ? Color.clear : Color(hex: "8c7b64").opacity(0.3))
                    .frame(width: 2, height: 8)
                
                // Dot
                Circle()
                    .fill((isFirst && !hasNewBulletAbove) ? Theme.accent : Color(hex: "8c7b64").opacity(0.5))
                    .frame(width: 8, height: 8)
                
                // Bottom line (hidden for last item)
                Rectangle()
                    .fill(isLast ? Color.clear : Color(hex: "8c7b64").opacity(0.3))
                    .frame(width: 2)
                    .frame(maxHeight: .infinity)
            }
            .frame(width: 20)
            
            // Content
            VStack(alignment: .leading, spacing: 4) {
                // Timestamp
                Text(formattedTimestamp)
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(Color(hex: "8c7b64").opacity(0.7))
                
                // Bullet text
                Text(bullet.text)
                    .font(.custom("Georgia", size: 15))
                    .foregroundColor(Theme.textDark)
                    .lineSpacing(4)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(.bottom, isLast ? 0 : 16)
        }
    }
}

// MARK: - Entry Dots Panel
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
                Text("\(notes.count) sparks")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(Theme.textMuted)
                Spacer()
            }
            
            // Dots
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

// MARK: - Preview
struct JournalView_Previews: PreviewProvider {
    static var previews: some View {
        JournalView(note: sampleNotes[0])
            .environmentObject(NoteStore())
    }
}
