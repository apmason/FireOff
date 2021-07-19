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

enum TwitterError: Error {
    case apiError(statusCode: Int)
    case networkError
    case sessionCancelled
    case defaultError(Error)
}

class TwitterSignIn: NSObject, ObservableObject {
    
    private var swifter: Swifter?    
    static let shared = TwitterSignIn()
    
    @Published var signedIn: Bool = false
    
    private override init() {}
    
    func signIn(completion: @escaping (Result<Void, TwitterError>) -> Void) {
        swifter = Swifter(consumerKey: Constants.consumerKey, consumerSecret: Constants.consumerSecret)
        swifter?.authorize(withProvider: self, callbackURL: URL(string: Constants.callbackURL)!, success: { token, response in
            guard let httpResponse = response as? HTTPURLResponse else {
                completion(.failure(.networkError))
                return
            }
            
            if httpResponse.statusCode == 200 {
                self.signedIn = true
                completion(.success(()))
            } else {
                self.signedIn = false
                completion(.failure(.apiError(statusCode: httpResponse.statusCode)))
            }
        }, failure: { error in
            self.signedIn = false
            let webError = ASWebAuthenticationSessionError(_nsError: (error as NSError))
            if webError.code == ASWebAuthenticationSessionError.Code.canceledLogin {
                completion(.failure(.sessionCancelled))
            } else {
                completion(.failure(.defaultError(error)))
            }
        })
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
