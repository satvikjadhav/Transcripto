// NotesManager.swift
import Foundation
import CoreData

struct Note: Identifiable, Codable {
    var id: UUID
    var title: String
    var content: String
    var dateCreated: Date
    var dateModified: Date
    
    init(id: UUID = UUID(), title: String, content: String, dateCreated: Date = Date(), dateModified: Date = Date()) {
        self.id = id
        self.title = title
        self.content = content
        self.dateCreated = dateCreated
        self.dateModified = dateModified
    }
}

class NotesManager {
    static let shared = NotesManager()
    
    private let userDefaults = UserDefaults.standard
    private let notesKey = "savedTranscriptionNotes"
    
    private init() {}
    
    func saveNote(title: String, content: String) -> Note {
        var notes = getAllNotes()
        
        let newNote = Note(title: title, content: content)
        notes.append(newNote)
        
        saveAllNotes(notes)
        return newNote
    }
    
    func updateNote(id: UUID, title: String? = nil, content: String? = nil) -> Note? {
        var notes = getAllNotes()
        
        guard let index = notes.firstIndex(where: { $0.id == id }) else {
            return nil
        }
        
        var updatedNote = notes[index]
        
        if let title = title {
            updatedNote.title = title
        }
        
        if let content = content {
            updatedNote.content = content
        }
        
        updatedNote.dateModified = Date()
        notes[index] = updatedNote
        
        saveAllNotes(notes)
        return updatedNote
    }
    
    func deleteNote(id: UUID) -> Bool {
        var notes = getAllNotes()
        
        guard let index = notes.firstIndex(where: { $0.id == id }) else {
            return false
        }
        
        notes.remove(at: index)
        saveAllNotes(notes)
        return true
    }
    
    func getAllNotes() -> [Note] {
        guard let data = userDefaults.data(forKey: notesKey) else {
            return []
        }
        
        do {
            let notes = try JSONDecoder().decode([Note].self, from: data)
            return notes
        } catch {
            print("Error decoding notes: \(error)")
            return []
        }
    }
    
    func getNote(id: UUID) -> Note? {
        let notes = getAllNotes()
        return notes.first(where: { $0.id == id })
    }
    
    private func saveAllNotes(_ notes: [Note]) {
        do {
            let data = try JSONEncoder().encode(notes)
            userDefaults.set(data, forKey: notesKey)
        } catch {
            print("Error encoding notes: \(error)")
        }
    }
}
