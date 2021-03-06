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

typealias Success = Bool

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
    
    @Published var tweetText: String = "" {
        didSet {
            self.remainingCharacters = 240 - tweetText.count
            self.updateCanSendState()
        }
    }
    
    @Published var canSend: Bool = false

    @Published private(set) var remainingCharacters: Int = 240
    @Published var activeAlert = ActiveAlert()
    
    private var token: Credential.OAuthAccessToken?
    
    var userName: String? {
        return token?.screenName
    }
    
    fileprivate let oauthKey = "twitter_oauth_key"
    fileprivate let oauthSecretKey = "twitter_oauth_secret"
    fileprivate let userIDKey = "twitter_userID"
    
    private override init() {
        super.init()
        
        // We already have the keys stored, so make the Swifter object right away.
        guard let key = UserDefaults.standard.string(forKey: oauthKey),
              let secret = UserDefaults.standard.string(forKey: oauthSecretKey) else {
            return
        }
                
        swifter = Swifter(consumerKey: Constants.consumerKey,
                          consumerSecret: Constants.consumerSecret,
                          oauthToken: key,
                          oauthTokenSecret: secret)
        
        setSavedImage()
        
        signedIn = true
        
        verifyCredentials(fetchProfileImage: true, completion: { success in
            if !success {
                self.createSessionExpiredAlert()
            }
        })
    }
    
    // TODO: This is an ugly function, make it nicer
    func signIn(completion: @escaping (TwitterError?) -> Void) {
        swifter = Swifter(consumerKey: Constants.consumerKey, consumerSecret: Constants.consumerSecret)
        
        swifter?.authorize(withProvider: self, callbackURL: URL(string: Constants.callbackURL)!, success: { [weak self] token, response in
            DispatchQueue.main.async { [weak self] in
                guard let self = self, let httpResponse = response as? HTTPURLResponse else {
                    completion(.networkError)
                    return
                }
                
                if httpResponse.statusCode == 200, let token = token {
                    self.signedIn = true
                    self.token = token
                    
                    self.verifyCredentials(fetchProfileImage: true, completion: { success in
                        if !success {
                            self.createSessionExpiredAlert()
                        }
                    })
                    
                    UserDefaults.standard.set(token.key, forKey: self.oauthKey)
                    UserDefaults.standard.set(token.secret, forKey: self.oauthSecretKey)
                    UserDefaults.standard.set(token.userID, forKey: self.userIDKey)
                    
                    completion(nil)
                } else {
                    self.signedIn = false
                    completion(.apiError(statusCode: httpResponse.statusCode))
                }
            }
        }, failure: { error in
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
        
        swifter?.postTweet(status: tweetText, success: { [weak self] result in
            guard let self = self else { return }
            self.sendingTweet = false
            self.tweetText = ""
            
            print("Tweet sent: \(result)")
        }, failure: { [weak self] error in
            guard let self = self else { return }
            self.sendingTweet = false
            
            print("Error posting my tweet!: \(error.localizedDescription)")
            // See if the user's token is still valid. If it is, say we failed to send the tweet. If it's not, tell them we need them to re-auth.
            self.verifyCredentials(fetchProfileImage: false) { [weak self] success in
                guard let self = self else { return }
                // The user was verified but
                if success {
                    self.activeAlert.createAlert(title: "Oops!",
                                                 message: "Tweet failed to send",
                                                 buttonText: "Okay",
                                                 buttonAction: {
                                                    // We don't need to do anything in here, but we want our button to be clickable
                                                 })
                } else {
                    self.createSessionExpiredAlert()
                }
            }
        })
    }
    
    func logout() {
        UserDefaults.standard.set(nil, forKey: self.oauthKey)
        UserDefaults.standard.set(nil, forKey: self.oauthSecretKey)
        UserDefaults.standard.set(nil, forKey: self.userIDKey)
        
        signedIn = false
    }
    
    /**
     // call logout on acceptance. Would it be best to chain that together with Combine? How to really use Combine to chain things together?
     */
    
    /// Verify a signed in Twitter user's credentials. If the verification fails an error will be presented and the user will be logged out right immediately.
    /// - Parameter fetchProfileImage: A Boolean value determining if a succesful response should download the latest profile image URL.
    /// - Parameter completion: A closure that is passed a `Success` value and returns nothing. `Success` will be `true` if the user was verified succesfully and `false` otherwise.
    private func verifyCredentials(fetchProfileImage: Bool, completion: @escaping ((Success) -> Void)) {
        swifter?.verifyAccountCredentials(success: { json in
            // Should we fetch the profile photo in here?
            print("Verifying account, response is \(json)")
            if fetchProfileImage {
                guard case .object(let dict) = json,
                      let profilePath = dict["profile_image_url_https"],
                      case .string(let path) = profilePath,
                      let imageURL = URL(string: path) else {
                    print("Failed to get profile image URL")
                    return
                }
                
                self.downloadProfileImage(imageURL)
            }
            
            completion(true)
        }, failure: { error in
            print("error authorizing user: \(error.localizedDescription)")
            completion(false)
        })
    }
    
    private func createSessionExpiredAlert() {
        self.activeAlert.createAlert(title: "Session expired!", message: "You'll need to log back in", buttonText: "Okay") { [weak self] in
            self?.logout()
        }
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
    
    /// Downloads the user's profile image
    private func downloadProfileImage(_ url: URL) {
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            guard let self = self, error == nil, let data = data else {
                print("Error downloading photo: \(String(describing: error?.localizedDescription))")
                return
            }
            
            ImageSaver.saveImage(data)
            
            DispatchQueue.main.async {
                #if os(iOS)
                self.profileImage = UIImage(data: data)
                #elseif os(macOS)
                self.profileImage = NSImage(data: data)
                #endif
            }
        }.resume()
    }
    
    private func setSavedImage() {
        guard let data = ImageSaver.retrieveImageData() else {
            return
        }
                
        DispatchQueue.main.async {
            #if os(iOS)
            self.profileImage = UIImage(data: data)
            #elseif os(macOS)
            self.profileImage = NSImage(data: data)
            #endif
        }
    }
}
