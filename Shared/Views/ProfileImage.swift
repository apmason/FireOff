//
//  ProfileImage.swift
//  FireOff
//
//  Created by Alexander Mason on 7/23/21.
//

import SwiftUI

struct ProfileImage: View {
    
    @ObservedObject var twitterModel: TwitterSignIn
    
    var body: some View {
        if let profileImage = twitterModel.profileImage {
            #if os(iOS)
            Image(uiImage: profileImage)
            #elseif os(macOS)
            Image(nsImage: profileImage)
            #endif
        } else {
            Color.gray
        }
    }
}

struct ProfileImage_Previews: PreviewProvider {
    static var previews: some View {
        ProfileImage(twitterModel: TwitterSignIn.shared)
    }
}
