import SwiftUI

struct TranscriptionView: View {
    @ObservedObject var viewModel: TranscriptionViewModel
    @State private var showingAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        NavigationView {
            VStack {
                // Mode selector
                Picker("Transcription Mode", selection: $viewModel.isRealTimeMode) {
                    Text("File Transcription").tag(false)
                    Text("Real-time Transcription").tag(true)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()
                
                // Status display
                statusView
                
                // Transcription text display
                ScrollView {
                    Text(viewModel.transcriptionText)
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .frame(maxHeight: .infinity)
                .background(Color(.secondarySystemBackground))
                .cornerRadius(8)
                .padding()
                
                // Save controls (visible when transcription is complete)
                if viewModel.state == .completed {
                    HStack {
                        TextField("Note Title", text: $viewModel.currentNoteTitle)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                        
                        Button("Save Note") {
                            viewModel.saveTranscriptionAsNote()
                        }
                        .buttonStyle(.borderedProminent)
                    }
                    .padding()
                }
                
                // Record/Stop controls
                controlsView
            }
            .navigationTitle("Audio Transcription")
            .alert(isPresented: $showingAlert) {
                Alert(title: Text("Error"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
            }
            .onChange(of: viewModel.state) { newState in
                if case .error(let message) = newState {
                    alertMessage = message
                    showingAlert = true
                }
            }
        }
    }
    
    private var statusView: some View {
        HStack {
            switch viewModel.state {
            case .idle:
                Label("Ready", systemImage: "checkmark.circle")
                    .foregroundColor(.green)
            case .loading:
                Label("Loading model...", systemImage: "arrow.clockwise")
                    .foregroundColor(.orange)
            case .recording:
                Label("Recording...", systemImage: "mic.fill")
                    .foregroundColor(.red)
            case .transcribing:
                Label("Transcribing...", systemImage: "text.bubble")
                    .foregroundColor(.blue)
            case .completed:
                Label("Completed", systemImage: "checkmark.circle.fill")
                    .foregroundColor(.green)
            case .error:
                Label("Error", systemImage: "exclamationmark.triangle")
                    .foregroundColor(.red)
            }
        }
        .padding()
    }
    
    private var controlsView: some View {
        HStack(spacing: 20) {
            if viewModel.isRealTimeMode {
                // Real-time transcription controls
                switch viewModel.state {
                case .idle, .completed, .error:
                    Button(action: {
                        viewModel.startRealTimeTranscription()
                    }) {
                        Label("Start", systemImage: "mic.fill")
                            .frame(minWidth: 100)
                    }
                    .buttonStyle(.borderedProminent)
                    
                case .transcribing:
                    Button(action: {
                        viewModel.stopRealTimeTranscription()
                    }) {
                        Label("Stop", systemImage: "stop.fill")
                            .frame(minWidth: 100)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.red)
                    
                default:
                    EmptyView()
                }
            } else {
                // File transcription controls
                switch viewModel.state {
                case .idle, .completed, .error:
                    Button(action: {
                        viewModel.startRecording()
                    }) {
                        Label("Record", systemImage: "record.circle")
                            .frame(minWidth: 100)
                    }
                    .buttonStyle(.borderedProminent)
                    
                case .recording:
                    Button(action: {
                        viewModel.stopRecordingAndTranscribe()
                    }) {
                        Label("Stop", systemImage: "stop.fill")
                            .frame(minWidth: 100)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.red)
                    
                default:
                    EmptyView()
                }
            }
        }
        .padding()
    }
}
