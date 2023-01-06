//
//  AddRowView.swift
//  StringsFileEditor
//
//  Created by Matteo Ludwig on 06.01.23.
//

import SwiftUI


struct AddRowView: View {
    @EnvironmentObject var viewModel: ViewModel
    
    @State var key = ""
    @State var translations = Document.Translations()
    
    var document: Document {
        viewModel.document!
    }
    
    var languages: [String] {
        return document.languages
    }
    
    var body: some View {
        
        Form {
            Text("Add Row").font(.title).frame(maxWidth: .infinity, alignment: .leading)
            
            TextField("Key", text: $key)
            
            ForEach(languages, id: \.self) { langCode in
                TextField(langCode, text: Binding {
                    return translations[langCode] ?? "-"
                } set: { val, _ in
                    translations[langCode] = val
                })
            }
            
            HStack {
                Button(role: .cancel) {
                    viewModel.showAddRowDialog = false
                } label: {
                    Text("Cancel")
                }
                Spacer()
                Button {
                    viewModel.addKey(key: key, translations: translations)

                    viewModel.showAddRowDialog = false
                } label: {
                    Text("Add")
                }
            }
            

        }
        .frame(minWidth: 400)
        .padding()

    }

}

struct AddRowView_Previews: PreviewProvider {
    static var previews: some View {
        AddRowView().environmentObject(ViewModel.preview)
    }
}
