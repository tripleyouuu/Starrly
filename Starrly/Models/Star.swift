//
//  Star.swift
//  Starrly
//
//  Created by Vitha Watson on 14/09/26.
//

import Foundation
import CoreGraphics
import SwiftData

@Model
final class Star {
    var id: UUID
    var name: String
    var color: StarColor
    var createdAt: Date
    var firstSessionAt: Date?
    var localPosition: CGPoint
    var explorePosition: CGPoint

    var constellation: Constellation?

    @Relationship(deleteRule: .cascade, inverse: \Session.star)
    var sessions: [Session] = []

    init(name: String, color: StarColor, localPosition: CGPoint, explorePosition: CGPoint) {
        self.id = UUID()
        self.name = name
        self.color = color
        self.createdAt = .now
        self.firstSessionAt = nil
        self.localPosition = localPosition
        self.explorePosition = explorePosition
    }

    var type: StarType {
        StarType.forSessionCount(sessions.count)
    }
}
