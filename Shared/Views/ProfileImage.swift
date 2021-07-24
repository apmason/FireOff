//
//  ProfileImage.swift
//  FireOff
//
//  Created by Alexander Mason on 7/23/21.
//

import SwiftUI

struct ProfileImage: View {
    
    @ObservedObject var twitterModel: TwitterSignIn = TwitterSignIn.shared
    
    var body: some View {
        Color.gray
//        if let profileImage = twitterModel.profileImage {
//            #if os(iOS)
//            Image(uiImage: profileImage)
////                .frame(width: 30, height: 30)
////                .cornerRadius(15)
//            #elseif os(macOS)
//            Image(nsImage: profileImage)
////                .frame(width: 30, height: 30)
////                .cornerRadius(15)
//            #endif
//        } else {
//            Color.gray
////                .frame(width: 30, height: 30)
////                .cornerRadius(15)
//        }
    }
}

struct ProfileImage_Previews: PreviewProvider {
    static var previews: some View {
        ProfileImage()
    }
}
