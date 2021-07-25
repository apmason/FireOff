//
//  TweetView.swift
//  FireOff
//
//  Created by Alex Mason on 7/19/21.
//

import SwiftUI

struct TweetView: View {
    
    @State private var tweetText: String = ""
    @State private var remainingCharacters: Int = 240
    private var maxCharacters = 240
    @State private var sendingTweet: Bool = false
    @State private var errorAlert = ErrorAlert()
    
    private var twitterModel: TwitterSignIn = TwitterSignIn.shared
    
    var body: some View {
        HStack(alignment: .top, spacing: 10, content: {
            Color.gray
                .frame(width: 30, height: 30)
                .cornerRadius(15)
            Color.blue
        })
        .padding(.horizontal, 20)
        
    }
}

struct TweetView_Previews: PreviewProvider {
    @State static var tweetText: String = "FireOff a tweet!"
    
    static var previews: some View {
        TweetView()
    }
}
