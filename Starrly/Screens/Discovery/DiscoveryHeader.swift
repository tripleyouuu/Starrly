//
//  DiscoveryHeader.swift
//  Starrly
//
//  Created by Vitha Watson on 14/09/26.
//


import SwiftUI

struct DiscoveryHeader: View {
    let onBack: () -> Void

    var body: some View {
        ZStack {
            HStack {
                BackButton(action: onBack)
                Spacer()
            }

            Text("Discovery")
                .font(.system(size: 33, weight: .bold))
                .foregroundStyle(Color.starrlyOffWhite)
        }
    }
}