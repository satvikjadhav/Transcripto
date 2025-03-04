import AVFoundation
import Combine

class AudioRecorder: NSObject, ObservableObject, AVAudioRecorderDelegate {
    @Published var isRecording = false  // Published property for UI updates
    private var audioRecorder: AVAudioRecorder?
    private var recordingURL: URL?

    func startRecording() {
        let session = AVAudioSession.sharedInstance()

        do {
            try session.setCategory(.playAndRecord, mode: .default) //Correct Category
            try session.setActive(true)

            // Create a URL for the recording (in the documents directory)
            let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            recordingURL = documentsDirectory.appendingPathComponent("recording.wav") //Use .wav, very important

            // **Recording Settings (16kHz, etc.)**
            let settings: [String: Any] = [
                AVFormatIDKey: kAudioFormatLinearPCM, // Uncompressed PCM format
                AVSampleRateKey: 16000,                // 16kHz sample rate
                AVNumberOfChannelsKey: 1,              // Mono audio
                AVLinearPCMBitDepthKey: 16,            //16 bit
                AVLinearPCMIsBigEndianKey: false,     //Little Endian
                AVLinearPCMIsFloatKey: false,          //integer
                AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue  //Good quality
            ]

            guard let url = recordingURL else {
              print("Error with url")
              return
            }

            audioRecorder = try AVAudioRecorder(url: url, settings: settings)
            audioRecorder?.delegate = self  // Set the delegate
            audioRecorder?.isMeteringEnabled = true //If you want level metering
            audioRecorder?.prepareToRecord()
            audioRecorder?.record()

            isRecording = true // Update the published property
        } catch {
            print("Error starting recording: \(error.localizedDescription)")
            isRecording = false  // Make sure to set to false on error
        }
    }

    func stopRecording() {
        audioRecorder?.stop()
        isRecording = false // Update published property
        audioRecorder = nil
    }

    // AVAudioRecorderDelegate method (called when recording finishes)
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if flag {
            print("Recording finished successfully.  File at: \(recordingURL?.absoluteString ?? "Unknown URL")")
        } else {
            print("Recording failed.")
            // Handle the failure (e.g., show an alert to the user)
        }
        isRecording = false // Make sure this is updated
    }

    // Handle interruption
    func audioRecorderEncodeErrorDidOccur(_ recorder: AVAudioRecorder, error: Error?) {
        if let e = error {
            print("Encode error occurred: \(e.localizedDescription)")
        }
        isRecording = false // Reset the recording state
    }
}