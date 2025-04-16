//
//  ContentView.swift
//  Transcripto
//
//  Created by Lakshmi Tulasi Ummadipolu on 3/4/25.
//

//import SwiftUI
//
//// class AudioTranscriber....
//
//struct ContentView: View {
//    @State private var folders: [String] = []  // Start with an empty list
//    @State private var newFolderName = ""     // Stores the folder name for input
//    @State private var showAddFolderSheet = false // Controls sheet visibility
//    @State private var editingFolderIndex: Int? // Keeps track of which folder is being edited
//    @State private var showAlert = false      // Controls alert visibility for duplicate names
//    @State private var alertMessage = ""      // Stores the alert message
//
//    var body: some View {
//        NavigationView {
//            VStack {
//                if folders.isEmpty {
//                    Text("No folders available. Click + to create one.")
//                        .foregroundColor(.gray)
//                        .padding()
//                } else {
//                    List {
//                        ForEach(folders.indices, id: \.self) { index in
//                            HStack {
//                                NavigationLink(destination: RecordingsView(folderName: folders[index])) {
//                                    Text(folders[index])
//                                        .font(.headline)
//                                }
//                                Spacer()
//                                
//                                // Rename Button
//                                Button(action: {
//                                    startEditingFolder(index: index)
//                                }) {
//                                    Image(systemName: "pencil")
//                                        .foregroundColor(.blue)
//                                }
//                                .padding(.trailing, 10)
//
//                                // Delete Button
//                                Button(action: {
//                                    deleteFolder(index: index)
//                                }) {
//                                    Image(systemName: "trash")
//                                        .foregroundColor(.red)
//                                }
//                            }
//                        }
//                        .onDelete(perform: deleteAtOffsets) // Enable swipe-to-delete
//                    }
//                }
//                
//                Spacer()
//                
//                // Button to add a new folder
//                Button(action: {
//                    newFolderName = ""  // Reset input
//                    editingFolderIndex = nil
//                    showAddFolderSheet = true
//                }) {
//                    Image(systemName: "plus")
//                        .font(.largeTitle)
//                        .frame(width: 60, height: 60)
//                        .background(Color.blue)
//                        .foregroundColor(.white)
//                        .clipShape(Circle())
//                        .padding()
//                }
//                .sheet(isPresented: $showAddFolderSheet) {
//                    FolderInputView(
//                        folderName: $newFolderName,
//                        isPresented: $showAddFolderSheet,
//                        saveAction: saveFolder
//                    )
//                }
//            }
//            .navigationTitle("Voice Folders")
//            .alert(isPresented: $showAlert) {
//                Alert(title: Text("Error"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
//            }
//        }
//    }
//    
//    // Start Editing a Folder (Prepares Name)
//    private func startEditingFolder(index: Int) {
//        newFolderName = folders[index]
//        editingFolderIndex = index
//        showAddFolderSheet = true
//    }
//
//    // Add or Rename a Folder
//    private func saveFolder() {
//        guard !newFolderName.isEmpty else { return }
//        
//        if folders.contains(newFolderName) && editingFolderIndex == nil {
//            alertMessage = "A folder with this name already exists."
//            showAlert = true
//            return
//        }
//        
//        if let index = editingFolderIndex {
//            if folders[index] != newFolderName && folders.contains(newFolderName) {
//                alertMessage = "A folder with this name already exists."
//                showAlert = true
//                return
//            }
//            folders[index] = newFolderName // Rename existing folder
//        } else {
//            folders.append(newFolderName) // Add a new folder
//        }
//        
//        newFolderName = ""
//        editingFolderIndex = nil
//    }
//
//    // Delete a Folder
//    private func deleteFolder(index: Int) {
//        folders.remove(at: index)
//    }
//
//    // Delete Folder Using Swipe Action
//    private func deleteAtOffsets(offsets: IndexSet) {
//        folders.remove(atOffsets: offsets)
//    }
//}
//
//// Updated Folder Input Sheet UI
//struct FolderInputView: View {
//    @Binding var folderName: String
//    @Binding var isPresented: Bool
//    var saveAction: () -> Void
//
//    var body: some View {
//        NavigationView {
//            VStack(spacing: 20) {
//                Text("Enter Folder Name")
//                    .font(.headline)
//                    .padding(.top, 20)
//                
//                TextField("Folder Name", text: $folderName)
//                    .textFieldStyle(RoundedBorderTextFieldStyle())
//                    .padding(.horizontal, 20)
//                    .padding(.top, 10)
//
//                Spacer()
//
//                HStack {
//                    Button(action: {
//                        isPresented = false  // Close the sheet only
//                    }) {
//                        Text("Cancel")
//                            .foregroundColor(.red)
//                            .padding()
//                    }
//
//                    Spacer()
//
//                    Button(action: {
//                        saveAction()
//                        isPresented = false
//                    }) {
//                        Text("Save")
//                            .fontWeight(.bold)
//                            .foregroundColor(folderName.isEmpty ? .gray : .blue)
//                    }
//                    .disabled(folderName.isEmpty)
//                    .padding()
//                }
//                .padding(.bottom, 20)
//            }
//            .navigationTitle(folderName.isEmpty ? "New Folder" : "Rename Folder")
//            .padding()
//        }
//    }
//}

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = TranscriptionViewModel()
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            RecordingView(viewModel: viewModel)
                .tabItem {
                    Label("Record", systemImage: "waveform")
                }
                .tag(0)
            
            NotesListView(viewModel: viewModel)
                .tabItem {
                    Label("Notes", systemImage: "list.bullet")
                }
                .tag(1)
        }
        .accentColor(.red)
        .onAppear {
            // Request recording permissions when app launches
            viewModel.requestRecordingPermission { granted in
                if !granted {
                    print("Recording permission denied")
                }
            }
        }
    }
}

struct RecordingView: View {
    @ObservedObject var viewModel: TranscriptionViewModel
    @State private var showingAlert = false
    @State private var alertMessage = ""
    @State private var animateWaveform = false
    
    var body: some View {
        NavigationView {
            VStack {
                // Transcription content area
                ZStack {
                    // Background
                    Color(.systemGray6)
                        .cornerRadius(12)
                        .shadow(radius: 3)
                    
                    VStack {
                        // Mode selector at top
                        Picker("Mode", selection: $viewModel.isRealTimeMode) {
                            Text("Recording").tag(false)
                            Text("Real-time").tag(true)
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        .padding(.horizontal, 20)
                        .padding(.top, 20)
                        
                        // Visualization / Waveform
                        ZStack {
                            if viewModel.state == .recording || viewModel.state == .transcribing {
                                // Simple waveform visualization
                                HStack(spacing: 4) {
                                    ForEach(0..<10, id: \.self) { i in
                                        RoundedRectangle(cornerRadius: 2)
                                            .fill(Color.red)
                                            .frame(width: 3, height: CGFloat.random(in: 10...40))
                                            .animation(
                                                Animation.easeInOut(duration: 0.2)
                                                    .repeatForever()
                                                    .delay(Double(i) * 0.05),
                                                value: animateWaveform
                                            )
                                    }
                                }
                                .padding(.vertical, 30)
                                .onAppear { animateWaveform = true }
                                .onDisappear { animateWaveform = false }
                            } else {
                                Image(systemName: "waveform")
                                    .font(.system(size: 50))
                                    .foregroundColor(.gray)
                                    .padding(.vertical, 30)
                            }
                        }
                        
                        // Status indicator
                        Text(statusText)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .padding(.bottom, 8)
                        
                        // Transcription text display
                        ScrollView {
                            Text(viewModel.transcriptionText.isEmpty ? "Transcription will appear here" : viewModel.transcriptionText)
                                .padding()
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .foregroundColor(viewModel.transcriptionText.isEmpty ? .gray : .primary)
                        }
                        .frame(maxHeight: .infinity)
                        
                        // Save note controls (only when completed)
                        if viewModel.state == .completed {
                            VStack(spacing: 12) {
                                TextField("Note Title", text: $viewModel.currentNoteTitle)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .padding(.horizontal)
                                
                                Button("Save Note") {
                                    viewModel.saveTranscriptionAsNote()
                                }
                                .buttonStyle(.borderedProminent)
                                .tint(.red)
                                .padding(.bottom)
                            }
                            .padding(.horizontal)
                            .transition(.opacity)
                        }
                    }
                }
                .padding()
                
                // Recording controls
                recordingControlsView
                    .padding(.bottom, 40)
            }
            .navigationTitle("Transcripto")
            .alert(isPresented: $showingAlert) {
                Alert(title: Text("Error"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
            }
            .onChange(of: viewModel.state) { newState in
                if case .error(let message) = newState {
                    alertMessage = message
                    showingAlert = true
                }
            }
            .background(Color(.systemBackground))
        }
    }
    
    private var statusText: String {
        switch viewModel.state {
        case .idle: return "Ready to record"
        case .loading: return "Loading model..."
        case .recording: return "Recording..."
        case .transcribing: return "Transcribing..."
        case .completed: return "Transcription completed"
        case .error: return "Error occurred"
        }
    }
    
    private var recordingControlsView: some View {
        ZStack {
            // Outer circle for visual effect
            Circle()
                .fill(Color(.systemGray6))
                .frame(width: 80, height: 80)
            
            // Record/Stop button
            Button(action: {
                if viewModel.isRealTimeMode {
                    if viewModel.state == .transcribing {
                        viewModel.stopRealTimeTranscription()
                    } else {
                        viewModel.startRealTimeTranscription()
                    }
                } else {
                    if viewModel.state == .recording {
                        viewModel.stopRecordingAndTranscribe()
                    } else {
                        viewModel.startRecording()
                    }
                }
            }) {
                ZStack {
                    Circle()
                        .fill(viewModel.state == .recording || viewModel.state == .transcribing ? Color.red : Color.white)
                        .frame(width: 70, height: 70)
                        .shadow(radius: 3)
                    
                    if viewModel.state == .recording || viewModel.state == .transcribing {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.white)
                            .frame(width: 20, height: 20)
                    }
                }
            }
            .disabled(viewModel.state == .loading || viewModel.state == .transcribing && !viewModel.isRealTimeMode)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
