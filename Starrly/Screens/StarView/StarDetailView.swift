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
            AmbientSkyView(constellations: allConstellations, isBlurred: true, autoPan: true)
                .ignoresSafeArea()

            ZStack {
                ZStack {
                    HStack {
                        BackButton(action: { appState.route = returnTo })
                        Spacer()
                    }

                    Text(star?.name ?? "")
                        .font(.system(size: 33, weight: .bold))
                        .foregroundStyle(Color.starrlyOffWhite)
                }
                .frame(maxHeight: .infinity, alignment: .top)

                if let star {
                    HStack(alignment: .top, spacing: 40) {
                        OrbitMapView(star: star, onSelect: selectSession)
                            .frame(maxWidth: 640, maxHeight: 720)
                            .glassEffect(.clear, in: RoundedRectangle(cornerRadius: 24))

                        VStack(alignment: .leading, spacing: 40) {
                            HStack {
                                Text("Add Planet…")
                                    .font(.system(size: 27, weight: .semibold))
                                    .foregroundStyle(Color.starrlyOffWhite)

                                Spacer()

                                Button {
                                    recordSession()
                                } label: {
                                    Text("Record Session")
                                        .font(.system(size: 27, weight: .semibold))
                                        .frame(width: 280, height: 60)
                                        .contentShape(Rectangle())
                                }
                                .buttonStyle(.plain)
                                .foregroundStyle(Color.starrlyOffWhite)
                                .glassEffect(.starrly.interactive(), in: RoundedRectangle(cornerRadius: 24))

                                Spacer()
                            }

                            Rectangle()
                                .fill(Color.starrlyOffWhite)
                                .frame(maxWidth: 780, maxHeight: 1)

                            MemberPlanetsList(sessions: star.sessions, onSelect: selectSession)
                                .frame(maxWidth: 780, maxHeight: .infinity, alignment: .top)
                        }
                        .frame(maxWidth: .infinity, maxHeight: 720)
                    }
                    .padding(.top, 40)
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
            if let constellation = star.constellation {
                ConstellationLayoutEngine.resolveIntersections(for: constellation)
            }
        }
        modelContext.insert(session)
        appState.route = .session(session.id, starReturnTo: .star(starID, returnTo: returnTo))
    }

    private func selectSession(_ session: Session) {
        appState.route = .session(session.id, starReturnTo: .star(starID, returnTo: returnTo))
    }
}
