//
//  SessionView.swift
//  Starrly
//
//  Created by Vitha Watson on 14/09/26.
//

import SwiftUI
import SwiftData

struct SessionView: View {
    let sessionID: UUID
    let starReturnTo: Route

    @Environment(AppState.self) private var appState
    @Query private var sessions: [Session]

    init(sessionID: UUID, starReturnTo: Route) {
        self.sessionID = sessionID
        self.starReturnTo = starReturnTo
        let id = sessionID
        _sessions = Query(filter: #Predicate<Session> { $0.id == id })
    }

    var body: some View {
        if let session = sessions.first {
            SessionContentView(session: session) {
                appState.route = starReturnTo
            }
        }
    }
}
