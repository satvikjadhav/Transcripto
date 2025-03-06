import SwiftUI
import AVFoundation  // Needed for AVAudioSession and related classes

struct RecordingsView: View {
    let folderName: String
    @State private var recordings = ["Voice Note 1", "Voice Note 2", "Voice Note 3"]
    
    // Instantiate the audio recorder as a state object
    @StateObject private var audioRecorder = AudioRecorder()
    
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
            
            // Additional playback controls (if needed)
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
                    // Stop logic (if you want to stop playback)
                }) {
                    Image(systemName: "trash")
                        .font(.largeTitle)
                        .foregroundColor(.red)
                }
                .padding()
            }
            
            // Recording button: toggles start and stop recording
            Button(action: {
                if audioRecorder.isRecording {
                    audioRecorder.stopRecording()
                } else {
                    audioRecorder.startRecording()
                }
            }) {
                // Change icon based on recording state
                Image(systemName: audioRecorder.isRecording ? "stop.fill" : "mic.circle.fill")
                    .font(.system(size: 70))
                    .foregroundColor(audioRecorder.isRecording ? .gray : .red)
                    .padding()
            }
            
            // Optionally display recording status text
            if audioRecorder.isRecording {
                Text("Recording...")
                    .foregroundColor(.red)
                    .padding(.top, 5)
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
