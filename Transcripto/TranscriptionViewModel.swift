import Foundation
import Combine
import SwiftUI

enum TranscriptionState {
    case idle
    case loading
    case recording
    case transcribing
    case completed
    case error(String)
}

class TranscriptionViewModel: ObservableObject {
    @Published var transcriptionText = ""
    @Published var state: TranscriptionState = .idle
    @Published var notes: [Note] = []
    @Published var isRealTimeMode = false
    @Published var currentNoteTitle = ""
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        setupWhisperKit()
        loadNotes()
    }
    
    func setupWhisperKit() {
        state = .loading
        
//        WhisperKitManager.shared.setup { [weak self] result in
//            guard let self = self else { return }
//            
//            switch result {
//            case .success:
//                self.state = .idle
//            case .failure(let error):
//                self.state = .error("Failed to initialize WhisperKit: \(error.localizedDescription)")
//            }
//        }
        
        WhisperKitManager.shared.setup { result in
            switch result {
            case .success:
                print("WhisperKit setup complete.")
            case .failure(let error):
                print("Setup failed: \(error)")
            }
        }
    }
    
    func loadNotes() {
        notes = NotesManager.shared.getAllNotes()
    }
    
    func requestRecordingPermission(completion: @escaping (Bool) -> Void) {
        AudioRecorder.shared.requestPermissions(completion: completion)
    }
    
    // For recorded audio transcription
    func startRecording() {
        AudioRecorder.shared.startRecording { [weak self] success in
            guard let self = self else { return }
            
            if success {
                self.state = .recording
            } else {
                self.state = .error("Failed to start recording")
            }
        }
    }
    
    func stopRecordingAndTranscribe() {
        guard case .recording = state else { return }
        
        state = .transcribing
        transcriptionText = ""
        
        AudioRecorder.shared.recordingCompletion = { [weak self] url in
            guard let self = self, let url = url else {
                self?.state = .error("Recording failed")
                return
            }
            
            self.transcribeRecordedAudio(url: url)
        }
        
        AudioRecorder.shared.stopRecording()
    }
    
    private func transcribeRecordedAudio(url: URL) {
        Task {
            do {
                let text = try await WhisperKitManager.shared.transcribeAudioFile(url: url)
                await MainActor.run {
                    self.transcriptionText = text
                    self.state = .completed
                }
            } catch {
                await MainActor.run {
                    self.state = .error("Transcription failed: \(error.localizedDescription)")
                }
            }
        }
    }
    
    // For real-time transcription
    func startRealTimeTranscription() {
        transcriptionText = ""
        state = .transcribing
        isRealTimeMode = true
        
        RealTimeTranscription.shared.onTranscriptionUpdate = { [weak self] text in
            guard let self = self else { return }
            self.transcriptionText = text
        }
        
        Task {
            await RealTimeTranscription.shared.startTranscribing()
        }
    }
    
    func stopRealTimeTranscription() {
        if isRealTimeMode, case .transcribing = state {
            let finalText = RealTimeTranscription.shared.stopTranscribing()
            transcriptionText = finalText
            state = .completed
            isRealTimeMode = false
        }
    }
    
    // Save transcription as a note
    func saveTranscriptionAsNote() {
        guard !transcriptionText.isEmpty else { return }
        
        let title = currentNoteTitle.isEmpty ? "Transcription \(Date())" : currentNoteTitle
        let newNote = NotesManager.shared.saveNote(title: title, content: transcriptionText)
        notes.append(newNote)
        currentNoteTitle = ""
        
        // Reset after saving
        state = .idle
        transcriptionText = ""
    }
    
    func deleteNote(at indexSet: IndexSet) {
        for index in indexSet {
            let note = notes[index]
            if NotesManager.shared.deleteNote(id: note.id) {
                notes.remove(at: index)
            }
        }
    }
}
