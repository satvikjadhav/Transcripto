import SwiftUI

struct NotesListView: View {
    @ObservedObject var viewModel: TranscriptionViewModel
    @State private var searchText = ""
    
    var filteredNotes: [Note] {
        if searchText.isEmpty {
            return viewModel.notes
        } else {
            return viewModel.notes.filter { note in
                note.title.localizedCaseInsensitiveContains(searchText) ||
                note.content.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    var body: some View {
        NavigationView {
            List {
                if filteredNotes.isEmpty {
                    Text("No recordings")
                        .foregroundColor(.gray)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .listRowBackground(Color.clear)
                        .padding()
                } else {
                    ForEach(filteredNotes) { note in
                        NavigationLink(destination: NoteDetailView(note: note, viewModel: viewModel)) {
                            NoteRowView(note: note)
                        }
                    }
                    .onDelete(perform: viewModel.deleteNote)
                }
            }
            .listStyle(InsetGroupedListStyle())
            .navigationTitle("All Recordings")
            .searchable(text: $searchText, prompt: "Search recordings")
            .toolbar {
                EditButton()
            }
            .onAppear {
                viewModel.loadNotes()
            }
        }
    }
}

struct NoteRowView: View {
    let note: Note
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(note.title)
                .font(.headline)
                .lineLimit(1)
            
            HStack {
                WaveformIconView()
                    .frame(width: 40, height: 20)
                    .foregroundColor(.gray)
                
                Text(formattedDuration(for: note))
                    .font(.caption)
                    .foregroundColor(.gray)
                
                Spacer()
                
                Text(formattedDate(note.dateCreated))
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
        .padding(.vertical, 4)
    }
    
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter.string(from: date)
    }
    
    // This is a placeholder - in a real app, you'd store the duration with each recording
    private func formattedDuration(for note: Note) -> String {
        // Calculate a pseudo-random duration based on content length
        let minutes = Int(note.content.count / 100) % 10
        let seconds = Int(note.content.count / 10) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}

struct WaveformIconView: View {
    var body: some View {
        HStack(alignment: .center, spacing: 2) {
            ForEach(0..<5) { i in
                RoundedRectangle(cornerRadius: 1)
                    .frame(width: 2, height: CGFloat(5 + i * 2))
            }
            ForEach(0..<3) { i in
                RoundedRectangle(cornerRadius: 1)
                    .frame(width: 2, height: CGFloat(14 - i * 2))
            }
            ForEach(0..<4) { i in
                RoundedRectangle(cornerRadius: 1)
                    .frame(width: 2, height: CGFloat(10 - i * 2))
            }
        }
    }
}
