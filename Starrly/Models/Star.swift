import Foundation
import CoreGraphics
import SwiftData

@Model
final class Star {
    var id: UUID
    var name: String
    var colorValue: Int
    var createdAt: Date
    var firstSessionAt: Date?
    var localPositionX: Double
    var localPositionY: Double

    var constellation: Constellation?

    @Relationship(deleteRule: .cascade, inverse: \Session.star)
    var sessions: [Session] = []

    init(name: String, color: StarColor, localPosition: CGPoint) {
        self.id = UUID()
        self.name = name
        self.colorValue = color.rawValue
        self.createdAt = .now
        self.firstSessionAt = nil
        self.localPositionX = localPosition.x
        self.localPositionY = localPosition.y
    }

    var color: StarColor {
        StarColor(rawValue: colorValue) ?? .lavender
    }

    var localPosition: CGPoint {
        get { CGPoint(x: localPositionX, y: localPositionY) }
        set {
            localPositionX = newValue.x
            localPositionY = newValue.y
        }
    }

    var type: StarType {
        StarType.forSessionCount(sessions.count)
    }
}
