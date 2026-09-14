//
//  ConstellationPathBuilder.swift
//  Starrly
//
//  Created by Vitha Watson on 14/09/26.
//

import Foundation

enum ConstellationPathBuilder {
    static func orderedConnectedStars(from stars: [Star]) -> [Star] {
        stars
            .filter { $0.firstSessionAt != nil }
            .sorted { $0.firstSessionAt! < $1.firstSessionAt! }
    }
}
