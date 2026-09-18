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
        VStack(spacing: 0) {
            Text("Recently explored")
                .font(.system(size: 27, weight: .semibold))
                .foregroundStyle(Color.starrlyOffWhite)
                .frame(maxWidth: .infinity, alignment: .center)

            ForEach(stars) { star in
                Spacer()

                Button {
                    appState.route = .star(star.id, returnTo: .home)
                } label: {
                    HStack(spacing: 24) {
                        StarView(type: star.type, color: star.color)
                            .frame(width: 32, height: 32)

                        VStack(alignment: .leading, spacing: 6) {
                            Text(star.name)
                                .font(.system(size: 21, weight: .semibold))
                                .foregroundStyle(Color.starrlyOffWhite)
                                .lineLimit(1)
                            Text(star.constellation?.name ?? "")
                                .font(.system(size: 19))
                                .foregroundStyle(Color.starrlyOffWhite.opacity(0.7))
                                .lineLimit(1)
                        }
                        .frame(maxWidth: 260, alignment: .leading)

                        Spacer()

                        Image(systemName: "chevron.right")
                            .font(.system(size: 21, weight: .semibold))
                            .foregroundStyle(Color.starrlyOffWhite)
                    }
                }
                .padding(.horizontal,16)
                .buttonStyle(.plain)
            }

            Spacer()
        }
    }
}
