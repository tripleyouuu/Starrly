//
//  HomeView.swift
//  Starrly
//
//  Created by Vitha Watson on 14/09/26.
//

import SwiftUI
import SwiftData
import TipKit

struct HomeView: View {
    @Query private var constellations: [Constellation]
    @Environment(AppState.self) private var appState

    private var isExistingUser: Bool {
        !constellations.isEmpty
    }

    private var allStars: [Star] {
        constellations.flatMap(\.stars)
    }

    private var hasRecordedSession: Bool {
        !recentlyExploredStars.isEmpty
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
        GeometryReader { geometry in
            let telescopeMaxWidth = max(160, min(640, geometry.size.width - 560))

            ZStack(alignment: .bottomLeading) {
                AmbientSkyView(constellations: constellations, autoPan: true)
                    .ignoresSafeArea()

                TelescopeView {
                    appState.route = .discovery
                }
                .frame(maxWidth: telescopeMaxWidth)

                HStack(alignment: .top, spacing: 40) {
                    VStack(alignment: .leading, spacing: 20) {
                        Text("Welcome to Starrly!")
                            .font(.system(size: 33, weight: .bold))
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
                                .glassEffect(.starrly, in: RoundedRectangle(cornerRadius: 24))
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
                            .glassEffect(.starrly, in: RoundedRectangle(cornerRadius: 24))
                            .popoverTip(TelescopeTip(), arrowEdge: .trailing)
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
                        .glassEffect(.starrly, in: RoundedRectangle(cornerRadius: 24))
                        .contentShape(Rectangle())
                        .onTapGesture {}

                        if hasRecordedSession {
                            RecentlyExploredPanel(stars: recentlyExploredStars)
                                .padding(24)
                                .frame(width: 480, height: 360)
                                .glassEffect(.starrly, in: RoundedRectangle(cornerRadius: 24))
                                .contentShape(Rectangle())
                                .onTapGesture {}

                            Text("Discover thyself, discover the universe.")
                                .font(.system(size: 13))
                                .italic()
                                .foregroundStyle(Color.starrlyOffWhite)
                                .frame(maxWidth: .infinity, alignment: .center)
                        } else {
                            GettingStartedPanel()
                                .padding(24)
                                .frame(width: 480, height: 360)
                                .glassEffect(.starrly, in: RoundedRectangle(cornerRadius: 24))
                                .contentShape(Rectangle())
                                .onTapGesture {}
                        }

                        Spacer()
                    }
                    .frame(maxWidth: 480)
                }
                .padding(40)
            }
        }
    }
}
