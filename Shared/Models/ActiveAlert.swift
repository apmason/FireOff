//
//  ActiveAlert.swift
//  FireOff
//
//  Created by Alex Mason on 7/26/21.
//

import SwiftUI
import Foundation

/// An object that presents an error
struct ActiveAlert {
    
    var showAlert = false
    
    private(set) var alert: Alert? {
        didSet {
            showAlert = alert != nil
        }
    }
        
    mutating func createAlert(title: String, message: String?=nil, buttonText: String, buttonAction: (() -> Void)?) {
        let messageText: Text? = message != nil ? Text(message!) : nil
        self.alert = Alert(title: Text(title), message: messageText, dismissButton: .default(Text(buttonText), action: buttonAction))
        //showAlert = true
    }
}
