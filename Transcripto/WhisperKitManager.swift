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
                print("Starting WhisperKit initialization with tiny model...")
                // Initialize WhisperKit with the tiny model, explicitly specifying download if needed
                whisperKit = try await WhisperKit(
                    model: "tiny",
                    modelFolder: nil, // Use default folder
                    verbose: true,    // Enable verbose logging for debugging
                    download: true    // Explicitly request download if needed
                )
                print("WhisperKit initialization completed!")
                isModelLoaded = true
                DispatchQueue.main.async {
                    completion(.success(()))
                }
            } catch {
                print("WhisperKit initialization failed: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }
    }
    
    /// Prepares WhisperKit for streaming transcription.
    func prepareForStreamingTranscription() async throws {
        guard !isModelLoaded else { return }
        // Initialize WhisperKit if not already loaded
        whisperKit = try await WhisperKit(model: "tiny", verbose: false, download: true)
        isModelLoaded = true
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
        
        // Save audio data to a temporary file with wav format for better compatibility
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString + ".wav")
        
        // Convert the PCM data to WAV format
        try self.saveWavFile(from: audioData, to: tempURL)
        
        // Transcribe the temporary file
        let results = try await whisperKit.transcribe(audioPath: tempURL.path)
        
        // Clean up by deleting the temporary file
        try? FileManager.default.removeItem(at: tempURL)
        
        // Combine the text from each TranscriptionResult into a single string
        let fullText = results.map { $0.text }.joined(separator: " ")
        return fullText
    }
    
    // Helper function to save PCM data as WAV file
    private func saveWavFile(from pcmData: Data, to url: URL) throws {
        // WAV header constants
        let headerSize = 44
        let formatChunkSize = 16
        let formatType = 1 // PCM
        let channels = 1 // Mono
        let sampleRate = 16000
        let bitsPerSample = 32 // 32-bit float samples
        let bytesPerSample = bitsPerSample / 8
        let byteRate = sampleRate * channels * bytesPerSample
        let blockAlign = channels * bytesPerSample
        let dataSize = pcmData.count
        let fileSize = dataSize + headerSize - 8
        
        // Create WAV header
        var header = Data(capacity: headerSize)
        
        // RIFF chunk descriptor
        header.append(contentsOf: "RIFF".utf8)
        header.append(contentsOf: withUnsafeBytes(of: UInt32(fileSize).littleEndian) { Data($0) })
        header.append(contentsOf: "WAVE".utf8)
        
        // Format chunk
        header.append(contentsOf: "fmt ".utf8)
        header.append(contentsOf: withUnsafeBytes(of: UInt32(formatChunkSize).littleEndian) { Data($0) })
        header.append(contentsOf: withUnsafeBytes(of: UInt16(formatType).littleEndian) { Data($0) })
        header.append(contentsOf: withUnsafeBytes(of: UInt16(channels).littleEndian) { Data($0) })
        header.append(contentsOf: withUnsafeBytes(of: UInt32(sampleRate).littleEndian) { Data($0) })
        header.append(contentsOf: withUnsafeBytes(of: UInt32(byteRate).littleEndian) { Data($0) })
        header.append(contentsOf: withUnsafeBytes(of: UInt16(blockAlign).littleEndian) { Data($0) })
        header.append(contentsOf: withUnsafeBytes(of: UInt16(bitsPerSample).littleEndian) { Data($0) })
        
        // Data chunk
        header.append(contentsOf: "data".utf8)
        header.append(contentsOf: withUnsafeBytes(of: UInt32(dataSize).littleEndian) { Data($0) })
        
        // Create file and write header and PCM data
        FileManager.default.createFile(atPath: url.path, contents: nil)
        let fileHandle = try FileHandle(forWritingTo: url)
        try fileHandle.write(contentsOf: header)
        try fileHandle.write(contentsOf: pcmData)
        try fileHandle.close()
    }
}
