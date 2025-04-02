// To save transcriptions as notes within your app, 
// we can use a simple data model and persist it 
// using UserDefaults, Core Data, or a file system approach

import Foundation

struct Note: Identifiable, Codable {
    let id = UUID()
    let text: String
    let date: Date
}

// class NotesManager: ObservableObject....