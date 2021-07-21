//
//  TwitterSignIn.swift
//  FireOff
//
//  Created by Alex Mason on 7/17/21.
//

import Swifter
import SwiftUI
import Foundation
import AuthenticationServices


class TwitterSignIn: NSObject, ObservableObject {
    
    private var swifter: Swifter?    
    static let shared = TwitterSignIn()
    
    @Published var signedIn: Bool = false
    
    private var token: Credential.OAuthAccessToken?
    
    var userName: String? {
        return token?.screenName
    }
    
    fileprivate let oauthKey = "key"
    fileprivate let secretKey = "secret"
    
    private override init() {}
    
    func signIn(completion: @escaping (TwitterError?) -> Void) {
        // We already have the keys stored, so make the Swifter object right away.
        if let key = UserDefaults.standard.string(forKey: oauthKey),
           let secret = UserDefaults.standard.string(forKey: secretKey) {
            swifter = Swifter(consumerKey: Constants.consumerKey,
                                   consumerSecret: Constants.consumerSecret,
                                   oauthToken: key,
                                   oauthTokenSecret: secret)
            signedIn = true
            completion(nil)
            return
        }
        
        swifter = Swifter(consumerKey: Constants.consumerKey, consumerSecret: Constants.consumerSecret)
        
        swifter?.authorize(withProvider: self, callbackURL: URL(string: Constants.callbackURL)!, success: { token, response in
            guard let httpResponse = response as? HTTPURLResponse else {
                completion(.networkError)
                return
            }
            
            if httpResponse.statusCode == 200 {
                self.signedIn = true
                self.token = token
                
                guard let token = token else {
                    return
                }
                
                UserDefaults.standard.set(token.key, forKey: "key")
                UserDefaults.standard.set(token.secret, forKey: "secret")
                completion(nil)
            } else {
                self.signedIn = false
                completion(.apiError(statusCode: httpResponse.statusCode))
            }
        }, failure: { error in
            self.signedIn = false
            let webError = ASWebAuthenticationSessionError(_nsError: (error as NSError))
            if webError.code == ASWebAuthenticationSessionError.Code.canceledLogin {
                completion(.sessionCancelled)
            } else {
                completion(.swiftError(error))
            }
        })
    }
    
    func sendTweet(_ tweet: String, completion: @escaping (Error?) -> Void) {
        guard tweet.count <= 240 else {
            assertionFailure("This shouldn't happen!")
            return
        }
        
        swifter?.postTweet(status: tweet, success: { result in
            // analyze this result
            print("Analyzing the result: \(result.description)")
            completion(nil)
        }, failure: { error in
            // pop this error back to the user
            print("Error posting my tweet!: \(error.localizedDescription)")
            completion(error)
        })
    }
}

extension TwitterSignIn: ASWebAuthenticationPresentationContextProviding {
    
    func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        return ASPresentationAnchor()
    }
}
