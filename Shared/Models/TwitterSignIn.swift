//
//  TwitterSignIn.swift
//  FireOff
//
//  Created by Alex Mason on 7/17/21.
//

import Swifter
import Foundation
import AuthenticationServices

class TwitterSignIn: NSObject {
    
    private var swifter: Swifter?
    private var token: Credential.OAuthAccessToken?
    
    static let shared = TwitterSignIn()
    
    private override init() {}
    
    func signIn() {
        swifter = Swifter(consumerKey: Constants.consumerKey, consumerSecret: Constants.consumerSecret)
        swifter?.authorize(withProvider: self, callbackURL: URL(string: Constants.callbackURL)!) { token, response in
            guard let httpResponse = response as? HTTPURLResponse else { return }
            if httpResponse.statusCode == 200 {
                self.token = token
                
            } else {
                // TODO: Present error to user
            }
        }
    }
}

extension TwitterSignIn: ASWebAuthenticationPresentationContextProviding {
    
    func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        #if os(iOS)
        return UIApplication.shared.windows.filter {$0.isKeyWindow}.first!
        #elseif os(macOS)
        return NSApplication.shared.keyWindow!
        #endif
    }
}
