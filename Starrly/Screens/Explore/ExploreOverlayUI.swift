//
//  ExploreOverlayUI.swift
//  Starrly
//
//  Created by Vitha Watson on 14/09/26.
//

import SwiftUI

struct ExploreOverlayUI: View {
    let labelText: String?
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

            if let labelText {
                Text(labelText)
                    .foregroundStyle(Color.starrlyOffWhite)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .glassEffect(.starrly, in: .capsule)
            }

            Spacer()
        }
        .padding(40)
    }
}
