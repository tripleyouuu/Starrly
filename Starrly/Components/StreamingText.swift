//
//  StreamingText.swift
//  Starrly
//
//  Created by Vitha Watson on 16/09/26.
//

import SwiftUI

struct StreamingText: View {
    let text: String
    var charactersPerSecond: Double = 35

    @Environment(AppSettings.self) private var settings
    @State private var revealedCount = 0

    var body: some View {
        Text(String(text.prefix(revealedCount)))
            .task(id: text) {
                guard settings.isMotionEnabled else {
                    revealedCount = text.count
                    return
                }
                revealedCount = 0
                guard !text.isEmpty else { return }
                let interval = 1.0 / charactersPerSecond
                for count in 1...text.count {
                    try? await Task.sleep(for: .seconds(interval))
                    guard !Task.isCancelled else { return }
                    revealedCount = count
                }
            }
    }
}
