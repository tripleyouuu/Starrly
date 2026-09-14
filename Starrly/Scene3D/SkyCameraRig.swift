//
//  SkyCameraRig.swift
//  Starrly
//
//  Created by Vitha Watson on 14/09/26.
//

import RealityKit
import SwiftUI

@Observable
final class SkyCameraRig {
    let rigEntity = Entity()
    let cameraEntity = PerspectiveCamera()

    private(set) var yaw: Double = 0
    private(set) var pitch: Double = 30

    static let minPitch: Double = 0
    static let maxPitch: Double = 85

    init() {
        rigEntity.addChild(cameraEntity)
        updateOrientation()
    }

    func setInitial(yaw: Double, pitch: Double) {
        self.yaw = yaw
        self.pitch = min(max(pitch, Self.minPitch), Self.maxPitch)
        updateOrientation()
    }

    func pan(deltaYaw: Double, deltaPitch: Double) {
        yaw += deltaYaw
        pitch = min(max(pitch + deltaPitch, Self.minPitch), Self.maxPitch)
        updateOrientation()
    }

    private func updateOrientation() {
        let yawRotation = simd_quatf(angle: Float(yaw * .pi / 180), axis: [0, 1, 0])
        let pitchRotation = simd_quatf(angle: Float(-pitch * .pi / 180), axis: [1, 0, 0])
        rigEntity.orientation = yawRotation * pitchRotation
    }
}
