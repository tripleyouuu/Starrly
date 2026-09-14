//
//  MemberStarsList.swift
//  Starrly
//
//  Created by Vitha Watson on 14/09/26.
//

import SwiftUI

struct MemberStarsList: View {
    let stars: [Star]
    let onSelect: (Star) -> Void

    private var sortedStars: [Star] {
        stars.sorted { $0.createdAt > $1.createdAt }
    }

    private let columns = [GridItem(.flexible()), GridItem(.flexible())]

    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 20) {
                ForEach(sortedStars) { star in
                    Button {
                        onSelect(star)
                    } label: {
                        HStack(spacing: 12) {
                            StarView(type: star.type, color: star.color)
                                .frame(width: 28, height: 28)

                            VStack(alignment: .leading, spacing: 2) {
                                Text(star.name)
                                    .foregroundStyle(Color.starrlyOffWhite)
                                Text(star.type.label)
                                    .foregroundStyle(Color.starrlyOffWhite.opacity(0.7))
                            }

                            Spacer()

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
