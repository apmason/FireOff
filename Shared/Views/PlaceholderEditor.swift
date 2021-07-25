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
    
    // TODO: - Fix all these padding changes
    var editorTopPadding: CGFloat {
        #if os(iOS)
        return -7
        #else
        return 0
        #endif
    }
    
    var editorLeadingPadding: CGFloat {
        #if os(iOS)
        return -3.5
        #else
        return 0
        #endif
    }
    
    var placeholderLeadingPadding: CGFloat {
        return 3.5
    }
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            TextEditor(text: $text)
                .multilineTextAlignment(.leading)
                .font(.body)
                .foregroundColor(.black)
                .onChange(of: text) { value in
                    showPlaceholder = text == ""
                    onChange?()
                }
                .frame(alignment: .topLeading)
                .padding(.top, editorTopPadding)
                .padding(.leading, editorLeadingPadding)
                
            if showPlaceholder {
                Text(placeholderText)
                    .font(.body)
                    .foregroundColor(AppColors.placeholderTextColor)
                    .frame(alignment: .topLeading)
                    .padding(.leading, placeholderLeadingPadding)
            }
        }
        .background(Color.red.opacity(0.3))
    }
}

struct PlaceholderEditor_Previews: PreviewProvider {
    static var previews: some View {
        PlaceholderEditor(text: .constant(""), placeholderText: "Fire it off!")
    }
}
