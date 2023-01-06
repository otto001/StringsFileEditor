//
//  EditableText.swift
//  StringsFileEditor
//
//  Created by Matteo Ludwig on 06.01.23.
//

import SwiftUI

struct EditableText: View {
    @Binding var text: String
    @State private var editText: String? = nil
    @FocusState private var focussed: Bool
    
    var body: some View {
        if let editText = editText {
            TextField("", text: Binding {
                return editText
            } set: { val, _ in
                self.editText = val
            })
            .focused($focussed)
            .onChange(of: focussed) { isFocussed in
                if !isFocussed {
                    self.text = editText
                    self.editText = nil
                }
            }
        } else {
            Text(text)
            .onTapGesture {
                self.editText = text
                self.focussed = true
            }
        }
    }
}

struct EditableText_Previews: PreviewProvider {
    struct EditableTextPreview: View {
        @State var text: String = "Test"
        
        var body: some View {
            EditableText(text: $text)
        }
    }
    
    static var previews: some View {
        EditableTextPreview()
    }
}
