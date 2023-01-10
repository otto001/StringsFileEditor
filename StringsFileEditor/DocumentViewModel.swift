//
//  ViewModel.swift
//  StringsFileEditor
//
//  Created by Matteo Ludwig on 06.01.23.
//

import Foundation
import AppKit

class DocumentViewModel: ObservableObject {
    @Published var document: Document?
    
    @Published var showAddRowDialog: Bool = false
    
    private var undoRedoMaximum = 64
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
        if self.undoStack.count > self.undoRedoMaximum {
            self.undoStack = Array(self.undoStack[1...])
        }
        if clearRedo {
            self.redoStack.removeAll()
        }
    }
    
    private func storeRedo() {
        guard let document = self.document else { return }
        self.redoStack.append(document)
        if self.redoStack.count > self.undoRedoMaximum {
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
    
    func setTranslation(key: String, language: Document.LanguageCode, translation: String) {
        self.storeUndo()
        self.document?.setTranslation(key: key, language: language, translation: translation)
    }
    
    func setTranslations(key: String, translations: Document.Translations) {
        self.storeUndo()
        self.document?.setTranslations(key: key, translations: translations)
    }
    
    func removeKey(key: String) {
        self.storeUndo()
        self.document?.removeKey(key: key)
    }
    
    func save() {
        self.document?.save()
    }
}


extension DocumentViewModel {
    static var preview: DocumentViewModel {
        var document = Document()
        
        let en = Document.LanguageCode(string: "en")
        let de = Document.LanguageCode(string: "de")
        
        document.setTranslation(key: "hello", language: en, translation: "Hello")
        document.setTranslation(key: "hello", language: de, translation: "Hallo")
        
        document.setTranslation(key: "bye", language: en, translation: "Bye")
        document.setTranslation(key: "bye", language: de, translation: "Tschüss")
        
        document.setTranslation(key: "yes", language: en, translation: "Yes")
        document.setTranslation(key: "yes", language: de, translation: "Ja")
        
        document.setTranslation(key: "no", language: en, translation: "No")
        document.setTranslation(key: "no", language: de, translation: "Nein")
        
        
        let viewModel = DocumentViewModel()
        viewModel.document = document
        return viewModel
    }
}
