//
//  AlertState.swift
//  FireOff
//
//  Created by Alex Mason on 7/18/21.
//

import Foundation

struct ErrorAlert {
    var showAlert = false
    private var error: Error?
    
    /// Show an alert to the user
    /// - Parameters:
    ///   - error: An Error to present to the user, if one exists.
    mutating func showAlert(for error: Error) {
        self.showAlert = true
        self.error = error
    }
    
    /// Set the state so there is no alert to show.
    mutating func reset() {
        self.showAlert = false
        self.error = nil
    }
    
    /// A string to present to the user.
    var errorString: String {
        if let error = error {
            return "\(error.localizedDescription)"
        } else {
            return "An unknown error occured"
        }
    }
}
