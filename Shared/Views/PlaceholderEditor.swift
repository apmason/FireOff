//
//  PlaceholderEditor.swift
//  FireOff
//
//  Created by Alexander Mason on 7/19/21.
//

import SwiftUI

struct PlaceholderEditor: View {
    
    @State private var text: String = ""
    @State private var showPlaceholder: Bool = true
    var placeholderText: String
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            TextEditor(text: $text)
                .onChange(of: text) { value in
                    showPlaceholder = text == ""
                }
                
            if showPlaceholder {
                Text(placeholderText)
            }
        }
    }
}

struct PlaceholderEditor_Previews: PreviewProvider {
    static var previews: some View {
        PlaceholderEditor(placeholderText: "Fire it off!")
    }
}
