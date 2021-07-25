//
//  TweetView.swift
//  FireOff
//
//  Created by Alex Mason on 7/19/21.
//

import SwiftUI

struct TweetView: View {
    
    @ObservedObject private var twitterModel: TwitterSignIn = TwitterSignIn.shared
    
    var body: some View {
        ZStack {
            VStack(alignment: .center) {
                TopTweetView(twitterModel: twitterModel)
                HStack(alignment: .top, spacing: 10, content: {
                    ProfileImage(twitterModel: twitterModel)
                        .frame(width: 30, height: 30)
                        .cornerRadius(15)
                    PlaceholderEditor(text: $twitterModel.tweetText, placeholderText: "FireOff a tweet!")
                        .frame(alignment: .topLeading)
                })
                .padding(.horizontal, 20)
                
                Divider()
                Text("\(twitterModel.remainingCharacters)")
            }
            
            if twitterModel.sendingTweet {
                ActivityView()
            }
        }
        
        
        // @ALEX TODO: Listening to twitterModel.signingIn for the alert.
        
        
    }
}

struct TweetView_Previews: PreviewProvider {
    @State static var tweetText: String = "FireOff a tweet!"
    
    static var previews: some View {
        TweetView()
    }
}
