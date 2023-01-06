//
//  DocumentView.swift
//  StringsFileEditor
//
//  Created by Matteo Ludwig on 06.01.23.
//

import SwiftUI

fileprivate let colWidth: CGFloat = 200

fileprivate struct DocumentRowView: View {
    @EnvironmentObject var viewModel: ViewModel
    
    let key: Document.Key
    
    var document: Document {
        viewModel.document!
    }
    
    var languages: [String] {
        return document.languages
    }
    
    init(key: Document.Key) {
        self.key = key
    }

    var body: some View {
        let translations = document.entries[key] ?? Document.Translations()
        
        VStack(alignment: .leading) {
            HStack {
                Text(key).frame(width: colWidth, alignment: .leading)
                ForEach(languages, id: \.self) { langCode in
                    
                    EditableText(text: Binding {
                        return translations[langCode] ?? "-"
                    } set: { val, _ in
                        viewModel.setTranslation(key: key, langCode: langCode, translation: val)
                    })
                    .frame(width: colWidth, alignment: .leading)
                }
                Button(role: .destructive) {
                    viewModel.removeKey(key: key)
                } label: {
                    Text("Remove")
                }

            }
            Divider()
        }
    }
}


struct DocumentView: View {
    @EnvironmentObject var viewModel: ViewModel
    
    var document: Document {
        viewModel.document!
    }
    
    var languages: [String] {
        return document.languages
    }

    var body: some View {
        List(document.keys, id: \.self) { key in
            DocumentRowView(key: key)
        }
        .padding(.top, 30)
        .overlay(alignment: .topLeading) {
            HStack {
                Text("Key").frame(width: colWidth, alignment: .leading)
                ForEach(languages, id: \.self) { langCode in
                    Text(langCode).frame(width: colWidth, alignment: .leading)
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
            .background(Material.regular)
        }
        .sheet(isPresented: $viewModel.showAddRowDialog) {
            AddRowView()
        }
    }
}

struct DocumentView_Previews: PreviewProvider {
    static var previews: some View {
        DocumentView().environmentObject(ViewModel.preview)
    }
}
