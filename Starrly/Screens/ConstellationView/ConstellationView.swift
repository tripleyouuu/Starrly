//
//  ConstellationView.swift
//  Starrly
//
//  Created by Vitha Watson on 14/09/26.
//

import SwiftUI
import SwiftData
import TipKit

struct ConstellationView: View {
    let constellationID: UUID
    let returnTo: Route

    @Environment(AppState.self) private var appState
    @Query private var constellations: [Constellation]
    @Query private var allConstellations: [Constellation]

    private static let mapHideThreshold: CGFloat = 900

    init(constellationID: UUID, returnTo: Route) {
        self.constellationID = constellationID
        self.returnTo = returnTo
        let id = constellationID
        _constellations = Query(filter: #Predicate<Constellation> { $0.id == id })
    }

    private var constellation: Constellation? {
        constellations.first
    }

    var body: some View {
        ZStack {
            AmbientSkyView(constellations: allConstellations, isBlurred: true, autoPan: true)
                .ignoresSafeArea()

            VStack(spacing: 40) {
                ScreenHeader(title: constellation?.name ?? "", onBack: { appState.route = returnTo })

                GeometryReader { geometry in
                    let showsMap = geometry.size.width >= Self.mapHideThreshold

                    HStack(alignment: .top, spacing: 60) {
                        if showsMap {
                            ConstellationMapView(stars: constellation?.stars ?? [], onSelect: selectStar)
                                .frame(width: min(640, geometry.size.width * 0.45))
                                .frame(maxHeight: .infinity)
                                .glassEffect(.starrly, in: RoundedRectangle(cornerRadius: 24))
                                .popoverTip(ConstellationMapTip(), arrowEdge: .trailing)
                                .task { await watchMapTipDismissal() }
                        }

                        VStack(alignment: .leading, spacing: 40) {
                            AddStarField(onSubmit: addStar)
                                .frame(maxWidth: 720, alignment: .leading)

                            Rectangle()
                                .fill(Color.starrlyOffWhite)
                                .frame(maxWidth: 720, maxHeight: 1)

                            MemberStarsList(stars: constellation?.stars ?? [], onSelect: selectStar)
                                .frame(maxWidth: 720, maxHeight: .infinity, alignment: .top)
                                .popoverTip(MemberStarsTip(), arrowEdge: .top)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                    }
                }
            }
            .padding(40)
        }
    }

    private func addStar(name: String) {
        guard let constellation else { return }
        let color = StarColor.allCases.randomElement() ?? .lavender
        let existing = constellation.stars.map(\.localPosition)
        let position = ConstellationLayoutEngine.placeNewStar(among: existing)
        let star = Star(name: name, color: color, localPosition: position)
        star.constellation = constellation
        constellation.stars.append(star)
    }

    private func selectStar(_ star: Star) {
        appState.route = .star(star.id, returnTo: .constellation(constellationID, returnTo: returnTo))
    }

    private func watchMapTipDismissal() async {
        for await status in ConstellationMapTip().statusUpdates {
            if case .invalidated = status {
                await ConstellationMapTip.dismissedEvent.donate()
                return
            }
        }
    }
}
