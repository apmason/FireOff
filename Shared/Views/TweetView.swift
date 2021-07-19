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
    
    var body: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 20) {
                HStack {
                    Text(TwitterSignIn.shared.userName ?? "Loading")
                }
                PlaceholderEditor(placeholderText: "Hey!")
                    .frame(alignment: .topLeading)
                Divider()
                Text("\(remainingCharacters)")
            }
            Button("Tweet") {
                print("Send tweet")
                // clear out text
                // alert user if it worked or not
            }
        }
        .padding(20)
    }
}

struct TweetView_Previews: PreviewProvider {
    @State static var tweetText: String = "Hey!"
    
    static var previews: some View {
        TweetView()
    }
}
