//
//  TwitterError.swift
//  FireOff (iOS)
//
//  Created by Alex Mason on 7/20/21.
//

import Foundation

enum TwitterError: Error {
    case apiError(statusCode: Int)
    case networkError
    case sessionCancelled
    case swiftError(Error)
}

extension TwitterError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .apiError(statusCode: let code):
            return NSLocalizedString("Non-200 HTTP Status Code returned. Code was: \(code)", comment: "API Error")
            
        case .networkError:
            return NSLocalizedString("Network error occured", comment: "Network Error")
            
        case .sessionCancelled:
            return NSLocalizedString("Session was cancelled", comment: "Session Cancelled")
            
        case .swiftError(let error):
            return NSLocalizedString("An error occured: \(error.localizedDescription)", comment: "Default error")
            
        }
    }
}
