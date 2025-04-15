//
//  WhisperKitManager.swift
//  Transcripto
//
//  Created by Satvik Jadhav on 4/14/25. // Note: Year 2025 seems like a typo?
//

import Foundation
import WhisperKit
import AVFoundation

class WhisperKitManager {
    static let shared = WhisperKitManager()
    
    private var whisperKit: WhisperKit?
    private var isModelLoaded = false
    
    private init() {}
    
    /// Sets up WhisperKit with the default model.
    func setup(completion: @escaping (Result<Void, Error>) -> Void) {
        Task {
            do {
                // Initialize WhisperKit with default settings
                whisperKit = try await WhisperKit()
                isModelLoaded = true
                DispatchQueue.main.async {
                    completion(.success(()))
                }
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }
    }
    
    /// Transcribes an audio file from a given URL.
    func transcribeAudioFile(url: URL) async throws -> String {
        guard let whisperKit = whisperKit, isModelLoaded else {
            throw NSError(domain: "WhisperKitManager", code: 1, userInfo: [NSLocalizedDescriptionKey: "WhisperKit not initialized or model not loaded"])
        }
        
        // Transcribe the audio file, expecting an array of TranscriptionResult
        let results = try await whisperKit.transcribe(audioPath: url.path)
        
        // Combine the text from each TranscriptionResult into a single string
        let fullText = results.map { $0.text }.joined(separator: " ")
        return fullText
    }
    
    /// Transcribes an audio chunk provided as Data.
    func transcribeAudioChunk(_ audioData: Data) async throws -> String {
        guard let whisperKit = whisperKit, isModelLoaded else {
            throw NSError(domain: "WhisperKitManager", code: 1, userInfo: [NSLocalizedDescriptionKey: "WhisperKit not initialized or model not loaded"])
        }
        
        // Save audio data to a temporary file
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString + ".m4a")
        try audioData.write(to: tempURL)
        
        // Transcribe the temporary file, expecting an array of TranscriptionResult
        let results = try await whisperKit.transcribe(audioPath: tempURL.path)
        
        // Clean up by deleting the temporary file
        try FileManager.default.removeItem(at: tempURL)
        
        // Combine the text from each TranscriptionResult into a single string
        let fullText = results.map { $0.text }.joined(separator: " ")
        return fullText
    }
}
