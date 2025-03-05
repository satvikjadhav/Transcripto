import SwiftUI

struct RecordingsView: View {
    let folderName: String
    @State private var recordings = ["Voice Note 1", "Voice Note 2", "Voice Note 3"]

    var body: some View {
        VStack {
            List {
                ForEach(recordings, id: \.self) { recording in
                    HStack {
                        Text(recording)
                        Spacer()
                        Button(action: {
                            // Play recording logic
                        }) {
                            Image(systemName: "play.circle")
                                .foregroundColor(.blue)
                        }
                    }
                }
            }
            
            Spacer()
            
            HStack {
                Button(action: {
                    // Rewind logic
                }) {
                    Image(systemName: "backward.fill")
                        .font(.largeTitle)
                }
                .padding()
                
                Button(action: {
                    // Play/Pause logic
                }) {
                    Image(systemName: "play.circle.fill")
                        .font(.largeTitle)
                        .foregroundColor(.blue)
                }
                .padding()
                
                Button(action: {
                    // Stop logic
                }) {
                    Image(systemName: "trash")
                        .font(.largeTitle)
                        .foregroundColor(.red)
                }
                .padding()
            }
            
            Button(action: {
                // Start recording logic
            }) {
                Image(systemName: "mic.circle.fill")
                    .font(.system(size: 70))
                    .foregroundColor(.red)
                    .padding()
            }
        }
        .navigationTitle(folderName)
    }
}

struct RecordingsView_Previews: PreviewProvider {
    static var previews: some View {
        RecordingsView(folderName: "Sample Folder")
    }
}

