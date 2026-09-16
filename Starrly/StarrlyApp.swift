//
//  StarrlyApp.swift
//  Starrly
//
//  Created by Vitha Watson on 14/09/26.
//

import SwiftUI
import SwiftData
import TipKit

@main
struct StarrlyApp: App {
    init() {
        try? Tips.configure()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: [Constellation.self, Star.self, Session.self])
    }
}
