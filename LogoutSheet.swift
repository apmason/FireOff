//
//  Sheet.swift
//  FireOff
//
//  Created by Alexander Mason on 7/25/21.
//

import Foundation
import SwiftUI


/// A cross-platofrm modifier that presents an alert. For Mac, a popover will be presented. For iOS, an ActionSheet will be presented.
struct LogoutSheet: ViewModifier {
    
    @Binding var presented: Bool
    @ObservedObject var twitterModel: TwitterSignIn
    
    fileprivate let questionText = "Are you sure you want to logout?"
    
    func body(content: Content) -> some View {
        #if os(macOS)
        return content.alert(isPresented: $presented) {
            Alert(title: Text(questionText),
                  primaryButton: .default(Text("No, stay logged in")),
                  secondaryButton: .destructive(Text("Yes, logout"), action: {
                    twitterModel.logout()
                  })
            )
        }
        #else
        return content
            .actionSheet(isPresented: $presented) {
                ActionSheet(title: Text(questionText), buttons: [
                    .default(Text("No, stay logged in")),
                    .destructive(Text("Yes, logout"), action: {
                        twitterModel.logout()
                    })
                ])
            }
        #endif
    }
}
