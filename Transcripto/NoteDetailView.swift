import SwiftUI

struct NoteDetailView: View {
    let note: Note
    @ObservedObject var viewModel: TranscriptionViewModel
    @State private var editedTitle: String
    @State private var editedContent: String
    @State private var isEditing = false
    @Environment(\.presentationMode) var presentationMode
    @State private var showDeleteConfirmation = false
    
    init(note: Note, viewModel: TranscriptionViewModel) {
        self.note = note
        self.viewModel = viewModel
        self._editedTitle = State(initialValue: note.title)
        self._editedContent = State(initialValue: note.content)
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Waveform visualization at top
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(.systemGray6))
                        .frame(height: 100)
                    
                    DetailWaveformView()
                        .frame(height: 60)
                        .foregroundColor(.red)
                        .padding(.horizontal, 20)
                }
                .padding(.horizontal)
                
                // Content section
                VStack(alignment: .leading, spacing: 15) {
                    if isEditing {
                        TextField("Title", text: $editedTitle)
                            .font(.title2)
                            .fontWeight(.bold)
                            .padding(.horizontal)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                        
                        TextEditor(text: $editedContent)
                            .frame(minHeight: 200)
                            .padding(8)
                            .background(Color(.systemGray6))
                            .cornerRadius(8)
                            .padding(.horizontal)
                    } else {
                        Text(note.title)
                            .font(.title2)
                            .fontWeight(.bold)
                            .padding(.horizontal)
                        
                        Text(dateFormatter.string(from: note.dateCreated))
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .padding(.horizontal)
                        
                        Text(note.content)
                            .font(.body)
                            .padding(.horizontal)
                    }
                }
                
                Spacer()
            }
            .padding(.vertical)
        }
        .navigationTitle(isEditing ? "Edit Recording" : "Recording")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                if isEditing {
                    Button("Save") {
                        saveChanges()
                    }
                } else {
                    Menu {
                        Button(action: {
                            isEditing = true
                        }) {
                            Label("Edit", systemImage: "pencil")
                        }
                        
                        Button(role: .destructive, action: {
                            showDeleteConfirmation = true
                        }) {
                            Label("Delete", systemImage: "trash")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
            }
            
            if isEditing {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        isEditing = false
                        editedTitle = note.title
                        editedContent = note.content
                    }
                }
            }
        }
        .alert("Delete Recording", isPresented: $showDeleteConfirmation) {
            Button("Delete", role: .destructive) {
                deleteNote()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Are you sure you want to permanently delete this recording?")
        }
    }
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }
    
    private func saveChanges() {
        if let updatedNote = NotesManager.shared.updateNote(
            id: note.id,
            title: editedTitle,
            content: editedContent
        ) {
            if let index = viewModel.notes.firstIndex(where: { $0.id == updatedNote.id }) {
                viewModel.notes[index] = updatedNote
            }
            isEditing = false
        }
    }
    
    private func deleteNote() {
        if NotesManager.shared.deleteNote(id: note.id) {
            if let index = viewModel.notes.firstIndex(where: { $0.id == note.id }) {
                viewModel.notes.remove(at: index)
            }
            presentationMode.wrappedValue.dismiss()
        }
    }
}

// A more detailed waveform for the detail view
struct DetailWaveformView: View {
    var body: some View {
        GeometryReader { geometry in
            HStack(alignment: .center, spacing: 3) {
                ForEach(0..<Int(geometry.size.width / 5), id: \.self) { index in
                    let height = self.waveformHeight(at: index, maxHeight: geometry.size.height)
                    RoundedRectangle(cornerRadius: 1.5)
                        .frame(width: 2, height: height)
                }
            }
        }
    }
    
    private func waveformHeight(at index: Int, maxHeight: CGFloat) -> CGFloat {
        // Create a semi-random waveform pattern
        let baseHeight = maxHeight * 0.3
        let maxVariation = maxHeight * 0.6
        
        let variation = sin(Double(index) * 0.3) + cos(Double(index) * 0.2) + sin(Double(index) * 0.1)
        let normalizedVariation = (variation + 3) / 6  // Normalize to 0-1 range
        
        return baseHeight + CGFloat(normalizedVariation) * maxVariation
    }
}
