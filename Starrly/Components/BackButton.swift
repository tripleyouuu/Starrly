//
//  BackButton.swift
//  Starrly
//
//  Created by Vitha Watson on 14/09/26.
//

import SwiftUI

struct BackButton: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: "chevron.left")
                .foregroundStyle(Color.starrlyOffWhite)
        }
        .buttonStyle(.plain)
        .padding(10)
        .glassEffect(.starrly.interactive(), in: .circle)
    }
}
