// ContentView.swift
import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = TranscriptionViewModel()
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            TranscriptionView(viewModel: viewModel)
                .tabItem {
                    Label("Transcribe", systemImage: "waveform")
                }
                .tag(0)
            
            NotesListView(viewModel: viewModel)
                .tabItem {
                    Label("Notes", systemImage: "note.text")
                }
                .tag(1)
        }
        .onAppear {
            // Request permissions when the app starts
            viewModel.requestRecordingPermission { granted in
                if !granted {
                    print("Microphone permission denied")
                }
            }
        }
    }
}
