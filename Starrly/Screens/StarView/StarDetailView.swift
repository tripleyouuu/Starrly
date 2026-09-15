//
//  StarDetailView.swift
//  Starrly
//
//  Created by Vitha Watson on 14/09/26.
//

import SwiftUI
import SwiftData

struct StarDetailView: View {
    let starID: UUID
    let returnTo: Route

    @Environment(AppState.self) private var appState
    @Environment(\.modelContext) private var modelContext
    @Query private var stars: [Star]
    @Query private var allConstellations: [Constellation]

    init(starID: UUID, returnTo: Route) {
        self.starID = starID
        self.returnTo = returnTo
        let id = starID
        _stars = Query(filter: #Predicate<Star> { $0.id == id })
    }

    private var star: Star? {
        stars.first
    }

    var body: some View {
        ZStack {
            AmbientSkyView(constellations: allConstellations, isBlurred: true)
                .ignoresSafeArea()

            VStack(spacing: 40) {
                ZStack {
                    HStack {
                        BackButton(action: { appState.route = returnTo })
                        Spacer()
                    }

                    Text(star?.name ?? "")
                        .font(.title2)
                        .foregroundStyle(Color.starrlyOffWhite)
                }

                if let star {
                    HStack(alignment: .top, spacing: 40) {
                        OrbitMapView(star: star, onSelect: selectSession)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .glassEffect(.starrly, in: .rect(cornerRadius: 20))

                        VStack(alignment: .leading, spacing: 20) {
                            HStack {
                                Text("Add Planet…")
                                    .foregroundStyle(Color.starrlyOffWhite)

                                Spacer()

                                Button("Record Session", action: recordSession)
                                    .buttonStyle(.plain)
                                    .padding(.horizontal, 20)
                                    .padding(.vertical, 10)
                                    .foregroundStyle(Color.starrlyOffWhite)
                                    .glassEffect(.starrly.interactive(), in: .capsule)
                            }

                            MemberPlanetsList(sessions: star.sessions, onSelect: selectSession)
                        }
                        .frame(maxWidth: .infinity)
                    }
                }
            }
            .padding(40)
        }
    }

    private func recordSession() {
        guard let star else { return }
        let session = Session()
        session.star = star
        star.sessions.append(session)
        if star.firstSessionAt == nil {
            star.firstSessionAt = session.createdAt
        }
        modelContext.insert(session)
        appState.route = .session(session.id, starReturnTo: .star(starID, returnTo: returnTo))
    }

    private func selectSession(_ session: Session) {
        appState.route = .session(session.id, starReturnTo: .star(starID, returnTo: returnTo))
    }
}
