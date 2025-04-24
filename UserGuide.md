# Transcripto User Guide

## Introduction

Transcripto is a powerful iOS application designed for audio recording and transcription, offering both file-based and real-time transcription capabilities. This user guide provides comprehensive instructions on installing, setting up, and using Transcripto to record, transcribe, and manage audio notes effectively.

---

## Table of Contents

1. Installation and Setup
2. App Features and Functionality
3. Navigating and Using Transcripto
    - Requesting Permissions
    - Recording Audio
    - Real-Time Transcription
    - Managing Notes
    - Editing and Deleting Notes
    - Searching Notes
4. Troubleshooting
5. Contact Support

---

## Installation and Setup

### System Requirements

- **Device**: iPhone or iPad running iOS 16.0 or later
- **Storage**: Approximately 200 MB of free storage space
- **Permissions**: Microphone access for recording and transcription

### Installation Steps

1. **Clone the repository, and build the app**:

2. **Launch the App**:
    - Locate the Transcripto icon on your home screen.
    - Tap the icon to open the app.
3. **Initial Setup**:
    - Upon first launch, Transcripto will request microphone access. Tap **OK** to grant permission.
    - The app will initialize the transcription model, which may take a few moments. A "Loading model..." message will appear during this process.

### Verifying Setup

- Ensure the app opens to the main **Record** tab, displaying the recording interface.
- Confirm that the status text reads **Ready to record**.

---

## App Features and Functionality

Transcripto offers a range of features to streamline audio recording and transcription:

### 1. Audio Recording

- **High-Quality Recording**: Records audio in M4A format with a sample rate of 44.1 kHz and high audio quality.
- **File-Based Transcription**: Transcribes recorded audio files using the WhisperKit model.

### 2. Real-Time Transcription

- **Live Transcription**: Processes audio in real-time, displaying text as you speak.
- **Noise Filtering**: Automatically filters out common background noises (e.g., engine sounds, music) for clearer transcriptions.

### 3. Note Management

- **Save Transcriptions**: Store transcriptions as notes with customizable titles.
- **Edit and Delete**: Modify or remove saved notes as needed.
- **Search Functionality**: Search notes by title or content for quick access.

### 4. User Interface

- **Tab-Based Navigation**: Switch between **Record** and **Notes** tabs.
- **Waveform Visualization**: Displays dynamic waveforms during recording or transcription.
- **Status Indicators**: Shows real-time status (e.g., Recording, Transcribing, Completed).

---

## Navigating and Using Transcripto

### Requesting Permissions

1. When you first open Transcripto, a prompt will request microphone access.
2. Tap **OK** to allow recording.
    - If you accidentally deny permission, go to **Settings > Privacy > Microphone** and enable access for Transcripto.

### Recording Audio

1. **Navigate to the Record Tab**:
    - Open Transcripto. The **Record** tab is selected by default.
2. **Select Recording Mode**:
    - Use the segmented picker to choose **Recording** mode (default).
3. **Start Recording**:
    - Tap the circular button with the microphone icon.
    - The button turns red, and a waveform animation appears, indicating active recording.
    - The status text changes to **Recording...**.
4. **Stop Recording**:
    - Tap the red button (now showing a white square).
    - The app will automatically start transcribing the audio, and the status changes to **Transcribing...**.
5. **View Transcription**:
    - Once transcription is complete, the transcribed text appears in the text area.
    - The status changes to **Transcription completed**.
6. **Save as a Note**:
    - Enter a title in the **Note Title** field (default: "Transcription [Date]").
    - Tap **Save Note** to store the transcription.
    - The interface resets, and the status returns to **Ready to record**.

### Real-Time Transcription

1. **Select Real-Time Mode**:
    - In the **Record** tab, use the segmented picker to select **Real-time** mode.
2. **Start Transcription**:
    - Tap the circular button with the microphone icon.
    - The button turns red, and a waveform animation appears.
    - The status text changes to **Transcribing...**.
    - Transcribed text appears in real-time as you speak.
3. **Stop Transcription**:
    - Tap the red button (showing a white square).
    - The final transcription is displayed, and the status changes to **Transcription completed**.
4. **Save as a Note**:
    - The app automatically sets a title like "Real-time Recording [Date Time]".
    - Edit the title if desired, then tap **Save Note**.
    - The interface resets to **Ready to record**.

### Managing Notes

1. **Navigate to the Notes Tab**:
    - Tap the **Notes** tab at the bottom of the screen.
2. **View Notes**:
    - A list of saved notes appears, showing the title, a waveform icon, pseudo-duration, and creation date.
    - If no notes exist, a "No recordings" message is displayed.
3. **View Note Details**:
    - Tap a note to open the **Note Detail View**.
    - View the note’s title, creation date, content, and a detailed waveform visualization.

### Editing and Deleting Notes

1. **Edit a Note**:
    - In the **Notes** tab, tap a note to open its details.
    - Tap the **ellipsis (...)** icon in the top-right corner and select **Edit**.
    - Modify the title or content as needed.
    - Tap **Save** to confirm changes or **Cancel** to discard them.
2. **Delete a Note**:
    - In the **Note Detail View**, tap the **ellipsis (...)** icon and select **Delete**.
    - Confirm deletion in the alert dialog.
    - Alternatively, in the **Notes** tab, swipe left on a note and tap **Delete** or use the **Edit** button to select and delete multiple notes.

### Searching Notes

1. **Access the Search Bar**:
    - In the **Notes** tab, pull down to reveal the search bar.
2. **Search for Notes**:
    - Enter keywords in the search field.
    - The list filters to show notes with matching titles or content.
3. **Clear Search**:
    - Delete the search text to view all notes again.

---

## Troubleshooting

### Common Issues and Solutions

1. **Microphone Permission Denied**:
    - Error: "Failed to start recording."
    - Solution: Go to **Settings > Privacy > Microphone** and enable Transcripto.
2. **Transcription Model Fails to Load**:
    - Error: "Failed to initialize WhisperKit."
    - Solution: Ensure a stable internet connection and relaunch the app.
3. **No Transcription Output**:
    - Issue: Transcription completes but no text appears.
    - Solution: Ensure the audio contains clear speech and minimal background noise. Try recording in a quieter environment.
4. **App Crashes**:
    - Solution: Update to the latest version of Transcripto via the App Store. If the issue persists, contact support.

### Debugging Tips

- Check the status indicator for real-time feedback (e.g., **Loading model...**, **Error occurred**).
- If an error alert appears, note the message for reference when contacting support.

---

## Conclusion

Transcripto simplifies audio recording and transcription with an intuitive interface and robust features. By following this guide, you can effectively record, transcribe, and manage your audio notes. For the latest updates and additional resources, visit the Transcripto website.