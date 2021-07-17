//
//  ContentView.swift
//  Shared
//
//  Created by Alex Mason on 7/17/21.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        Button("Log In With Twitter") {
            TwitterSignIn.shared.signIn()
        }
        .padding(.all)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
