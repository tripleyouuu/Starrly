//
//  RecentlyExploredPanel.swift
//  Starrly
//
//  Created by Vitha Watson on 14/09/26.
//

import SwiftUI

struct RecentlyExploredPanel: View {
    let stars: [Star]
    @Environment(AppState.self) private var appState

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Recently explored")
                .foregroundStyle(Color.starrlyOffWhite)

            ForEach(stars) { star in
                Button {
                    appState.route = .star(star.id, returnTo: .home)
                } label: {
                    HStack(spacing: 16) {
                        StarView(type: star.type, color: star.color)
                            .frame(width: 32, height: 32)

                        VStack(alignment: .leading, spacing: 2) {
                            Text(star.name)
                                .foregroundStyle(Color.starrlyOffWhite)
                            Text(star.constellation?.name ?? "")
                                .foregroundStyle(Color.starrlyOffWhite.opacity(0.7))
                        }

                        Spacer()

                        Image(systemName: "chevron.right")
                            .foregroundStyle(Color.starrlyOffWhite)
                    }
                }
                .buttonStyle(.plain)
            }
        }
    }
}
