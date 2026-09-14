//
//  SkySphereEntity.swift
//  Starrly
//
//  Created by Vitha Watson on 14/09/26.
//

import RealityKit

enum SkySphereEntity {
    static func make() -> Entity {
        let mesh = MeshResource.generateSphere(radius: 500)
        var material = UnlitMaterial()
        if let texture = try? TextureResource.load(named: "SkySphere") {
            material.color = .init(texture: .init(texture))
        }
        let entity = ModelEntity(mesh: mesh, materials: [material])
        entity.scale = [-1, 1, 1]
        return entity
    }
}
