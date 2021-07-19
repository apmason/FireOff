//
//  AlertState.swift
//  FireOff
//
//  Created by Alex Mason on 7/18/21.
//

import Foundation

struct AlertState {
    var showAlert = false
    private var errorCode: Int?
    private var errorDescription: String?
    
    
    /// Show an alert to the user
    /// - Parameters:
    ///   - errorCode: An HTTP error code to show to the user, if one exists.
    ///   - error: An Error to present to the user, if one exists.
    mutating func showAlert(errorCode: Int?=nil, error: Error?=nil) {
        self.showAlert = true
        self.errorDescription = error?.localizedDescription
        self.errorCode = errorCode
    }
    
    /// Set the state so there is no alert to show.
    mutating func reset() {
        self.showAlert = false
        self.errorCode = nil
        self.errorDescription = nil
    }
    
    /// A string to present to the user.
    var errorString: String {
        if let errorCode = errorCode {
            return "Error code: \(errorCode)"
        } else if let description = errorDescription {
            return "Error: \(description)"
        } else {
            return "Network error"
        }
    }
}
