//
//  SkyProjection.swift
//  Starrly
//
//  Created by Vitha Watson on 14/09/26.
//


import Foundation
import CoreGraphics
import simd

enum SkyProjection {
    static func worldPosition(for position: SkyPosition, radius: Double) -> SIMD3<Float> {
        let yawRadians = position.yaw * .pi / 180
        let pitchRadians = position.pitch * .pi / 180
        let x = radius * cos(pitchRadians) * sin(yawRadians)
        let y = radius * sin(pitchRadians)
        let z = -radius * cos(pitchRadians) * cos(yawRadians)
        return SIMD3<Float>(Float(x), Float(y), Float(z))
    }

    static func starWorldPosition(
        star: Star,
        constellationCentroid: SkyPosition,
        localOrigin: CGPoint = .zero,
        radius: Double,
        spreadScale: Double = 0.05,
        pitchBand: ClosedRange<Double> = ExploreLayoutEngine.minPitch...ExploreLayoutEngine.maxPitch
    ) -> SIMD3<Float> {
        let localX = star.localPosition.x - localOrigin.x
        let localY = star.localPosition.y - localOrigin.y
        let pitch = constellationCentroid.pitch + localY * spreadScale
        let position = SkyPosition(
            yaw: constellationCentroid.yaw + localX * spreadScale,
            pitch: min(max(pitch, pitchBand.lowerBound), pitchBand.upperBound)
        )
        return worldPosition(for: position, radius: radius)
    }
}
