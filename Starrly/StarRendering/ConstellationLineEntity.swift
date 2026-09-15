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

        let mesh = MeshResource.generateCylinder(height: distance, radius: 3.0)
        var material = UnlitMaterial()
        material.color = .init(tint: .white)
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
