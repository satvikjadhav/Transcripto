import SwiftUI

struct NoteDetailView: View {
    let note: Note
    @ObservedObject var viewModel: TranscriptionViewModel
    @State private var editedTitle: String
    @State private var editedContent: String
    @State private var isEditing = false
    @Environment(\.presentationMode) var presentationMode
    
    init(note: Note, viewModel: TranscriptionViewModel) {
        self.note = note
        self.viewModel = viewModel
        self._editedTitle = State(initialValue: note.title)
        self._editedContent = State(initialValue: note.content)
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                if isEditing {
                    TextField("Title", text: $editedTitle)
                        .font(.title)
                        .padding(.bottom)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    TextEditor(text: $editedContent)
                        .frame(minHeight: 200)
                        .padding(4)
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                } else {
                    Text(note.title)
                        .font(.title)
                        .padding(.bottom)
                    
                    Text(note.content)
                        .font(.body)
                }
                
                Spacer()
            }
            .padding()
        }
        .navigationTitle(isEditing ? "Edit Note" : "Note Details")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(isEditing ? "Save" : "Edit") {
                    if isEditing {
                        // Save changes
                        if let updatedNote = NotesManager.shared.updateNote(
                            id: note.id,
                            title: editedTitle,
                            content: editedContent
                        ) {
                            // Update the note in the viewModel
                            if let index = viewModel.notes.firstIndex(where: { $0.id == updatedNote.id }) {
                                viewModel.notes[index] = updatedNote
                            }
                            isEditing = false
                        }
                    } else {
                        isEditing = true
                    }
                }
            }
        }
    }
}
