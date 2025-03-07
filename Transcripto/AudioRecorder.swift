import AVFoundation
import Combine

class AudioRecorder: NSObject, ObservableObject, AVAudioRecorderDelegate {
    @Published var isRecording = false  // For UI updates
    @Published var lastRecordingURL: URL? = nil  // New published property for the finished recording

    private var audioRecorder: AVAudioRecorder?
    private var recordingURL: URL?
    
    // Generate a unique file URL for each recording.
    private func generateRecordingURL() -> URL {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd-HHmmss"
        let fileName = "recording-\(formatter.string(from: Date())).wav"
        return documentsDirectory.appendingPathComponent(fileName)
    }
    
    func startRecording() {
        let session = AVAudioSession.sharedInstance()
        
        do {
            try session.setCategory(.playAndRecord, mode: .default)
            try session.setActive(true)
            
            recordingURL = generateRecordingURL()  // Use a unique URL each time
            
            let settings: [String: Any] = [
                AVFormatIDKey: kAudioFormatLinearPCM,
                AVSampleRateKey: 16000,
                AVNumberOfChannelsKey: 1,
                AVLinearPCMBitDepthKey: 16,
                AVLinearPCMIsBigEndianKey: false,
                AVLinearPCMIsFloatKey: false,
                AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
            ]
            
            guard let url = recordingURL else {
                print("Error generating file URL")
                return
            }
            
            audioRecorder = try AVAudioRecorder(url: url, settings: settings)
            audioRecorder?.delegate = self
            audioRecorder?.isMeteringEnabled = true
            audioRecorder?.prepareToRecord()
            audioRecorder?.record()
            
            isRecording = true
        } catch {
            print("Error starting recording: \(error.localizedDescription)")
            isRecording = false
        }
    }
    
    func stopRecording() {
        audioRecorder?.stop()
        isRecording = false
        audioRecorder = nil
    }
    
    // Called when the recording finishes
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if flag {
            print("Recording finished successfully. File at: \(recordingURL?.absoluteString ?? "Unknown URL")")
            lastRecordingURL = recordingURL  // Publish the finished recording URL
        } else {
            print("Recording failed.")
        }
        isRecording = false
    }
    
    // Handle encoding errors
    func audioRecorderEncodeErrorDidOccur(_ recorder: AVAudioRecorder, error: Error?) {
        if let e = error {
            print("Encode error occurred: \(e.localizedDescription)")
        }
        isRecording = false
    }
}
