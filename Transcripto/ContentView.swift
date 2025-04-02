//
//  ContentView.swift
//  Transcripto
//
//  Created by Lakshmi Tulasi Ummadipolu on 3/4/25.
//

import SwiftUI

// class AudioTranscriber....

struct ContentView: View {
    @State private var folders: [String] = []  // Start with an empty list
    @State private var newFolderName = ""     // Stores the folder name for input
    @State private var showAddFolderSheet = false // Controls sheet visibility
    @State private var editingFolderIndex: Int? // Keeps track of which folder is being edited
    @State private var showAlert = false      // Controls alert visibility for duplicate names
    @State private var alertMessage = ""      // Stores the alert message

    var body: some View {
        NavigationView {
            VStack {
                if folders.isEmpty {
                    Text("No folders available. Click + to create one.")
                        .foregroundColor(.gray)
                        .padding()
                } else {
                    List {
                        ForEach(folders.indices, id: \.self) { index in
                            HStack {
                                NavigationLink(destination: RecordingsView(folderName: folders[index])) {
                                    Text(folders[index])
                                        .font(.headline)
                                }
                                Spacer()
                                
                                // Rename Button
                                Button(action: {
                                    startEditingFolder(index: index)
                                }) {
                                    Image(systemName: "pencil")
                                        .foregroundColor(.blue)
                                }
                                .padding(.trailing, 10)

                                // Delete Button
                                Button(action: {
                                    deleteFolder(index: index)
                                }) {
                                    Image(systemName: "trash")
                                        .foregroundColor(.red)
                                }
                            }
                        }
                        .onDelete(perform: deleteAtOffsets) // Enable swipe-to-delete
                    }
                }
                
                Spacer()
                
                // Button to add a new folder
                Button(action: {
                    newFolderName = ""  // Reset input
                    editingFolderIndex = nil
                    showAddFolderSheet = true
                }) {
                    Image(systemName: "plus")
                        .font(.largeTitle)
                        .frame(width: 60, height: 60)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .clipShape(Circle())
                        .padding()
                }
                .sheet(isPresented: $showAddFolderSheet) {
                    FolderInputView(
                        folderName: $newFolderName,
                        isPresented: $showAddFolderSheet,
                        saveAction: saveFolder
                    )
                }
            }
            .navigationTitle("Voice Folders")
            .alert(isPresented: $showAlert) {
                Alert(title: Text("Error"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
            }
        }
    }
    
    // Start Editing a Folder (Prepares Name)
    private func startEditingFolder(index: Int) {
        newFolderName = folders[index]
        editingFolderIndex = index
        showAddFolderSheet = true
    }

    // Add or Rename a Folder
    private func saveFolder() {
        guard !newFolderName.isEmpty else { return }
        
        if folders.contains(newFolderName) && editingFolderIndex == nil {
            alertMessage = "A folder with this name already exists."
            showAlert = true
            return
        }
        
        if let index = editingFolderIndex {
            if folders[index] != newFolderName && folders.contains(newFolderName) {
                alertMessage = "A folder with this name already exists."
                showAlert = true
                return
            }
            folders[index] = newFolderName // Rename existing folder
        } else {
            folders.append(newFolderName) // Add a new folder
        }
        
        newFolderName = ""
        editingFolderIndex = nil
    }

    // Delete a Folder
    private func deleteFolder(index: Int) {
        folders.remove(at: index)
    }

    // Delete Folder Using Swipe Action
    private func deleteAtOffsets(offsets: IndexSet) {
        folders.remove(atOffsets: offsets)
    }
}

// Updated Folder Input Sheet UI
struct FolderInputView: View {
    @Binding var folderName: String
    @Binding var isPresented: Bool
    var saveAction: () -> Void

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Enter Folder Name")
                    .font(.headline)
                    .padding(.top, 20)
                
                TextField("Folder Name", text: $folderName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal, 20)
                    .padding(.top, 10)

                Spacer()

                HStack {
                    Button(action: {
                        isPresented = false  // Close the sheet only
                    }) {
                        Text("Cancel")
                            .foregroundColor(.red)
                            .padding()
                    }

                    Spacer()

                    Button(action: {
                        saveAction()
                        isPresented = false
                    }) {
                        Text("Save")
                            .fontWeight(.bold)
                            .foregroundColor(folderName.isEmpty ? .gray : .blue)
                    }
                    .disabled(folderName.isEmpty)
                    .padding()
                }
                .padding(.bottom, 20)
            }
            .navigationTitle(folderName.isEmpty ? "New Folder" : "Rename Folder")
            .padding()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
