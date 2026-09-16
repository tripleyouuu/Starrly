//
//  StarBillboardEntity.swift
//  Starrly
//
//  Created by Vitha Watson on 14/09/26.
//

import RealityKit
import AppKit
import SwiftUI

enum StarBillboardEntity {
    static func make(star: Star, sizeScale: Double = 1.0) async -> Entity {
        let root = Entity()
        root.name = "star:\(star.id.uuidString)"
        root.components.set(BillboardComponent())

        let size = Float(20 * sizeScale)
        var rotationPivots: [Entity] = []
        var scalingLayers: [(entity: ModelEntity, baseScale: Float, targetMultiplier: Float)] = []

        // A dedicated soft halo behind the star, rather than reusing the star's own body — this is
        // the actual stand-in for the 2D drop-shadow: growing/shrinking a separate soft-edged glow
        // reads as "blur radius changing" the way scaling the star itself never could, and it's not
        // fighting for attention against a layer that's already pulsing/rotating for its own reasons.
        // if let glow = makeGlowEntity(size: size * 2.5, tint: NSColor(Color.starrlyOffWhite)) {
        //     root.addChild(glow)
        //     DispatchQueue.main.async {
        //         animateGlow(glow, intensity: StarMotionSpec.twinkleIntensity(for: star.type))
        //     }
        // }

        for (index, layerName) in StarAsset.layers(for: star.type).enumerated() {
            let mesh = MeshResource.generatePlane(width: size, height: size)
            var material = UnlitMaterial()
            if let texture = TextureAssetLoader.loadTexture(named: layerName) {
                let tint = NSColor(star.color.color).withAlphaComponent(0.999)
                material.color = .init(tint: tint, texture: .init(texture))
                material.blending = .transparent(opacity: .init(scale: 1.0, texture: .init(texture)))
            } else {
                print("\(layerName) texture failed to load")
            }

            let baseScale = Float(StarAsset.relativeScale(for: layerName))
            let layerEntity = ModelEntity(mesh: mesh, materials: [material])
            layerEntity.scale = SIMD3<Float>(repeating: baseScale)
            layerEntity.position.z = Float(index) * 0.01

            if StarMotionSpec.layerPulses(type: star.type, layer: layerName) {
                scalingLayers.append((layerEntity, baseScale, Float(StarMotionSpec.pulseGrowScale)))
            } else if StarMotionSpec.layerShrinks(type: star.type, layer: layerName) {
                scalingLayers.append((layerEntity, baseScale, Float(StarMotionSpec.haloShrinkScale)))
            }

            // Rotation lives on its own parent entity (rather than mutating layerEntity's own
            // transform further) so it never fights with that layer's own pulse/shrink animation
            // over the same entity's transform — each nesting level owns exactly one animation.
            let rotationPivot = Entity()
            rotationPivot.addChild(layerEntity)
            if StarMotionSpec.layerRotates(type: star.type, layer: layerName) {
                rotationPivots.append(rotationPivot)
            }

            root.addChild(rotationPivot)
        }

        // Deferred to the next run-loop turn: the caller adds `root` to the scene immediately
        // after this function returns, and animations played before an entity is scene-attached
        // don't reliably start.
        DispatchQueue.main.async {
            // All of a neutron star's beam/halo motion — and the giant/supernova rotation — is
            // started here in the same synchronous pass, so every animation's clock originates
            // from the exact same instant and the 4s/4s halves stay phase-locked to each other.
            for pivot in rotationPivots {
                animateRotation(pivot, duration: StarMotionSpec.rotationDuration)
            }
            for layer in scalingLayers {
                animateScale(layer.entity, baseScale: layer.baseScale, targetMultiplier: layer.targetMultiplier, duration: StarMotionSpec.pulseDuration)
            }
        }

        return root
    }

    // private static func makeGlowEntity(size: Float, tint: NSColor) -> ModelEntity? {
    //     guard let texture = TextureAssetLoader.radialGlowTexture else { return nil }
    //     let mesh = MeshResource.generatePlane(width: size, height: size)
    //     var material = UnlitMaterial()
    //     material.color = .init(tint: tint, texture: .init(texture))
    //     material.blending = .transparent(opacity: .init(scale: 1.0, texture: .init(texture)))
    //     // Doesn't write depth, so it can never occlude the star it surrounds regardless of exact
    //     // 3D position — depth differences of a few hundredths of a unit at the ~490-unit range
    //     // these all render at are too small for the depth buffer to resolve reliably either way.
    //     material.writesDepth = false
    //     return ModelEntity(mesh: mesh, materials: [material])
    // }

    private static func animateScale(_ entity: Entity, baseScale: Float, targetMultiplier: Float, duration: TimeInterval) {
        func transform(scaleFactor: Float) -> Transform {
            Transform(scale: SIMD3<Float>(repeating: baseScale * scaleFactor), rotation: entity.orientation, translation: entity.position)
        }
        let grow = FromToByAnimation<Transform>(
            from: transform(scaleFactor: 1),
            to: transform(scaleFactor: targetMultiplier),
            duration: duration,
            timing: .easeInOut,
            bindTarget: .transform
        )
        let shrinkBack = FromToByAnimation<Transform>(
            from: transform(scaleFactor: targetMultiplier),
            to: transform(scaleFactor: 1),
            duration: duration,
            timing: .easeInOut,
            bindTarget: .transform
        )
        playLoopingSequence([grow, shrinkBack], on: entity, label: "scale")
    }

    private static func animateRotation(_ entity: Entity, duration: TimeInterval) {
        let halfDuration = duration / 2
        func transform(angle: Float) -> Transform {
            Transform(scale: entity.scale, rotation: simd_quatf(angle: angle, axis: [0, 0, 1]), translation: entity.position)
        }
        let firstHalf = FromToByAnimation<Transform>(
            from: transform(angle: 0),
            to: transform(angle: .pi),
            duration: halfDuration,
            timing: .linear,
            bindTarget: .transform
        )
        let secondHalf = FromToByAnimation<Transform>(
            from: transform(angle: .pi),
            to: transform(angle: .pi * 2),
            duration: halfDuration,
            timing: .linear,
            bindTarget: .transform
        )
        playLoopingSequence([firstHalf, secondHalf], on: entity, label: "rotation")
    }

    // The actual drop-shadow stand-in: grows and shrinks the standalone glow sprite behind the
    // star, on its own randomized speed/delay, exactly like a blur radius animating from 0 up to
    // a peak and back — rather than resizing or dimming the star itself.
    // private static func animateGlow(_ entity: Entity, intensity: CGFloat) {
    //     let delay = Double.random(in: StarMotionSpec.twinkleDelayRange)
    //     // Half speed relative to the 2D shadow's own timing (shared range doubled, just for this).
    //     let duration = Double.random(in: StarMotionSpec.twinkleDurationRange) * 2
    //     let peak = Float(0.05 + intensity * 2.5)
    //     Task { @MainActor in
    //         try? await Task.sleep(for: .seconds(delay))
    //         guard !Task.isCancelled else { return }
    //         func transform(scaleFactor: Float) -> Transform {
    //             Transform(scale: SIMD3<Float>(repeating: scaleFactor), rotation: entity.orientation, translation: entity.position)
    //         }
    //         let grow = FromToByAnimation<Transform>(
    //             from: transform(scaleFactor: 0.001),
    //             to: transform(scaleFactor: peak),
    //             duration: duration,
    //             timing: .easeInOut,
    //             bindTarget: .transform
    //         )
    //         let shrinkBack = FromToByAnimation<Transform>(
    //             from: transform(scaleFactor: peak),
    //             to: transform(scaleFactor: 0.001),
    //             duration: duration,
    //             timing: .easeInOut,
    //             bindTarget: .transform
    //         )
    //         playLoopingSequence([grow, shrinkBack], on: entity, label: "glow")
    //     }
    // }

    private static func playLoopingSequence(_ definitions: [FromToByAnimation<Transform>], on entity: Entity, label: String) {
        do {
            let resources = try definitions.map { try AnimationResource.generate(with: $0) }
            let sequence = try AnimationResource.sequence(with: resources)
            entity.playAnimation(sequence.repeat(duration: .infinity))
        } catch {
            print("StarBillboardEntity: \(label) animation failed: \(error)")
        }
    }
}
