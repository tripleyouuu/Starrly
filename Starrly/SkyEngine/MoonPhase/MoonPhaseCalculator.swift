//
//  MoonPhaseCalculator.swift
//  Starrly
//
//  Created by Vitha Watson on 14/09/26.
//

import Foundation

enum MoonPhaseCalculator {
    static func currentPhase(for date: Date = .now) -> MoonPhase {
        let knownNewMoon = Date(timeIntervalSince1970: 947182440)
        let synodicMonth: TimeInterval = 29.530588853 * 86400
        let elapsed = date.timeIntervalSince(knownNewMoon)
        let cycles = elapsed / synodicMonth
        let fraction = cycles - floor(cycles)
        let index = Int((fraction * 8).rounded()) % 8
        return MoonPhase.allCases[index]
    }
}
