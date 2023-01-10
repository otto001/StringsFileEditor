//
//  DocumentView.swift
//  StringsFileEditor
//
//  Created by Matteo Ludwig on 06.01.23.
//

import SwiftUI


fileprivate struct DocumentRowView: View {
    
    @EnvironmentObject var viewModel: DocumentViewModel
    var document: Document {
        viewModel.document!
    }
    
    let key: Document.Key
    var languages: [Document.LanguageCode]
    let columnWidth: CGFloat

    var body: some View {
        let translations = document.entries[key] ?? Document.Translations()
        
        VStack(alignment: .leading) {
            HStack {
                Text(key).frame(width: columnWidth, alignment: .leading)
                ForEach(languages, id: \.self) { language in
                    
                    EditableText(text: Binding {
                        return translations[language] ?? "-"
                    } set: { val, _ in
                        viewModel.setTranslation(key: key, language: language, translation: val)
                    })
                    .frame(width: columnWidth, alignment: .leading)
                }
                
                Spacer()
                
                Button(role: .destructive) {
                    viewModel.removeKey(key: key)
                } label: {
                    Text("Remove")
                }
                .padding(.trailing, 12)
            }
            Divider()
        }
    }
}


fileprivate struct DocumentTable: View {
    @State var search: String = ""
    
    let geo: GeometryProxy
    let document: Document
    
    var languages: [Document.LanguageCode] {
        return Array(document.languages).sorted()
    }
    
    var listWidth: CGFloat {
        geo.size.width
    }
    
    var columnWidth: CGFloat {
        return (listWidth - 200) / CGFloat(languages.count + 1)
    }
    
    var orderedKeys: [Document.Key] {
        return document.orderedKeys
    }
    
    var filteredKeys: [Document.Key] {
        guard !search.isEmpty else { return orderedKeys }
        return orderedKeys.filter { key in
            return key.contains(search)
        }
    }
    
    var body: some View {
        List(filteredKeys, id: \.self) { key in
            DocumentRowView(key: key, languages: languages, columnWidth: columnWidth)
        }
        .searchable(text: $search)
        .frame(width: listWidth)
        .padding(.top, 30)
        .overlay(alignment: .topLeading) {
            VStack(spacing: 0) {
                HStack {
                    Text("Key").frame(width: columnWidth, alignment: .leading).padding(.leading)
                    ForEach(languages) { language in
                        Text(language.string).frame(width: columnWidth, alignment: .leading)
                    }
                }
                .frame(width: listWidth, alignment: .leading)
                .padding(.vertical, 8)
                
                Divider()
            }
            .frame(width: listWidth, alignment: .leading)
            
            .background(Material.ultraThin)
        }
    }
}

struct DocumentView: View {
    @EnvironmentObject var viewModel: DocumentViewModel
    
    var document: Document {
        viewModel.document!
    }

    var navigationTitle: String {
        return document.baseUrl?.relativePath ?? "Strings File Editor"
    }

    var body: some View {
        GeometryReader { geo in
            DocumentTable(geo: geo, document: document)
        }
        .toolbarRole(.editor)
        .toolbar {
            ToolbarItem(placement: .automatic) {
                Button {
                    viewModel.showAddRowDialog = true
                } label: {
                    Label("Add Row", systemImage: "plus")
                }
            }
        }
        .sheet(isPresented: $viewModel.showAddRowDialog) {
            AddRowView()
        }
        .navigationTitle(navigationTitle)
    }
}

struct DocumentView_Previews: PreviewProvider {
    static var previews: some View {
        DocumentView().environmentObject(DocumentViewModel.preview)
    }
}
