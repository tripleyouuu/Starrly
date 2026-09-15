//
//  DiscoveryFlowView.swift
//  Starrly
//
//  Created by Vitha Watson on 14/09/26.
//

import SwiftUI
import SwiftData

struct DiscoveryFlowView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(AppState.self) private var appState
    @Query private var allConstellations: [Constellation]
    @State private var constellationName: String?

    var body: some View {
        ZStack {
            AmbientSkyView(constellations: allConstellations)
                .ignoresSafeArea()

            if let constellationName {
                NameFirstStarStep(
                    onBack: { self.constellationName = nil },
                    onSubmit: { starName in
                        createConstellation(name: constellationName, firstStarName: starName)
                    }
                )
            } else {
                NameConstellationStep(
                    onBack: { appState.route = .home },
                    onSubmit: { name in
                        constellationName = name
                    }
                )
            }
        }
    }

    private func createConstellation(name: String, firstStarName: String) {
        let constellation = Constellation(name: name)
        let existingPositions = allConstellations.compactMap(\.explorePosition)
        constellation.explorePosition = ExploreLayoutEngine.placeNewConstellation(among: existingPositions)

        let color = StarColor.allCases.randomElement() ?? .lavender
        let position = ConstellationLayoutEngine.placeNewStar(among: [])
        let star = Star(name: firstStarName, color: color, localPosition: position)
        star.constellation = constellation
        constellation.stars.append(star)

        modelContext.insert(constellation)

        appState.route = .constellation(constellation.id, returnTo: .home)
    }
}
