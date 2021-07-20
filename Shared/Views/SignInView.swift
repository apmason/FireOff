//
//  SignInView.swift
//  FireOff
//
//  Created by Alex Mason on 7/19/21.
//

import SwiftUI

struct SignInView: View {
    @State private var alertState = AlertState()
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
                    
                    switch error {
                    case .networkError:
                        // An unidentified network error.
                        self.alertState.showAlert()
                        
                    case .apiError(statusCode: let code):
                        self.alertState.showAlert(errorCode: code)
                        
                    case .sessionCancelled:
                        break // We won't show an alert if the user cancels the session
                    
                    case .defaultError(let error):
                        self.alertState.showAlert(error: error)
                        
                    }
                }
            }
            .alert(isPresented: $alertState.showAlert, content: {
                Alert(title: Text("Error!"), message: Text(alertState.errorString), dismissButton: .cancel(Text("Okay"), action: {
                    self.alertState.reset()
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
