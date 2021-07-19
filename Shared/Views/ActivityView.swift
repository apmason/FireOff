//
//  ActivityView.swift
//  FireOff
//
//  Created by Alex Mason on 7/18/21.
//

import SwiftUI

struct ActivityView: View {
    var body: some View {
        ZStack {
            ProgressView()
        }
        .frame(width: 100, height: 100, alignment: .center)
        .background(Color.black.opacity(0.8))
        .cornerRadius(10)
        .progressViewStyle(CircularProgressViewStyle(tint: .white))
    }
}

struct ActivityView_Previews: PreviewProvider {
    static var previews: some View {
        ActivityView()
    }
}
