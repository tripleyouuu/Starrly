//
//  SkySphereEntity.swift
//  Starrly
//
//  Created by Vitha Watson on 14/09/26.
//

import RealityKit
import AppKit

enum SkySphereEntity {
    static func make() async -> Entity {
        let mesh = MeshResource.generateSphere(radius: 500)
        var material = UnlitMaterial()
        if let texture = TextureAssetLoader.loadTexture(named: "SkySphere") {
            material.color = .init(texture: .init(texture))
        } else {
            material.color = .init(tint: NSColor.red)
        }
        let entity = ModelEntity(mesh: mesh, materials: [material])
        entity.scale = [-1, 1, 1]
        return entity
    }
}
