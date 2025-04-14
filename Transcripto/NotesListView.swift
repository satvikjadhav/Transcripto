import SwiftUI

struct NotesListView: View {
    @ObservedObject var viewModel: TranscriptionViewModel
    
    var body: some View {
        NavigationView {
            List {
                ForEach(viewModel.notes) { note in
                    NavigationLink(destination: NoteDetailView(note: note, viewModel: viewModel)) {
                        VStack(alignment: .leading) {
                            Text(note.title)
                                .font(.headline)
                            Text(note.content.prefix(100) + (note.content.count > 100 ? "..." : ""))
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            Text(note.dateModified, style: .date)
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    }
                }
                .onDelete(perform: viewModel.deleteNote)
            }
            .listStyle(InsetGroupedListStyle())
            .navigationTitle("Transcription Notes")
            .onAppear {
                viewModel.loadNotes()
            }
        }
    }
}
