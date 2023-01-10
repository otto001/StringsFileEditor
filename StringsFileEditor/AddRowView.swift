//
//  AddRowView.swift
//  StringsFileEditor
//
//  Created by Matteo Ludwig on 06.01.23.
//

import SwiftUI


struct AddRowView: View {
    @EnvironmentObject var viewModel: DocumentViewModel
    
    @State var key = ""
    @State var translations = Document.Translations()
    
    var document: Document {
        viewModel.document!
    }
    
    var languages: [Document.LanguageCode] {
        return Array(document.languages).sorted()
    }
    
    private func submit() {
        viewModel.setTranslations(key: key, translations: translations)
        viewModel.showAddRowDialog = false
    }

    
    var body: some View {
        NavigationStack {
            
            Form {
                
                Section {
                    TextField("Key", text: $key)
                }
                
                Section {
                    ForEach(languages) { language in
                        TextField(language.string, text: Binding {
                            return translations[language] ?? "-"
                        } set: { val, _ in
                            translations[language] = val
                        })
                    }
                }
            }
            .onSubmit {
                submit()
            }
            .formStyle(.grouped)
            .fixedSize(horizontal: false, vertical: true)
            .navigationTitle("Add Row")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        submit()
                    } label: {
                        Text("Add")
                    }
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button(role: .cancel) {
                        viewModel.showAddRowDialog = false
                    } label: {
                        Text("Cancel")
                    }
                }
            }
        }
        .frame(minWidth: 400)
    }

}

struct AddRowView_Previews: PreviewProvider {
    static var previews: some View {
        AddRowView().environmentObject(DocumentViewModel.preview)
    }
}
