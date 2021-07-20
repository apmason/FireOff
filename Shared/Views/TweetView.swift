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
    
    var body: some View {
        ZStack {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 20) {
                    HStack {
                        Text(TwitterSignIn.shared.userName ?? "Loading") //TODO: - Handle no username
                    }
                    PlaceholderEditor(text: $tweetText, placeholderText: "Hey!", onChange: {
                        remainingCharacters = maxCharacters - tweetText.count
                    })
                        .frame(alignment: .topLeading)
                    Divider()
                    Text("\(remainingCharacters)")
                }
                Button("Tweet") {
                    guard !sendingTweet else { return } // prevent double taps
                    sendingTweet = true
                    TwitterSignIn.shared.sendTweet(tweetText) { error in
                        sendingTweet = false
                        // Close out alert
                        guard let error = error else {
                            tweetText = "" // reset the TextEditor
                            // pop an alert up here showing success for a few seconds.
                            return
                        }
                        
                        // Show an alert
                        print("Error was \(error.localizedDescription)")
                    }
                }
                .disabled(remainingCharacters < 0)
            }
            .padding(20)
            
            if sendingTweet {
                ActivityView()
            }
        }
    }
}

struct TweetView_Previews: PreviewProvider {
    @State static var tweetText: String = "Hey!"
    
    static var previews: some View {
        TweetView()
    }
}
