//
//  ExploreOverlayUI.swift
//  Starrly
//
//  Created by Vitha Watson on 14/09/26.
//

import SwiftUI

struct ExploreOverlayUI: View {
    let onBack: () -> Void
    let onDiscover: () -> Void

    var body: some View {
        VStack {
            HStack {
                BackButton(action: onBack)

                Spacer()

                Button(action: onDiscover) {
                    Image(systemName: "plus")
                        .font(.system(size: 19, weight: .regular))
                        .foregroundStyle(Color.starrlyOffWhite)
                        .frame(width: 48, height: 48)
                        .contentShape(Circle())
                }
                .buttonStyle(.plain)
                .glassEffect(.starrly.interactive(), in: .circle)
            }

            Spacer()
        }
        .padding(40)
    }
}
