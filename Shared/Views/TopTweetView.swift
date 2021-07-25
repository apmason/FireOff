//
//  TopView.swift
//  FireOff
//
//  Created by Alexander Mason on 7/25/21.
//

import SwiftUI

struct TopTweetView: View {
    @ObservedObject var twitterModel: TwitterSignIn
    @State private var showLogoutSheet = false
    
    var body: some View {
        HStack(alignment: .center) {
            Button {
                showLogoutSheet = true
            } label: {
                Text("Logout")
            }
            .modifier(LogoutSheet(presented: $showLogoutSheet,
                                       twitterModel: twitterModel))
            
            Spacer()
            
            
            Button("Send Tweet") {
                twitterModel.sendTweet()
            }
            // @ALEX - View holds the logic of remainingCharacters
            .disabled(!twitterModel.canSend) // NOTE NEEDS TO CHANGE
            .padding(10)
            .foregroundColor(Color.white)
            .background(Color.blue)
            .cornerRadius(5) // @ALEX: New SwiftUI button type?
        }
    }
}

struct TopView_Previews: PreviewProvider {
    static var previews: some View {
        TopTweetView(twitterModel: TwitterSignIn.shared)
    }
}
