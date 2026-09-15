//
//  ConstellationView.swift
//  Starrly
//
//  Created by Vitha Watson on 14/09/26.
//

import SwiftUI
import SwiftData

struct ConstellationView: View {
    let constellationID: UUID
    let returnTo: Route

    @Environment(AppState.self) private var appState
    @Query private var constellations: [Constellation]
    @Query private var allConstellations: [Constellation]

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

            ZStack {
                ZStack {
                    HStack {
                        BackButton(action: { appState.route = returnTo })
                        Spacer()
                    }

                    Text(constellation?.name ?? "")
                        .font(.system(size: 33, weight: .bold))
                        .foregroundStyle(Color.starrlyOffWhite)
                }
                .frame(maxHeight: .infinity, alignment: .top)

                HStack(alignment: .top, spacing: 40) {
                    ConstellationMapView(stars: constellation?.stars ?? [])
                        .frame(maxWidth: 640, maxHeight: 720)
                        .glassEffect(.clear, in: RoundedRectangle(cornerRadius: 24))

                    VStack(alignment: .leading, spacing: 40) {
                        AddStarField(onSubmit: addStar)

                        Rectangle()
                            .fill(Color.starrlyOffWhite)
                            .frame(maxWidth: 780, maxHeight: 1)

                        MemberStarsList(stars: constellation?.stars ?? [], onSelect: selectStar)
                            .frame(maxWidth: 780, maxHeight: .infinity, alignment: .top)
                    }
                    .frame(maxWidth: .infinity, maxHeight: 720)
                }
                .padding(.top, 40)
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
}
