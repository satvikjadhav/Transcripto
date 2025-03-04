//
//  ContentView.swift
//  Transcripto
//
//  Created by Satvik  Jadhav on 2/25/25.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var audioRecorder = AudioRecorder() // Create an instance

    var body: some View {
        NavigationView {
            VStack {
                Spacer()

                Button(action: {
                    if audioRecorder.isRecording {
                        audioRecorder.stopRecording()
                    } else {
                        audioRecorder.startRecording()
                    }
                }) {
                    ZStack {
                        Circle()
                            .frame(width: 100, height: 100)
                            .foregroundColor(audioRecorder.isRecording ? .red : .blue) // Change color

                        Image(systemName: audioRecorder.isRecording ? "stop.fill" : "mic.fill")
                            .font(.system(size: 40))
                            .foregroundColor(.white)
                    }
                }

                Spacer()

                Text(audioRecorder.isRecording ? "Recording..." : "Tap to Record") // Status text
                    .font(.title2)
                    .padding()
            }
            .navigationTitle("Transcription App")
        }
    }
}

#Preview {
    ContentView()
}
