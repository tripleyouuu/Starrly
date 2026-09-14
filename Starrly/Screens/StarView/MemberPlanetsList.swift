//
//  MemberPlanetsList.swift
//  Starrly
//
//  Created by Vitha Watson on 14/09/26.
//

import SwiftUI

struct MemberPlanetsList: View {
    let sessions: [Session]
    let onSelect: (Session) -> Void

    private var sortedSessions: [Session] {
        sessions.sorted { $0.createdAt > $1.createdAt }
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                ForEach(sortedSessions) { session in
                    Button {
                        onSelect(session)
                    } label: {
                        HStack {
                            Text(session.createdAt.formatted(date: .abbreviated, time: .omitted))
                                .foregroundStyle(Color.starrlyOffWhite)

                            Spacer()

                            Text(session.title)
                                .foregroundStyle(Color.starrlyOffWhite)

                            Image(systemName: "chevron.right")
                                .foregroundStyle(Color.starrlyOffWhite)
                        }
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
}
