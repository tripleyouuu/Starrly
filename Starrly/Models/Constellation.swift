//
//  Constellation.swift
//  Starrly
//
//  Created by Vitha Watson on 14/09/26.
//

import Foundation
import SwiftData

@Model
final class Constellation {
    var id: UUID
    var name: String
    var createdAt: Date
    var explorePosition: SkyPosition?

    @Relationship(deleteRule: .cascade, inverse: \Star.constellation)
    var stars: [Star] = []

    init(name: String) {
        self.id = UUID()
        self.name = name
        self.createdAt = .now
    }
}
