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

    private let columns = [GridItem(.fixed(350), spacing: 60), GridItem(.fixed(350))]

    var body: some View {
        if sortedSessions.isEmpty {
            Text("Planets represent learning sessions corresponding to each skill. Record one to keep track of your progress — type out a journal entry, or upload media to look back on!  As the star gains more planets, it grows through the life cycle of a star and gets brighter. Happy learning!")
                .font(.system(size: 19, weight: .regular))
                .foregroundStyle(Color.starrlyOffWhite)
                .multilineTextAlignment(.center)
                .frame(width: 560)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                .offset(y: -40)
        } else {
            VStack(spacing: 40) {
                Text("Member Planets")
                    .font(.system(size: 27, weight: .semibold))
                    .foregroundStyle(Color.starrlyOffWhite)
                    .frame(maxWidth: .infinity, alignment: .center)

                ScrollView {
                    LazyVGrid(columns: columns, spacing: 48) {
                        ForEach(sortedSessions) { session in
                            Button {
                                onSelect(session)
                            } label: {
                                HStack(spacing: 108) {
                                    HStack(spacing: 16) {
                                        Image(session.shape.assetName)
                                            .resizable()
                                            .aspectRatio(contentMode: .fit)
                                            .frame(width: 64, height: 64)

                                        Text(session.displayTitle)
                                            .font(.system(size: 21, weight: .semibold))
                                            .foregroundStyle(Color.starrlyOffWhite)
                                            .lineLimit(1)
                                            .frame(width: 150, alignment: .leading)
                                    }

                                    Image(systemName: "chevron.right")
                                        .font(.system(size: 21, weight: .semibold))
                                        .foregroundStyle(Color.starrlyOffWhite)
                                }
                                .frame(height: 100)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.trailing, 16)
                    .frame(maxWidth: .infinity, alignment: .center)
                }
                .frame(maxHeight: .infinity)
            }
        }
    }
}
