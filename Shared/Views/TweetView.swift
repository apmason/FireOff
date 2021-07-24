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
        VStack {
            HStack {
                Image(systemName: "gear")
                    .frame(width: 30, height: 30, alignment: .leading)
                    .padding(15)
                Spacer()
                Button("Tweet") {
                    guard !sendingTweet else { return } // prevent double taps
                    sendingTweet = true
                    twitterModel.sendTweet(tweetText) { error in
                        sendingTweet = false
                        // Close out alert
                        guard let error = error else {
                            tweetText = "" // reset the TextEditor
                            // pop an alert up here showing success for a few seconds.
                            return
                        }
                        errorAlert.showAlert(for: error)
                    }
                }
                .disabled(remainingCharacters < 0 || remainingCharacters == 240)
                .frame(height: 30, alignment: .trailing)
                .padding(15)
                .cornerRadius(15)
            }
            .padding(.horizontal, /*@START_MENU_TOKEN@*/10/*@END_MENU_TOKEN@*/)
            
            HStack(alignment: .top, spacing: 20, content: {
                ProfileImage()
                    .frame(width: 30, height: 30)
                    .cornerRadius(15)
                
                PlaceholderEditor(text: $tweetText, placeholderText: "FireOff a tweet!", onChange: {
                    remainingCharacters = maxCharacters - tweetText.count
                })
            })
        }
    }
}

struct TweetView_Previews: PreviewProvider {
    @State static var tweetText: String = "FireOff a tweet!"
    
    static var previews: some View {
        TweetView()
    }
}
