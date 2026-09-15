//
//  HomeStatsPanel.swift
//  Starrly
//
//  Created by Vitha Watson on 14/09/26.
//

import SwiftUI

struct HomeStatsPanel: View {
    let constellationCount: Int
    let starCount: Int

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            statRow(label: "Constellations discovered", value: constellationCount)
            statRow(label: "Star systems illuminated", value: starCount)
        }
    }

    private func statRow(label: String, value: Int) -> some View {
        HStack(spacing: 20) {
            Text(label)
                .foregroundStyle(Color.starrlyOffWhite)

            Spacer()

            Text("\(value)")
                .font(.title2)
                .bold()
                .foregroundStyle(Color.starrlyOffWhite)
        }
    }
}
