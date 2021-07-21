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
        ActivityView()
//        if twitterModel.signedIn {
//            TweetView()
//        } else {
//            SignInView()
//        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
