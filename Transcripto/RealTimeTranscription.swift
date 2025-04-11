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
    
    var onTranscriptionUpdate: ((String) -> Void)?
    private var accumulatedText = ""
    
    private override init() {
        super.init()
        setupAudioEngine()
    }
    
    private func setupAudioEngine() {
        audioEngine = AVAudioEngine()
        inputNode = audioEngine?.inputNode
        
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.record, mode: .default)
            try audioSession.setActive(true)
        } catch {
            print("Error setting up audio session: \(error)")
        }
    }
    
    func startTranscribing() async {
        guard !isTranscribing, let audioEngine = audioEngine, let inputNode = inputNode else { return }
        
        // Reset accumulated text
        accumulatedText = ""
        
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
                
                // Process the converted buffer
                self.processAudioBuffer(pcmBuffer!)
            }
            
            try audioEngine.start()
            isTranscribing = true
        } catch {
            print("Error starting transcription: \(error)")
        }
    }
    
    private func processAudioBuffer(_ buffer: AVAudioPCMBuffer) {
        // Convert the PCM buffer to Data
        guard let channelData = buffer.floatChannelData?[0] else { return }
        let frameLength = Int(buffer.frameLength)
        let data = Data(bytes: channelData, count: frameLength * 4) // 4 bytes per float
        
        // Transcribe the audio chunk
        Task {
            do {
                let text = try await WhisperKitManager.shared.transcribeAudioChunk(data)
                if !text.isEmpty {
                    accumulatedText += text + " "
                    DispatchQueue.main.async {
                        self.onTranscriptionUpdate?(self.accumulatedText)
                    }
                }
            } catch {
                print("Error transcribing audio chunk: \(error)")
            }
        }
    }
    
    func stopTranscribing() -> String {
        guard isTranscribing, let audioEngine = audioEngine else { return accumulatedText }
        
        audioEngine.inputNode.removeTap(onBus: 0)
        audioEngine.stop()
        isTranscribing = false
        
        return accumulatedText
    }
}
