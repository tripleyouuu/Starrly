//
//  ConstellationLineEntity.swift
//  Starrly
//
//  Created by Vitha Watson on 15/09/26.
//


import RealityKit
import simd
import AppKit

enum ConstellationLineEntity {
    static func make(from start: SIMD3<Float>, to end: SIMD3<Float>) -> Entity {
        let delta = end - start
        let distance = simd_length(delta)

        let mesh = MeshResource.generateCylinder(height: distance, radius: 0.25)
        var material = UnlitMaterial()
        material.color = .init(tint: .white)
        // Doesn't write depth, so it can never occlude the stars it connects — with depth writes
        // off, visual stacking among non-depth-writing elements falls back to submission order,
        // which is reliable at the ~490-unit range these all render at (actual depth differences
        // of a few hundredths of a unit are too small for the depth buffer to resolve there).
        material.writesDepth = false
        let entity = ModelEntity(mesh: mesh, materials: [material])

        entity.position = (start + end) / 2

        let up = SIMD3<Float>(0, 1, 0)
        let direction = normalize(delta)
        if abs(dot(up, direction)) < 0.9999 {
            entity.orientation = simd_quatf(from: up, to: direction)
        }

        return entity
    }
}
