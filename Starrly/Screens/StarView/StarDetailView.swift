//
//  StarDetailView.swift
//  Starrly
//
//  Created by Vitha Watson on 14/09/26.
//

import SwiftUI
import SwiftData
import TipKit

struct StarDetailView: View {
    let starID: UUID
    let returnTo: Route

    @Environment(AppState.self) private var appState
    @Environment(\.modelContext) private var modelContext
    @Environment(SoundPlayer.self) private var soundPlayer
    @Query private var stars: [Star]
    @Query private var allConstellations: [Constellation]

    private static let mapHideThreshold: CGFloat = 900

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

            VStack(spacing: 40) {
                ScreenHeader(title: star?.name ?? "", onBack: { appState.route = returnTo })

                if let star {
                    GeometryReader { geometry in
                        let showsMap = geometry.size.width >= Self.mapHideThreshold

                        HStack(alignment: .top, spacing: 60) {
                            if showsMap {
                                OrbitMapView(star: star, onSelect: selectSession)
                                    .frame(width: min(640, geometry.size.width * 0.45))
                                    .frame(maxHeight: .infinity)
                                    .glassEffect(.starrly, in: RoundedRectangle(cornerRadius: 24))
                                    .popoverTip(StarMapTip(), arrowEdge: .trailing)
                                    .task { await watchMapTipDismissal() }
                            }

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
                                    .popoverTip(RecordSessionTip(), arrowEdge: .top)

                                    Spacer()
                                }
                                .frame(maxWidth: 720)

                                Rectangle()
                                    .fill(Color.starrlyOffWhite)
                                    .frame(maxWidth: 720, maxHeight: 1)

                                MemberPlanetsList(sessions: star.sessions, onSelect: selectSession)
                                    .frame(maxWidth: 720, maxHeight: .infinity, alignment: .top)
                            }
                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                        }
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
            if let constellation = star.constellation {
                ConstellationLayoutEngine.resolveIntersections(for: constellation)
            }
        }
        modelContext.insert(session)
        soundPlayer.playRandomReveal()
        appState.route = .session(session.id, starReturnTo: .star(starID, returnTo: returnTo))
    }

    private func selectSession(_ session: Session) {
        appState.route = .session(session.id, starReturnTo: .star(starID, returnTo: returnTo))
    }

    private func watchMapTipDismissal() async {
        for await status in StarMapTip().statusUpdates {
            if case .invalidated = status {
                await StarMapTip.dismissedEvent.donate()
                return
            }
        }
    }
}
