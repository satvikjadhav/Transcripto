import SwiftUI
import AVFoundation

struct RecordingsView: View {
    let folderName: String
    @State private var recordings: [String] = ["Voice Note 1", "Voice Note 2", "Voice Note 3"] // Now using names rather than URLs
    @StateObject private var audioRecorder = AudioRecorder()
    
    var body: some View {
        VStack {
            List {
                ForEach(recordings, id: \.self) { recording in
                    HStack {
                        Text(recording)
                        Spacer()
                        Button(action: {
                            // Playback logic can be implemented here
                        }) {
                            Image(systemName: "play.circle")
                                .foregroundColor(.blue)
                        }
                    }
                }
            }
            
            Spacer()
            
            // Playback controls (if needed)
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
                    // Stop logic for playback (if needed)
                }) {
                    Image(systemName: "trash")
                        .font(.largeTitle)
                        .foregroundColor(.red)
                }
                .padding()
            }
            
            // Record button: toggles recording on/off with a consistent circular icon
            Button(action: {
                if audioRecorder.isRecording {
                    audioRecorder.stopRecording()
                } else {
                    audioRecorder.startRecording()
                }
            }) {
                Image(systemName: audioRecorder.isRecording ? "stop.circle.fill" : "mic.circle.fill")
                    .font(.system(size: 70))
                    .foregroundColor(.red)
                    .padding()
            }
            
            if audioRecorder.isRecording {
                Text("Recording...")
                    .foregroundColor(.red)
                    .padding(.top, 5)
            }
        }
        .navigationTitle(folderName)
        // When a new recording finishes, update the recordings list with a custom name.
        .onReceive(audioRecorder.$lastRecordingURL) { newURL in
            if newURL != nil {
                // Instead of using the URL, we generate a name like "Voice Note X"
                let newName = "Voice Note \(recordings.count + 1)"
                recordings.append(newName)
            }
        }
    }
}

struct RecordingsView_Previews: PreviewProvider {
    static var previews: some View {
        RecordingsView(folderName: "Sample Folder")
    }
}
