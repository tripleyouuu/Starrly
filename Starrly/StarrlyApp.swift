//
//  StarrlyApp.swift
//  Starrly
//
//  Created by Vitha Watson on 14/09/26.
//

import SwiftUI
import SwiftData

@main
struct StarrlyApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: [Constellation.self, Star.self, Session.self])
    }
}
