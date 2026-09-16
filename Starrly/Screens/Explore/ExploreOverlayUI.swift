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
                        .foregroundStyle(Color.starrlyOffWhite)
                }
                .buttonStyle(.plain)
                .padding(10)
                .glassEffect(.starrly.interactive(), in: .circle)
            }

            Spacer()
        }
        .padding(40)
    }
}
