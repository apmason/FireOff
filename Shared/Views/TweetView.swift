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
            VStack(alignment: .center, spacing: 20) {
                TopTweetView(twitterModel: twitterModel)
                HStack(alignment: .top, spacing: 10, content: {
                    ProfileImage(twitterModel: twitterModel)
                        .frame(width: 30, height: 30)
                        .cornerRadius(15)
                    PlaceholderEditor(text: $twitterModel.tweetText, placeholderText: "FireOff a tweet!")
                        .frame(alignment: .topLeading)
                })
                .alert(isPresented: $twitterModel.activeAlert.showAlert) {
                    return twitterModel.activeAlert.alert ?? Alert(title: Text("A default error occured"))
                }
                
                Divider()
                Text("\(twitterModel.remainingCharacters)")
            }
            .padding(20)
        
            if twitterModel.sendingTweet {
                ActivityView()
            }
        }
    }
}

struct TweetView_Previews: PreviewProvider {
    @State static var tweetText: String = "FireOff a tweet!"
    
    static var previews: some View {
        TweetView()
    }
}
