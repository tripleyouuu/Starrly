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

    private let columns = [GridItem(.fixed(350), spacing: 60), GridItem(.fixed(350))]

    var body: some View {
        VStack(spacing: 40) {
            Text("Member Stars")
                .font(.system(size: 27, weight: .semibold))
                .foregroundStyle(Color.starrlyOffWhite)
                .frame(maxWidth: .infinity, alignment: .center)

            ScrollView {
                LazyVGrid(columns: columns, spacing: 48) {
                    ForEach(sortedStars) { star in
                        Button {
                            onSelect(star)
                        } label: {
                            HStack(spacing: 108) {
                                HStack(spacing: 16) {
                                    StarView(type: star.type, color: star.color)
                                        .frame(width: 44, height: 44)

                                    VStack(alignment: .leading, spacing: 6) {
                                        Text(star.name)
                                            .font(.system(size: 21, weight: .semibold))
                                            .foregroundStyle(Color.starrlyOffWhite)
                                            .lineLimit(1)
                                        Text(star.type.label)
                                            .font(.system(size: 19))
                                            .foregroundStyle(Color.starrlyOffWhite.opacity(0.7))
                                            .lineLimit(1)
                                    }
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
                .frame(maxWidth: .infinity, alignment: .center)
            }
            .frame(maxHeight: .infinity)
        }
    }
}
