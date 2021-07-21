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
    
    var editorTopPadding: CGFloat {
        #if os(iOS)
        return -5
        #else
        return 0
        #endif
    }
    
    var placeholderTopPadding: CGFloat {
        #if os(iOS)
        return 8
        #else
        return 0
        #endif
    }
    
    var placeholderLeadingPadding: CGFloat {
        #if os(iOS)
        return 0
        #else
        return 5
        #endif
    }
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            TextEditor(text: $text)
                .font(.body)
                .foregroundColor(.black)
                .onChange(of: text) { value in
                    showPlaceholder = text == ""
                    onChange?()
                }
                .multilineTextAlignment(.leading)
                .frame(minHeight: 30, alignment: .leading)
                .padding(.leading, editorTopPadding)
                
            if showPlaceholder {
                Text(placeholderText)
                    .font(.body)
                    .foregroundColor(AppColors.placeholderTextColor)
                    .padding(.top, placeholderTopPadding)
                    .padding(.leading, placeholderLeadingPadding)
            }
        }
    }
}

struct PlaceholderEditor_Previews: PreviewProvider {
    static var previews: some View {
        PlaceholderEditor(text: .constant(""), placeholderText: "Fire it off!")
    }
}
