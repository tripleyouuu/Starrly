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
    var shape: PlanetShape
    var createdAt: Date

    var star: Star?

    init() {
        self.id = UUID()
        self.title = "New Session"
        self.body = ""
        self.mediaPaths = []
        self.shape = PlanetShape.allCases.randomElement()!
        self.createdAt = .now
    }
}
