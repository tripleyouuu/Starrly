//
//  AppSettings.swift
//  Starrly
//
//  Created by Vitha Watson on 16/09/26.
//

import Foundation
import Observation

@Observable
final class AppSettings {
    var isSoundEnabled: Bool {
        didSet { UserDefaults.standard.set(isSoundEnabled, forKey: Keys.sound) }
    }

    var isMotionEnabled: Bool {
        didSet { UserDefaults.standard.set(isMotionEnabled, forKey: Keys.motion) }
    }

    private enum Keys {
        static let sound = "Starrly.isSoundEnabled"
        static let motion = "Starrly.isMotionEnabled"
    }

    init() {
        let defaults = UserDefaults.standard
        isSoundEnabled = (defaults.object(forKey: Keys.sound) as? Bool) ?? true
        isMotionEnabled = (defaults.object(forKey: Keys.motion) as? Bool) ?? true
    }
}
