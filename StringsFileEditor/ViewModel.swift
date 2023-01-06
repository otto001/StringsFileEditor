//
//  ViewModel.swift
//  StringsFileEditor
//
//  Created by Matteo Ludwig on 06.01.23.
//

import Foundation
import AppKit

class ViewModel: ObservableObject {
    @Published var document: Document?
    
    @Published var showAddRowDialog: Bool = false
    
    private var undoStack = [Document]()
    private var redoStack = [Document]()
    
    var canUndo: Bool {
        return !self.undoStack.isEmpty
    }
    
    var canRedo: Bool {
        return !self.redoStack.isEmpty
    }
    
    init() {
        self.document = nil
    }
    
    func openDialog() {
        
        let dialog = NSOpenPanel();
        
        dialog.title = "Choose Localization directory (the one contain lproj directories)";
        dialog.showsResizeIndicator = true;
        dialog.showsHiddenFiles = false;
        dialog.canChooseFiles = false;
        dialog.canChooseDirectories = true;
        
        if (dialog.runModal() ==  NSApplication.ModalResponse.OK) {
            let result = dialog.url
            
            if (result != nil) {
                self.document = Document(fromDirectory: result!.absoluteURL)
                self.undoStack.removeAll()
                self.redoStack.removeAll()
            }
        } else {
            return
        }
    }
    
    private func storeUndo(clearRedo: Bool = true) {
        guard let document = self.document else { return }
        self.undoStack.append(document)
        if self.undoStack.count > 32 {
            self.undoStack = Array(self.undoStack[1...])
        }
        if clearRedo {
            self.redoStack.removeAll()
        }
    }
    
    private func storeRedo() {
        guard let document = self.document else { return }
        self.redoStack.append(document)
        if self.redoStack.count > 32 {
            self.redoStack = Array(self.redoStack[1...])
        }
    }
    
    func undo() {
        guard let document = self.undoStack.popLast() else { return }
        self.storeRedo()
        self.document = document
    }
    
    func redo() {
        guard let document = self.redoStack.popLast() else { return }
        self.storeUndo(clearRedo: false)
        self.document = document
    }
    
    func setTranslation(key: String, langCode: String, translation: String) {
        self.storeUndo(clearRedo: false)
        self.document?.setTranslation(key: key, langCode: langCode, translation: translation)
    }
    
    func addKey(key: String, translations: Document.Translations) {
        guard let document = self.document else { return }
        self.storeUndo()
        for language in document.languages {
            let translation = translations[language] ?? key
            self.document?.setTranslation(key: key, langCode: language, translation: translation)
        }
    }
    
    func removeKey(key: String) {
        self.storeUndo()
        self.document?.removeKey(key: key)
    }
    
    func save() {
        self.document?.save()
    }
}


extension ViewModel {
    static var preview: ViewModel {
        var document = Document()
        document.setTranslation(key: "hello", langCode: "en", translation: "Hello")
        document.setTranslation(key: "hello", langCode: "de", translation: "Hallo")
        
        document.setTranslation(key: "bye", langCode: "en", translation: "Bye")
        document.setTranslation(key: "bye", langCode: "de", translation: "Tschüss")
        
        document.setTranslation(key: "yes", langCode: "en", translation: "Yes")
        document.setTranslation(key: "yes", langCode: "de", translation: "Ja")
        
        document.setTranslation(key: "no", langCode: "en", translation: "No")
        document.setTranslation(key: "no", langCode: "de", translation: "Nein")
        
        document.languages = ["en", "de"]
        
        let viewModel = ViewModel()
        viewModel.document = document
        return viewModel
    }
}
