//
//  HomeView.swift
//  Starrly
//
//  Created by Vitha Watson on 14/09/26.
//

import SwiftUI
import SwiftData

struct HomeView: View {
    @Query private var constellations: [Constellation]
    @Environment(AppState.self) private var appState

    private var isExistingUser: Bool {
        !constellations.isEmpty
    }

    private var allStars: [Star] {
        constellations.flatMap(\.stars)
    }

    private var recentlyExploredStars: [Star] {
        Array(
            allStars
                .filter { $0.firstSessionAt != nil }
                .sorted {
                    let lhs = $0.sessions.map(\.createdAt).max() ?? .distantPast
                    let rhs = $1.sessions.map(\.createdAt).max() ?? .distantPast
                    return lhs > rhs
                }
                .prefix(2)
        )
    }

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            AmbientSkyView(constellations: constellations, autoPan: true)
                .ignoresSafeArea()

            TelescopeView {
                appState.route = .discovery
            }
            .frame(maxWidth: 640)

            HStack(alignment: .top, spacing: 40) {
                VStack(alignment: .leading, spacing: 20) {
                    Text("Hello, there.")
                        .font(.system(size: 33, weight: .bold))
                        .foregroundStyle(Color.starrlyOffWhite)

                    (
                        Text("Welcome to ")
                        + Text("Starrly").fontWeight(.semibold)
                        + Text("! Here, you light up the night sky.")
                    )
                    .font(.system(size: 19))
                    .foregroundStyle(Color.starrlyOffWhite)

                    VStack(alignment: .leading, spacing: 16) {
                        if isExistingUser {
                            Button {
                                appState.route = .explore
                            } label: {
                                Text("Explore")
                                    .font(.system(size: 27, weight: .semibold))
                                    .frame(width: 280, height: 60)
                                    .contentShape(Rectangle())
                            }
                            .buttonStyle(.plain)
                            .foregroundStyle(Color.starrlyOffWhite)
                            .glassEffect(.clear, in: RoundedRectangle(cornerRadius: 24))
                        }

                        Button {
                            appState.route = .discovery
                        } label: {
                            Text("Discover")
                                .font(.system(size: 27, weight: .semibold))
                                .frame(width: 280, height: 60)
                                .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                        .foregroundStyle(Color.starrlyOffWhite)
                        .glassEffect(.clear, in: RoundedRectangle(cornerRadius: 24))
                    }

                    Spacer()
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 20) {
                    HStack(spacing: 20) {
                        HomeStatsPanel(
                            constellationCount: constellations.count,
                            starCount: allStars.count
                        )

                        MoonPhasePanel()
                            .frame(width: 160, height: 160)
                    }
                    .padding(24)
                    .frame(width: 480, height: 240)
                    .glassEffect(.clear, in: RoundedRectangle(cornerRadius: 24))

                    if isExistingUser {
                        RecentlyExploredPanel(stars: recentlyExploredStars)
                            .padding(24)
                            .frame(width: 480, height: 360)
                            .glassEffect(.clear, in: RoundedRectangle(cornerRadius: 24))

                        Text("Discover thyself, discover the universe.")
                            .font(.system(size: 13))
                            .italic()
                            .foregroundStyle(Color.starrlyOffWhite)
                            .frame(maxWidth: .infinity, alignment: .center)
                    } else {
                        Text("Learn something new to discover a constellation, and add new stars by identifying skills to work on. The more you practice, the brighter they glow!")
                            .foregroundStyle(Color.starrlyOffWhite)
                            .padding(24)
                            .glassEffect(.clear, in: RoundedRectangle(cornerRadius: 24))
                    }

                    Spacer()
                }
                .frame(maxWidth: 480)
            }
            .padding(40)
        }
    }
}
