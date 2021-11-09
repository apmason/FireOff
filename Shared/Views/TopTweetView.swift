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
            .disabled(!twitterModel.canSend)
            .padding(10)
        }
    }
}

struct TopView_Previews: PreviewProvider {
    static var previews: some View {
        TopTweetView(twitterModel: TwitterSignIn.shared)
    }
}
