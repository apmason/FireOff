//
//  SignInView.swift
//  FireOff
//
//  Created by Alex Mason on 7/19/21.
//

import SwiftUI

struct SignInView: View {
    @State private var errorAlert = ErrorAlert()
    @State private var signingIn: Bool = false
    
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
                    
                    self.errorAlert.showAlert(for: error)
                }
            }
            .alert(isPresented: $errorAlert.showAlert, content: {
                Alert(title: Text("Error!"), message: Text(errorAlert.errorString), dismissButton: .cancel(Text("Okay"), action: {
                    self.errorAlert.reset()
                }))
            })
            .padding(.all)
            
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
