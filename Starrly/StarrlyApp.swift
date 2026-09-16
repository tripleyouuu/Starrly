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
    @State private var settings: AppSettings
    @State private var soundPlayer: SoundPlayer

    init() {
        try? Tips.configure()
        let settings = AppSettings()
        _settings = State(initialValue: settings)
        _soundPlayer = State(initialValue: SoundPlayer(settings: settings))
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(settings)
                .environment(soundPlayer)
                .task {
                    soundPlayer.startAmbience()
                }
        }
        .modelContainer(for: [Constellation.self, Star.self, Session.self])
        .commands {
            SettingsCommands(settings: settings, soundPlayer: soundPlayer)
        }
    }
}
