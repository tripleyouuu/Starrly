//
//  SkyProjection.swift
//  Starrly
//
//  Created by Vitha Watson on 14/09/26.
//


import Foundation
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

    static func starWorldPosition(star: Star, constellationCentroid: SkyPosition, radius: Double, spreadScale: Double = 0.05) -> SIMD3<Float> {
        let pitch = constellationCentroid.pitch + star.localPosition.y * spreadScale
        let position = SkyPosition(
            yaw: constellationCentroid.yaw + star.localPosition.x * spreadScale,
            pitch: min(max(pitch, ExploreLayoutEngine.minPitch), ExploreLayoutEngine.maxPitch)
        )
        return worldPosition(for: position, radius: radius)
    }
}
