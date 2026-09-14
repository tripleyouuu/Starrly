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
        VStack(spacing: 40) {
            ZStack {
                HStack {
                    BackButton(action: { appState.route = returnTo })
                    Spacer()
                }

                Text(constellation?.name ?? "")
                    .font(.title2)
                    .foregroundStyle(Color.starrlyOffWhite)
            }

            HStack(alignment: .top, spacing: 40) {
                ConstellationMapView(stars: constellation?.stars ?? [])
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .glassEffect(.starrly, in: .rect(cornerRadius: 20))

                VStack(alignment: .leading, spacing: 20) {
                    AddStarField(onSubmit: addStar)
                    MemberStarsList(stars: constellation?.stars ?? [], onSelect: selectStar)
                }
                .frame(maxWidth: .infinity)
            }
        }
        .padding(40)
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
