//
//  TopView.swift
//  FireOff
//
//  Created by Alexander Mason on 7/25/21.
//

import SwiftUI

struct TopTweetView: View {
    @ObservedObject var twitterModel: TwitterSignIn
    
    var body: some View {
        HStack(alignment: .center) {
            Image(systemName: "gear")
                .resizable()
                .frame(width: 30,
                       height: 30,
                       alignment: .leading)
                .padding(15) // TODO: - Where should the padding go in here?
            
            Spacer()
            
            Button("Send Tweet") {
                twitterModel.sendTweet()
            }
            // @ALEX - View holds the logic of remainingCharacters
            .disabled(!twitterModel.canSend) // NOTE NEEDS TO CHANGE
            .frame(height: 30, alignment: .trailing)
            .padding(15)
            .cornerRadius(15)
        }
    }
}

struct TopView_Previews: PreviewProvider {
    static var previews: some View {
        TopTweetView(twitterModel: TwitterSignIn.shared)
    }
}
