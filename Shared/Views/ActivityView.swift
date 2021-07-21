//
//  ActivityView.swift
//  FireOff
//
//  Created by Alex Mason on 7/18/21.
//

import SwiftUI

struct ActivityView: View {
    
    var opacity: Double {
        #if os(iOS)
        return 0.8
        #else
        return 0.3
        #endif
    }
    
    var body: some View {
        ZStack {
            ProgressView()
        }
        .frame(width: 100, height: 100, alignment: .center)
        .background(Color.black.opacity(opacity))
        .cornerRadius(10)
        .progressViewStyle(CircularProgressViewStyle(tint: .white))
    }
}

struct ActivityView_Previews: PreviewProvider {
    static var previews: some View {
        ActivityView()
    }
}
