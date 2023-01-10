//
//  StringsFileEditorApp.swift
//  StringsFileEditor
//
//  Created by Matteo Ludwig on 06.01.23.
//

import SwiftUI

@main
struct StringsFileEditorApp: App {
    @StateObject var viewModel = DocumentViewModel()
    
    var body: some Scene {
        Window("Strings File Editor", id: "main") {
            ContentView().environmentObject(viewModel)
        }
        .commands {

            CommandGroup(after: .newItem) {
                Button("Open") {
                    viewModel.openDialog()
                }
                .keyboardShortcut("O", modifiers: .command)

                Button("Save") {
                    viewModel.save()
                }
                .disabled(viewModel.document == nil)
                .keyboardShortcut("S", modifiers: .command)
            }

            CommandGroup(replacing: .undoRedo) {
                Button("Undo") {
                    viewModel.undo()
                }
                .disabled(!viewModel.canUndo)
                .keyboardShortcut("Z", modifiers: .command)

                Button("Redo") {
                    viewModel.redo()
                }
                .disabled(!viewModel.canRedo)
                .keyboardShortcut("Z", modifiers: [.command, .shift])

                Button("Add Row") {
                    viewModel.showAddRowDialog = true
                }
                .disabled(viewModel.document == nil)
                .keyboardShortcut("A", modifiers: .option)

            }
        }
    }
}
