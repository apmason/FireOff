//
//  SignInView.swift
//  FireOff
//
//  Created by Alex Mason on 7/19/21.
//

import SwiftUI

struct SignInView: View {
    //@State private var errorAlert = ErrorAlert() // @ALEX: - Removed the error alert, so make sure this works elsewhere!
    @State private var signingIn: Bool = false // @ALEX update this so the Model-View connection is more similar to TweetView (we shouldn't track the state in the view, the model handles all that)).
    
    var body: some View {
        ZStack {
            Button("Log In With Twitter") {
                // Prevent double-taps
                guard !signingIn else { return }
                signingIn = true
                TwitterSignIn.shared.signIn { error in
                    signingIn = false
                    guard let error = error else {
                        return
                    }
                    
                    guard case TwitterError.sessionCancelled = error else {
                        return // we won't show an alert if the user cancels the session
                    }
                    
                    //self.errorAlert.showAlert(for: error)
                }
            }
            .padding(.all)
            // @ALEX: - Removed this, so make sure that we add error handling back.
//            .alert(isPresented: $errorAlert.showAlert, content: {
//                Alert(title: Text("Error!"), message: Text(errorAlert.errorString), dismissButton: .cancel(Text("Okay"), action: {
//                    self.errorAlert.reset()
//                }))
//            })
            
            // Show an activity indicator if we're signing in.
            if signingIn {
                ActivityView()
            }
        }
    }
}

struct SignInView_Previews: PreviewProvider {
    static var previews: some View {
        SignInView()
    }
}
