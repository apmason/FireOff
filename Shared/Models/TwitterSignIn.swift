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
#if os(iOS)
import UIKit
#elseif os(macOS)
import AppKit
#endif

class TwitterSignIn: NSObject, ObservableObject {
    
    private var swifter: Swifter?    
    static let shared = TwitterSignIn()
    
    @Published var signedIn: Bool = false
    
    #if os(iOS)
    @Published var profileImage: UIImage?
    #elseif os(macOS)
    @Published var profileImage: NSImage?
    #endif
    
    @Published var sendingTweet: Bool = false {
        didSet {
            self.updateButtonState()
        }
    }
    
    // TODO: - Tests for here
    @Published var tweetText: String = "" {
        didSet {
            self.remainingCharacters = 240 - tweetText.count
            self.updateButtonState()
        }
    }
    
    @Published var canSend: Bool = false

    // TODO: - Test to make sure this is 240 to start with
    // TODO: - @Question - can I have 240 be a reference to a private variable, or something like that?
    @Published private(set) var remainingCharacters: Int = 240
    
    private var token: Credential.OAuthAccessToken?
    
    var userName: String? {
        return token?.screenName
    }
    
    fileprivate let oauthKey = "twitter_oauth_key"
    fileprivate let oauthSecretKey = "twitter_oauth_secret"
    fileprivate let userIDSecret = "twitter_userID"
    
    private override init() {
        super.init()
        
        // We already have the keys stored, so make the Swifter object right away.
        guard let key = UserDefaults.standard.string(forKey: oauthKey),
              let secret = UserDefaults.standard.string(forKey: oauthSecretKey),
              let userID = UserDefaults.standard.string(forKey: userIDSecret) else {
            return
        }
        
        signedIn = true // TODO: Better way to observe the signed in state?
        updateButtonState()
        
        swifter = Swifter(consumerKey: Constants.consumerKey,
                          consumerSecret: Constants.consumerSecret,
                          oauthToken: key,
                          oauthTokenSecret: secret)
        
        // Get the user's information
        swifter?.showUser(UserTag.id(userID), success: { json in
            guard case let .object(dict) = json,
                  let profilePath = dict["profile_image_url_https"],
                  case let .string(path) = profilePath else {
                print("Failed to get profile image URL")
                return
            }
            
            guard let imageURL = URL(string: path) else {
                return
            }
            
            self.downloadProfile(imageURL)
            
        }, failure: { error in
            print("There was an error getting user info")
            // TODO: - Call authentication route to make sure we're signed in properly
        })
    }
    
    private func updateButtonState() {
        canSend = tweetText.count > 0 && remainingCharacters >= 0 && sendingTweet == false
    }
    
    /// TODO: - Add another function here that sees if the user is logged in with the right credentials. If not, clear out UserDefaults and set the state to signed out so we can exit.
    
    func signIn(completion: @escaping (TwitterError?) -> Void) {
        swifter = Swifter(consumerKey: Constants.consumerKey, consumerSecret: Constants.consumerSecret)
        
        swifter?.authorize(withProvider: self, callbackURL: URL(string: Constants.callbackURL)!, success: { [weak self] token, response in
            guard let self = self, let httpResponse = response as? HTTPURLResponse else {
                completion(.networkError)
                return
            }
            
            if httpResponse.statusCode == 200 {
                self.signedIn = true
                self.token = token
                
                guard let token = token else {
                    return
                }
                
                UserDefaults.standard.set(token.key, forKey: self.oauthKey)
                UserDefaults.standard.set(token.secret, forKey: self.oauthSecretKey)
                UserDefaults.standard.set(token.userID, forKey: self.userIDSecret)
                
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
    
    func sendTweet() {
        guard tweetText.count <= 240 else {
            assertionFailure("This shouldn't happen!")
            return
        }
        
        guard !self.sendingTweet else {
            return
        }
        
        self.sendingTweet = true
        
        swifter?.postTweet(status: tweetText, success: { result in
            self.sendingTweet = false
            self.tweetText = ""
            
            print("Tweet sent: \(result)")
            
            // TODO: - Have the view listen to an error poster!
            //completion(nil)
        }, failure: { error in
            self.sendingTweet = false

            // TODO: - call verifyAccountCredentials. Did the post fail because the user wasn't verified? Check here. If that is the case, then sign out, so the user can reauthorize.
            // Otherwise just post the result back to the user.
            
            // pop this error back to the user
            print("Error posting my tweet!: \(error.localizedDescription)")
            
            // TODO: - Have the view listen to an error poster!
            //completion(error)
        })
    }
}

extension TwitterSignIn: ASWebAuthenticationPresentationContextProviding {
    
    func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        return ASPresentationAnchor()
    }
}

extension TwitterSignIn {
    
    /// Downloads the user's profile image
    private func downloadProfile(_ url: URL) {
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            guard let self = self, error == nil, let data = data else {
                print("Error downloading photo: \(String(describing: error?.localizedDescription))")
                return
            }
            
            DispatchQueue.main.async {
                #if os(iOS)
                self.profileImage = UIImage(data: data)
                #elseif os(macOS)
                self.profileImage = NSImage(data: data)
                #endif
            }
        }.resume()
    }
}
