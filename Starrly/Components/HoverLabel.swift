//
//  HoverLabel.swift
//  Starrly
//
//  Created by Vitha Watson on 14/09/26.
//

import SwiftUI

struct HoverLabel: View {
    let text: String

    var body: some View {
        Text(text)
            .foregroundStyle(Color.starrlyOffWhite)
            .lineLimit(1)
            .frame(maxWidth: 220, alignment: .leading)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .glassEffect(.starrly, in: .capsule)
            .allowsHitTesting(false)
    }
}
