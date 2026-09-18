//
//  SettingsCommands.swift
//  Starrly
//
//  Created by Vitha Watson on 16/09/26.
//

import SwiftUI

struct SettingsCommands: Commands {
    @Bindable var settings: AppSettings
    let soundPlayer: SoundPlayer

    var body: some Commands {
        CommandMenu("Settings") {
            Toggle("Sound Effects", isOn: $settings.isSoundEnabled)
                .onChange(of: settings.isSoundEnabled) {
                    soundPlayer.applySoundEnabled()
                }
            Toggle("Background Motion", isOn: $settings.isMotionEnabled)
        }
    }
}
