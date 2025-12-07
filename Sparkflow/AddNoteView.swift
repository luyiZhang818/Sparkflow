import SwiftUI

enum InputMode: String, CaseIterable {
    case type = "Type"
    case record = "Record"
}

struct AddNoteView: View {
    @EnvironmentObject var noteStore: NoteStore
    @Environment(\.presentationMode) var presentationMode

    @State private var title = ""
    @State private var content = ""
    @State private var tagInput = ""
    @State private var tags: [String] = []
    @State private var inputMode: InputMode = .type
    @FocusState private var isContentFocused: Bool
    
    // Formatted current date
    private var currentDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, d MMMM"
        return formatter.string(from: Date())
    }

    var body: some View {
        ZStack {
            // Dark Background
            Color(hex: "0a0a0a").ignoresSafeArea()
            
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
                    .disabled(title.isEmpty && content.isEmpty)
                    .opacity(title.isEmpty && content.isEmpty ? 0.5 : 1)
                }
                .padding(.horizontal, 24)
                .padding(.top, 16)
                
                // Date
                Text(currentDate)
                    .font(.system(size: 13, weight: .regular))
                    .foregroundColor(Theme.textMuted)
                    .padding(.top, 20)
                
                // Title
                Text("Here, your dreams\ncome to life")
                    .font(.custom("PlayfairDisplay-Regular", size: 28))
                    .multilineTextAlignment(.center)
                    .foregroundColor(Theme.textPrimary)
                    .padding(.top, 8)
                    .padding(.bottom, 32)
                
                // Book/Journal Card
                VStack(spacing: 0) {
                    // Title Input
                    TextField("Title", text: $title)
                        .font(.custom("PlayfairDisplay-Regular", size: 20))
                        .foregroundColor(Theme.textDark)
                        .padding(.horizontal, 24)
                        .padding(.top, 24)
                        .padding(.bottom, 12)
                    
                    Divider()
                        .background(Color(hex: "d4d0c8"))
                        .padding(.horizontal, 24)
                    
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
                                    .onSubmit {
                                        addTag()
                                    }
                                
                                Button(action: addTag) {
                                    Image(systemName: "plus")
                                        .font(.system(size: 10, weight: .bold))
                                        .foregroundColor(Color(hex: "8c7b64"))
                                }
                            }
                        }
                        .padding(.horizontal, 24)
                        .padding(.vertical, 12)
                    }
                    
                    // Content Input
                    TextEditor(text: $content)
                        .font(.custom("Georgia", size: 16))
                        .foregroundColor(Theme.textDark)
                        .scrollContentBackground(.hidden)
                        .background(Color.clear)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 12)
                        .focused($isContentFocused)
                        .frame(maxHeight: .infinity)
                    
                    // Placeholder when empty
                    if content.isEmpty && !isContentFocused {
                        Text("Write your thoughts here...")
                            .font(.custom("Georgia", size: 16))
                            .italic()
                            .foregroundColor(Color(hex: "a8a29e"))
                            .padding(.horizontal, 24)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .allowsHitTesting(false)
                    }
                }
                .frame(maxWidth: .infinity)
                .frame(height: 380)
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
                
                // Instruction Text
                Text("Add a dream by simply recording a\nvoice message or typing it out")
                    .font(.system(size: 13))
                    .multilineTextAlignment(.center)
                    .foregroundColor(Theme.textMuted)
                    .padding(.bottom, 16)
                
                // Input Mode Selector (Record / Type)
                HStack(spacing: 0) {
                    ForEach(InputMode.allCases, id: \.self) { mode in
                        Button(action: { inputMode = mode }) {
                            HStack(spacing: 8) {
                                Image(systemName: mode == .record ? "mic" : "character.cursor.ibeam")
                                    .font(.system(size: 16))
                                Text(mode.rawValue)
                                    .font(.system(size: 14, weight: .medium))
                            }
                            .foregroundColor(inputMode == mode ? .white : Theme.textMuted)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(inputMode == mode ? Color.white.opacity(0.1) : Color.clear)
                            )
                        }
                    }
                }
                .padding(4)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color(hex: "292524"))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.white.opacity(0.08), lineWidth: 1)
                )
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
            }
        }
        .onTapGesture {
            // Dismiss keyboard when tapping outside
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        }
    }
    
    private func addTag() {
        let trimmed = tagInput.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        if !trimmed.isEmpty && !tags.contains(trimmed) {
            tags.append(trimmed)
            tagInput = ""
        }
    }

    private func saveNote() {
        let newNote = Note(
            title: title.isEmpty ? "Untitled" : title,
            content: content,
            tags: tags,
            createdAt: Date()
        )
        noteStore.notes.insert(newNote, at: 0)
        noteStore.save()
    }
}

struct AddNoteView_Previews: PreviewProvider {
    static var previews: some View {
        AddNoteView()
            .environmentObject(NoteStore())
    }
}
