//
//  RealTimeTranscription.swift
//  Transcripto
//
//  Created by Davenport, Aidan on 4/8/25.
//


import Foundation
import AVFoundation
import WhisperKit

class RealTimeTranscription: NSObject, AVAudioRecorderDelegate {
    static let shared = RealTimeTranscription()
    
    private var audioEngine: AVAudioEngine?
    private var inputNode: AVAudioInputNode?
    private var isTranscribing = false
    
    private let bufferSize: AVAudioFrameCount = 4096
    private let sampleRate: Double = 16000
    
    // Capture buffer for accumulating audio data
    private var audioBuffer = NSMutableData()
    private let audioBufferMaxSize = 5 * 16000 * 4 // ~5 seconds of audio at 16kHz (4 bytes per float)
    private let processingInterval: TimeInterval = 2.5 // Process every 2.5 seconds (reduced from 5)
    private var lastProcessingTime: Date?
    private var isProcessing = false
    
    // Noise detection variables
    private var silenceThreshold: Float = 0.01 // Threshold to determine silence
    private var minimumAudioLevel: Float = 0.0
    private var hasSignificantAudio = false
    
    var onTranscriptionUpdate: ((String) -> Void)?
    private var accumulatedText = ""
    private var previousChunks = Set<String>() // To avoid duplicate phrases
    
    private override init() {
        super.init()
        setupAudioEngine()
    }
    
    private func setupAudioEngine() {
        audioEngine = AVAudioEngine()
        inputNode = audioEngine?.inputNode
        
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
            try audioSession.setActive(true)
        } catch {
            print("Error setting up audio session: \(error)")
        }
    }
    
    func startTranscribing() async {
        guard !isTranscribing, let audioEngine = audioEngine, let inputNode = inputNode else { return }
        
        // Reset state
        audioBuffer = NSMutableData()
        accumulatedText = ""
        previousChunks.removeAll()
        lastProcessingTime = Date()
        isProcessing = false
        hasSignificantAudio = false
        
        do {
            try await WhisperKitManager.shared.prepareForStreamingTranscription()
            
            let recordingFormat = inputNode.outputFormat(forBus: 0)
            let convertFormat = AVAudioFormat(commonFormat: .pcmFormatFloat32, sampleRate: sampleRate, channels: 1, interleaved: false)
            
            // Add a tap on the input node to get audio data
            inputNode.installTap(onBus: 0, bufferSize: bufferSize, format: recordingFormat) { [weak self] buffer, time in
                guard let self = self else { return }
                
                // Convert the buffer to the desired format
                let converter = AVAudioConverter(from: recordingFormat, to: convertFormat!)
                let pcmBuffer = AVAudioPCMBuffer(pcmFormat: convertFormat!, frameCapacity: AVAudioFrameCount(convertFormat!.sampleRate * 0.5))
                
                var error: NSError?
                let inputBlock: AVAudioConverterInputBlock = { inNumPackets, outStatus in
                    outStatus.pointee = .haveData
                    return buffer
                }
                
                converter?.convert(to: pcmBuffer!, error: &error, withInputFrom: inputBlock)
                
                if let error = error {
                    print("Conversion error: \(error)")
                    return
                }
                
                // Check audio levels to detect if there's actual speech
                if let channelData = pcmBuffer?.floatChannelData?[0], pcmBuffer!.frameLength > 0 {
                    let frameCount = Int(pcmBuffer!.frameLength)
                    var maxAmplitude: Float = 0
                    
                    // Calculate the maximum amplitude in this buffer
                    for i in 0..<frameCount {
                        let sample = abs(channelData[i])
                        if sample > maxAmplitude {
                            maxAmplitude = sample
                        }
                    }
                    
                    // Update our min level if this is significant audio
                    if maxAmplitude > self.silenceThreshold {
                        self.hasSignificantAudio = true
                        self.minimumAudioLevel = max(self.minimumAudioLevel, maxAmplitude * 0.5)
                    }
                }
                
                // Only append the buffer if it contains significant audio
                if self.hasSignificantAudio {
                    self.appendAudioBuffer(pcmBuffer!)
                }
                
                // Process the audio at regular intervals if not already processing
                if !self.isProcessing,
                   let lastTime = self.lastProcessingTime,
                   Date().timeIntervalSince(lastTime) >= self.processingInterval {
                    // Remove hasSignificantAudio check here
                    self.isProcessing = true
                    self.processAccumulatedAudio()
                    self.lastProcessingTime = Date()
                }
            }
            
            try audioEngine.start()
            isTranscribing = true
        } catch {
            print("Error starting transcription: \(error)")
        }
    }
    
    private func appendAudioBuffer(_ buffer: AVAudioPCMBuffer) {
        guard let channelData = buffer.floatChannelData?[0] else { return }
        let frameLength = Int(buffer.frameLength)
        
        // Append the new audio data to our buffer
        audioBuffer.append(channelData, length: frameLength * 4) // 4 bytes per float
        
        // If buffer is too large, trim it
        if audioBuffer.length > audioBufferMaxSize {
            let amountToTrim = audioBuffer.length - audioBufferMaxSize
            audioBuffer.replaceBytes(in: NSRange(location: 0, length: amountToTrim), withBytes: nil, length: 0)
        }
    }
    
    private func processAccumulatedAudio() {
        // Don't process if buffer is too small
        guard audioBuffer.length > 4000 else {
            self.isProcessing = false
            return
        }
        
        // Create a copy of the current buffer
        let bufferCopy = Data(bytes: audioBuffer.bytes, count: audioBuffer.length)
        
        // Reset the buffer after copying to avoid processing the same audio twice
        audioBuffer = NSMutableData()
        
        // Process the audio asynchronously
        Task {
            do {
                let text = try await WhisperKitManager.shared.transcribeAudioChunk(bufferCopy)
                if !text.isEmpty {
                    // Clean and filter the text
                    let newText = text.trimmingCharacters(in: .whitespacesAndNewlines)
                        .replacingOccurrences(of: "(engine revving)", with: "")
                        .replacingOccurrences(of: "(music)", with: "")
                        .replacingOccurrences(of: "(silence)", with: "")
                    
                    if !newText.isEmpty && !self.previousChunks.contains(newText) {
                        // Add to the set of previous chunks to avoid repetition
                        self.previousChunks.insert(newText)
                        
                        // Add to accumulated text with proper spacing
                        if !self.accumulatedText.isEmpty && !self.accumulatedText.hasSuffix(" ") {
                            self.accumulatedText += " "
                        }
                        self.accumulatedText += newText
                        
                        DispatchQueue.main.async {
                            self.onTranscriptionUpdate?(self.accumulatedText)
                        }
                    }
                }
            } catch {
                print("Error transcribing audio chunk: \(error)")
            }
            
            self.isProcessing = false
        }
    }
    
    func stopTranscribing() -> String {
        guard isTranscribing, let audioEngine = audioEngine else { return accumulatedText }
        
        // Process any remaining audio if we have enough
        if audioBuffer.length > 4000 && !isProcessing && hasSignificantAudio {
            processAccumulatedAudio()
        }
        
        audioEngine.inputNode.removeTap(onBus: 0)
        audioEngine.stop()
        isTranscribing = false
        
        // Clean up final text
        let finalText = accumulatedText.trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: "(engine revving)", with: "")
            .replacingOccurrences(of: "(music)", with: "")
            .replacingOccurrences(of: "(silence)", with: "")
        
        return finalText
    }
}
