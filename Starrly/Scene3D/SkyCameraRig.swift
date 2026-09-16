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
    private(set) var pitch: Double = SkyCameraRig.defaultPitch
    private(set) var fieldOfView: Double = SkyCameraRig.defaultFieldOfView

    private var minPitch: Double = SkyCameraRig.defaultMinPitch
    private var maxPitch: Double = SkyCameraRig.defaultMaxPitch

    static let defaultMinPitch: Double = 0
    static let defaultMaxPitch: Double = 55
    static let defaultPitch: Double = 35
    static let defaultFieldOfView: Double = 60
    static let zoomedFieldOfView: Double = 35

    var isAnimating: Bool { animationTarget != nil }

    private var animationStart: (yaw: Double, pitch: Double, fieldOfView: Double)?
    private var animationTarget: (yaw: Double, pitch: Double, fieldOfView: Double)?
    private var animationStartedAt: Date?
    private let animationDuration: TimeInterval = 0.4

    init() {
        cameraEntity.components.set(PerspectiveCameraComponent(near: 0.1, far: 2000, fieldOfViewInDegrees: Float(fieldOfView)))
        rigEntity.addChild(cameraEntity)
        updateOrientation()
    }

    func setPitchBounds(_ range: ClosedRange<Double>) {
        minPitch = range.lowerBound
        maxPitch = range.upperBound
        pitch = clampPitch(pitch)
        updateOrientation()
    }

    func setInitial(yaw: Double, pitch: Double) {
        self.yaw = yaw
        self.pitch = clampPitch(pitch)
        updateOrientation()
    }

    func setYaw(_ newYaw: Double) {
        yaw = newYaw
        updateOrientation()
    }

    func pan(deltaYaw: Double, deltaPitch: Double) {
        cancelAnimation()
        yaw += deltaYaw
        pitch = clampPitch(pitch + deltaPitch)
        updateOrientation()
    }

    func autoPanStep(deltaYaw: Double) {
        yaw += deltaYaw
        updateOrientation()
    }

    func setFieldOfView(_ degrees: Double) {
        fieldOfView = degrees
        applyFieldOfView()
    }

    func startAnimating(toYaw targetYaw: Double, pitch targetPitch: Double, fieldOfView targetFieldOfView: Double? = nil) {
        let clampedTargetPitch = clampPitch(targetPitch)
        let rawDelta = (targetYaw - yaw).truncatingRemainder(dividingBy: 360)
        let shortestDelta = rawDelta > 180 ? rawDelta - 360 : (rawDelta < -180 ? rawDelta + 360 : rawDelta)

        animationStart = (yaw, pitch, fieldOfView)
        animationTarget = (yaw + shortestDelta, clampedTargetPitch, targetFieldOfView ?? fieldOfView)
        animationStartedAt = Date()
    }

    func cancelAnimation() {
        animationStart = nil
        animationTarget = nil
        animationStartedAt = nil
    }

    func tick(at now: Date) {
        guard let start = animationStart, let target = animationTarget, let startedAt = animationStartedAt else { return }
        let elapsed = now.timeIntervalSince(startedAt)
        let t = min(1, max(0, elapsed / animationDuration))
        let eased = 1 - pow(1 - t, 3)

        yaw = start.yaw + (target.yaw - start.yaw) * eased
        pitch = start.pitch + (target.pitch - start.pitch) * eased
        fieldOfView = start.fieldOfView + (target.fieldOfView - start.fieldOfView) * eased
        updateOrientation()
        applyFieldOfView()

        if t >= 1 {
            cancelAnimation()
        }
    }

    private func clampPitch(_ value: Double) -> Double {
        min(max(value, minPitch), maxPitch)
    }

    private func updateOrientation() {
        let yawRotation = simd_quatf(angle: Float(yaw * .pi / 180), axis: [0, 1, 0])
        let pitchRotation = simd_quatf(angle: Float(pitch * .pi / 180), axis: [1, 0, 0])
        rigEntity.orientation = yawRotation * pitchRotation
    }

    private func applyFieldOfView() {
        cameraEntity.components.set(PerspectiveCameraComponent(near: 0.1, far: 2000, fieldOfViewInDegrees: Float(fieldOfView)))
    }
}
