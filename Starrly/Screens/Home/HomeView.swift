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
    @AppStorage("hasShownFirstConstellationTagline") private var hasShownTagline = false

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

    private var showsTagline: Bool {
        constellations.count == 1 && !hasShownTagline
    }

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            TelescopeView {
                appState.route = .discovery
            }
            .padding(40)

            HStack(alignment: .top, spacing: 40) {
                VStack(alignment: .leading, spacing: 20) {
                    Text("Hello, there.")
                        .font(.largeTitle)
                        .foregroundStyle(Color.starrlyOffWhite)

                    Text("Welcome to Starrly! Here, you light up the night sky.")
                        .foregroundStyle(Color.starrlyOffWhite)

                    HStack(spacing: 20) {
                        Button("Discover") {
                            appState.route = .discovery
                        }
                        .buttonStyle(.plain)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .foregroundStyle(Color.starrlyOffWhite)
                        .glassEffect(.starrly.interactive(), in: .capsule)

                        if isExistingUser {
                            Button("Explore") {
                                appState.route = .explore
                            }
                            .buttonStyle(.plain)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 10)
                            .foregroundStyle(Color.starrlyOffWhite)
                            .glassEffect(.starrly.interactive(), in: .capsule)
                        }
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
                            .frame(width: 60, height: 60)
                    }
                    .padding(20)
                    .glassEffect(.starrly, in: .rect(cornerRadius: 20))

                    if isExistingUser {
                        RecentlyExploredPanel(stars: recentlyExploredStars)
                            .padding(20)
                            .glassEffect(.starrly, in: .rect(cornerRadius: 20))
                    } else {
                        Text("Learn something new to discover a constellation, and add new stars by identifying skills to work on. The more you practice, the brighter they glow!")
                            .foregroundStyle(Color.starrlyOffWhite)
                            .padding(20)
                            .glassEffect(.starrly, in: .rect(cornerRadius: 20))
                    }

                    if showsTagline {
                        Text("Discover thyself, discover the universe.")
                            .italic()
                            .foregroundStyle(Color.starrlyOffWhite)
                            .onAppear {
                                hasShownTagline = true
                            }
                    }

                    Spacer()
                }
            }
            .padding(40)
        }
    }
}
