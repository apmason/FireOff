//
//  ImageSaver.swift
//  FireOff
//
//  Created by Alexander Mason on 7/26/21.
//

import Foundation

class ImageSaver {
    
    fileprivate static let profileKey = "profile_image"
    
    static func saveImage(_ data: Data) {
        guard let filePath = filePath(for: profileKey) else {
            return
        }
        
        do {
            try data.write(to: filePath, options: .atomic)
        } catch {
            print("Error saving file: \(error.localizedDescription)")
        }
    }
    
    static func retrieveImageData() -> Data? {
        guard let filePath = filePath(for: profileKey) else {
            return nil
        }
        
        return FileManager.default.contents(atPath: filePath.path)
    }
    
    private static func filePath(for key: String) -> URL? {
        let fileManager = FileManager.default
        guard let documentURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return nil
        }
        
        return documentURL.appendingPathComponent(key + ".jpg")
    }
}
