//
//  Session.swift
//  Starrly
//
//  Created by Vitha Watson on 14/09/26.
//

import Foundation
import SwiftData

@Model
final class Session {
    var id: UUID
    var title: String
    var body: String
    var mediaPaths: [String]
    var shapeValue: Int
    var createdAt: Date

    var star: Star?

    init() {
        self.id = UUID()
        self.title = "New Session"
        self.body = ""
        self.mediaPaths = []
        self.shapeValue = PlanetShape.allCases.randomElement()!.rawValue
        self.createdAt = .now
    }

    var shape: PlanetShape {
        PlanetShape(rawValue: shapeValue) ?? .one
    }
}
