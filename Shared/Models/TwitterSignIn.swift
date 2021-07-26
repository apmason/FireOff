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
    
    @Published var signedIn: Bool = false {
        didSet {
            self.updateCanSendState()
        }
    }
    
    #if os(iOS)
    @Published var profileImage: UIImage?
    #elseif os(macOS)
    @Published var profileImage: NSImage?
    #endif
    
    @Published var sendingTweet: Bool = false {
        didSet {
            self.updateCanSendState()
        }
    }
    
    // TODO: - Write tests for here. Don't allow this `240` to be a magic number.
    @Published var tweetText: String = "" {
        didSet {
            self.remainingCharacters = 240 - tweetText.count
            self.updateCanSendState()
        }
    }
    
    @Published var canSend: Bool = false

    // TODO: - Test to make sure this is 240 to start with
    // TODO: - @Question - can I have 240 be a reference to a private variable, or something like that? No magic numbers! What are the benefits of `lazy`?
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
        
        swifter = Swifter(consumerKey: Constants.consumerKey,
                          consumerSecret: Constants.consumerSecret,
                          oauthToken: key,
                          oauthTokenSecret: secret)
        
        verifyCredentials()
        
        getProfilePhoto(for: userID)
    }
    
    func signIn(completion: @escaping (TwitterError?) -> Void) {
        swifter = Swifter(consumerKey: Constants.consumerKey, consumerSecret: Constants.consumerSecret)
        
        swifter?.authorize(withProvider: self, callbackURL: URL(string: Constants.callbackURL)!, success: { [weak self] token, response in
            // @ALEX: Is this the best way to do this? Using operators instead? To get everything on the main thread?
            DispatchQueue.main.async { [weak self] in
                guard let self = self, let httpResponse = response as? HTTPURLResponse else {
                    completion(.networkError)
                    return
                }
                
                if httpResponse.statusCode == 200 {
                    self.signedIn = true
                    self.token = token
                    
                    guard let token = token, let userID = token.userID else {
                        return
                    }
                    
                    /// NOTE: - Here, we will delete one of the two below functions. Either don't call verifyCredentials here (because we're already logged in, so we don't need to) or, remove getProfilePhoto(for:) because we can get the profile from verify credentials, so why duplicate calls (need to verify we always get the profile back)
                    self.getProfilePhoto(for: userID)
                    self.verifyCredentials() // @ALEX TODO: Is there a better place to put this verifyCredentials call? How to make SwiftUI testable? Then if we change something we know that things are setup properly.
                    
                    UserDefaults.standard.set("ass", forKey: self.oauthKey)
                    UserDefaults.standard.set("sso", forKey: self.oauthSecretKey)
                    UserDefaults.standard.set("dunk", forKey: self.userIDSecret)
                    
                    completion(nil)
                } else {
                    self.signedIn = false
                    completion(.apiError(statusCode: httpResponse.statusCode))
                }
            }
        }, failure: { error in
            // @ALEX: [SwiftUI] Publishing changes from background threads is not allowed; make sure to publish values from the main thread (via operators like receive(on:)) on model updates. <--- FIX THIS!!! Questions on this, obviously. Blog post!
            DispatchQueue.main.async {
                self.signedIn = false // NOTE: Should we be setting the signed in state like this? Shouldn't this be reactive to other stuff that is going on?
                let webError = ASWebAuthenticationSessionError(_nsError: (error as NSError))
                if webError.code == ASWebAuthenticationSessionError.Code.canceledLogin {
                    completion(.sessionCancelled)
                } else {
                    completion(.swiftError(error))
                }
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

            // Do a second check just to make sure that the user's credentials weren't cleared out in between the first login and now. We'll logout if there is an issue. Otherwise, present an error to the user.
            // SwiftUI error presenter?
            // TODO: - call verifyAccountCredentials. Did the post fail because the user wasn't verified? Check here. If that is the case, then sign out, so the user can reauthorize.
            // Otherwise just post the result back to the user.
            
            // pop this error back to the user
            print("Error posting my tweet!: \(error.localizedDescription)")
            
            // TODO: - Have the view listen to an error poster!
            //completion(error)
        })
    }
    
    func logout() {
        UserDefaults.standard.set(nil, forKey: self.oauthKey)
        UserDefaults.standard.set(nil, forKey: self.oauthSecretKey)
        UserDefaults.standard.set(nil, forKey: self.userIDSecret)
        
        signedIn = false
    }
    
    /**
     func checkLogin() {
     // if it's succesful present an error to the user that it was a temporary network issue.
     // if it's a real auth issue, present an error saying that the user needs to be logged out. Present an alert saying that we're logging them out, then log them out.
     
     // call logout on acceptance. Would it be best to chain that together with Combine? How to really use Combine to chain things together?
     }
     */
    
    // @ALEX We can get the profile image from the `verifyAccountCredentials` call. Does that always get returned here? I think it does, but we should test to find out. Then we can remove the call to showUser. Need to see where else that is called from.
    private func verifyCredentials() {
        swifter?.verifyAccountCredentials(success: { response in
            // parse response
            print("New response in here: \(response)")
            
        }, failure: { error in
            print("error authorizing user: \(error.localizedDescription)")
            // Present an alert to the user.
            // Your session has expired. You'll need to log back in (only one option in the alert)
            self.logout()
        })
    }
    
    private func updateCanSendState() {
        canSend = tweetText.count > 0 && remainingCharacters >= 0 && sendingTweet == false
    }
}

// MARK: - ASWebAuthenticationPresentationContextProviding

extension TwitterSignIn: ASWebAuthenticationPresentationContextProviding {
    
    func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        return ASPresentationAnchor()
    }
}

// MARK: - Profile photo fetching

extension TwitterSignIn {
    
    private func getProfilePhoto(for userID: String) {
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
