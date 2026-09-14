//
//  ExploreLayoutEngine.swift
//  Starrly
//
//  Created by Vitha Watson on 14/09/26.
//

import Foundation

enum ExploreLayoutEngine {
    static let minSeparation: Double = 25
    static let pitchRange: ClosedRange<Double> = 10...70

    static func placeNewConstellation(among existing: [SkyPosition]) -> SkyPosition {
        for _ in 0..<300 {
            let candidate = SkyPosition(
                yaw: Double.random(in: 0..<360),
                pitch: Double.random(in: pitchRange)
            )
            if isFarEnough(candidate, from: existing) {
                return candidate
            }
        }
        return SkyPosition(yaw: Double.random(in: 0..<360), pitch: Double.random(in: pitchRange))
    }

    private static func isFarEnough(_ candidate: SkyPosition, from existing: [SkyPosition]) -> Bool {
        existing.allSatisfy { angularDistance($0, candidate) >= minSeparation }
    }

    private static func angularDistance(_ a: SkyPosition, _ b: SkyPosition) -> Double {
        let yawDelta = abs(a.yaw - b.yaw).truncatingRemainder(dividingBy: 360)
        let wrappedYawDelta = min(yawDelta, 360 - yawDelta)
        let pitchDelta = abs(a.pitch - b.pitch)
        return sqrt(wrappedYawDelta * wrappedYawDelta + pitchDelta * pitchDelta)
    }
}
