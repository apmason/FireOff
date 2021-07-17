//
//  TwitterSignIn.swift
//  FireOff
//
//  Created by Alex Mason on 7/17/21.
//

import Swifter
import Foundation
import AuthenticationServices

enum TwitterError: Error {
    case apiError(statusCode: Int)
    case networkError
}

class TwitterSignIn: NSObject {
    
    private var swifter: Swifter?
    private var token: Credential.OAuthAccessToken?
    
    static let shared = TwitterSignIn()
    
    private override init() {}
    
    func signIn(completion: @escaping (Result<Void, TwitterError>) -> Void) {
        swifter = Swifter(consumerKey: Constants.consumerKey, consumerSecret: Constants.consumerSecret)
        swifter?.authorize(withProvider: self, callbackURL: URL(string: Constants.callbackURL)!) { token, response in
            guard let httpResponse = response as? HTTPURLResponse else {
                completion(.failure(.networkError))
                return
            }
            
            if httpResponse.statusCode == 200 {
                self.token = token
                completion(.success(()))
            } else {
                completion(.failure(.apiError(statusCode: httpResponse.statusCode)))
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
