//
//  ContentView.swift
//  Shared
//
//  Created by Alex Mason on 7/17/21.
//

import SwiftUI

struct AlertState {
    var showAlert = false
    private var errorCode: Int?
    
    mutating func showAlert(_ errorCode: Int?) {
        self.showAlert = true
        self.errorCode = errorCode
    }
    
    mutating func reset() {
        self.showAlert = false
        self.errorCode = nil
    }
    
    var errorString: String {
        if let errorCode = errorCode {
            return "Error code: \(errorCode)"
        } else {
            return "Network error"
        }
    }
}

struct ContentView: View {
    @State var alertState = AlertState()
    
    var body: some View {
        Button("Log In With Twitter") {
            TwitterSignIn.shared.signIn { result in
                switch result {
                case .success:
                    // to new view
                    break
                    
                case .failure(let error):
                    switch error {
                    case .networkError:
                        self.alertState.showAlert(nil)
                        
                    case .apiError(statusCode: let code):
                        self.alertState.showAlert(code)
                    }
                }
            }
        }
        .alert(isPresented: $alertState.showAlert, content: {
            Alert.init(title: Text("Error"), message: Text(alertState.errorString), dismissButton: .cancel(Text("Okay"), action: {
                self.alertState.reset()
            }))
        })
        .padding(.all)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
