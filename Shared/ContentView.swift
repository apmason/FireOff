//
//  ContentView.swift
//  Shared
//
//  Created by Alex Mason on 7/17/21.
//

import SwiftUI

struct ContentView: View {
    
    @ObservedObject var twitterModel: TwitterSignIn = TwitterSignIn.shared
    
    var body: some View {
//        HStack(alignment: .top, spacing: 10, content: {
//            Color.gray
//                .frame(width: 30, height: 30)
//                .cornerRadius(15)
//            Color.blue
//        })
//        .padding(.horizontal, 20)
        if twitterModel.signedIn {
            TweetView()
        } else {
            SignInView()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
