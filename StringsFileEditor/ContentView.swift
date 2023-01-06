//
//  ContentView.swift
//  StringsFileEditor
//
//  Created by Matteo Ludwig on 06.01.23.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var viewModel: ViewModel
    
    
    var body: some View {
        if viewModel.document != nil {
            DocumentView()
        } else {
            Button {
                viewModel.openDialog()
            } label: {
                Text("Open")
            }
            .padding()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
