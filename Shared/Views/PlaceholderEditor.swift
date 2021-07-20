//
//  PlaceholderEditor.swift
//  FireOff
//
//  Created by Alexander Mason on 7/19/21.
//

import SwiftUI

struct PlaceholderEditor: View {
    
    @Binding var text: String
    @State private var showPlaceholder: Bool = true
    var placeholderText: String
    var onChange: (() -> Void)?
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            TextEditor(text: $text)
                .font(.body)
                .foregroundColor(.black)
                .onChange(of: text) { value in
                    showPlaceholder = text == ""
                    onChange?()
                }
                .frame(minHeight: 30, alignment: .leading)
                .padding(.leading, -5)
                .multilineTextAlignment(.leading)
                
            if showPlaceholder {
                Text(placeholderText)
                    .font(.body)
                    .foregroundColor(AppColors.placeholderTextColor)
                    .padding(.top, 8)
            }
        }
    }
}

struct PlaceholderEditor_Previews: PreviewProvider {
    static var previews: some View {
        PlaceholderEditor(text: .constant(""), placeholderText: "Fire it off!")
    }
}
