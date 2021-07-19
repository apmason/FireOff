//
//  TweetView.swift
//  FireOff
//
//  Created by Alex Mason on 7/19/21.
//

import SwiftUI

struct TweetView: View {
    
    @State private var tweetText: String = ""
    
    var body: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 20) {
                HStack {
                    Text(TwitterSignIn.shared.userName ?? "Loading")
                    Text("FUCK")
                }.frame(width: .infinity, alignment: .trailing)
                
                TextField("Fire it Off!", text: $tweetText)
                    .frame(maxHeight: .infinity, alignment: .topLeading)
                Divider()
                Text("240")
                    .frame(alignment: .trailing)
                
            }
            Text("Hey brother")
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
