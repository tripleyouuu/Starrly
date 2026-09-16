//
//  GettingStartedPanel.swift
//  Starrly
//
//  Created by Vitha Watson on 16/09/26.
//

import SwiftUI

struct GettingStartedPanel: View {
    @State private var starColor: StarColor = .lavender

    var body: some View {
        VStack(spacing: 56) {
            StarView(type: .giant, color: starColor)
                .frame(width: 140, height: 140)
                .animation(.easeInOut(duration: 1.2), value: starColor)

            Text("Learn something new to discover a constellation, and add new stars by identifying skills to work on. The more you practice, the brighter they glow!")
                .font(.system(size: 16, weight: .regular))
                .foregroundStyle(Color.starrlyOffWhite)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .task {
            await cycleStarColors()
        }
    }

    private func cycleStarColors() async {
        let colors = StarColor.allCases
        var index = 0
        while !Task.isCancelled {
            try? await Task.sleep(nanoseconds: 1_500_000_000)
            index = (index + 1) % colors.count
            starColor = colors[index]
        }
    }
}
