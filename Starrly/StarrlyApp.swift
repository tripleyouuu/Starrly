//
//  StarrlyApp.swift
//  Starrly
//
//  Created by Vitha Watson on 14/09/26.
//

import SwiftUI
import SwiftData
import TipKit
import AppKit

final class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        DispatchQueue.main.async {
            guard let window = NSApplication.shared.windows.first,
                  !window.styleMask.contains(.fullScreen) else { return }
            window.toggleFullScreen(nil)
        }
    }
}

@main
struct StarrlyApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
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
