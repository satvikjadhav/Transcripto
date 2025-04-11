// AudioRecorder.swift
import Foundation
import AVFoundation

class AudioRecorder: NSObject, AVAudioRecorderDelegate {
    static let shared = AudioRecorder()
    
    private var audioRecorder: AVAudioRecorder?
    private var audioFilename: URL?
    
    var isRecording = false
    var recordingCompletion: ((URL?) -> Void)?
    
    private override init() {
        super.init()
        setupAudioSession()
    }
    
    private func setupAudioSession() {
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.playAndRecord, mode: .default)
            try audioSession.setActive(true)
        } catch {
            print("Failed to set up audio session: \(error)")
        }
    }
    
    func requestPermissions(completion: @escaping (Bool) -> Void) {
        AVAudioSession.sharedInstance().requestRecordPermission { granted in
            DispatchQueue.main.async {
                completion(granted)
            }
        }
    }
    
    func startRecording(completion: @escaping (Bool) -> Void) {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        audioFilename = documentsDirectory.appendingPathComponent("recording-\(Date().timeIntervalSince1970).m4a")
        
        guard let audioFilename = audioFilename else {
            completion(false)
            return
        }
        
        let settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 44100,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        
        do {
            audioRecorder = try AVAudioRecorder(url: audioFilename, settings: settings)
            audioRecorder?.delegate = self
            audioRecorder?.record()
            isRecording = true
            completion(true)
        } catch {
            print("Could not start recording: \(error)")
            completion(false)
        }
    }
    
    func stopRecording() {
        audioRecorder?.stop()
        isRecording = false
        recordingCompletion?(audioFilename)
    }
    
    // AVAudioRecorderDelegate methods
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if !flag {
            recordingCompletion?(nil)
        }
    }
}