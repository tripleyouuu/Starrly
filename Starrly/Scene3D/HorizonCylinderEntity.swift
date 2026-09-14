//
//  HorizonCylinderEntity.swift
//  Starrly
//
//  Created by Vitha Watson on 14/09/26.
//

import RealityKit

enum HorizonCylinderEntity {
    static func make() -> Entity {
        let mesh = MeshResource.generateCylinder(height: 60, radius: 120)
        var material = UnlitMaterial()
        if let texture = try? TextureResource.load(named: "HorizonStrip") {
            material.color = .init(texture: .init(texture))
        }
        material.blending = .transparent(opacity: .init(floatLiteral: 1))
        let entity = ModelEntity(mesh: mesh, materials: [material])
        entity.scale = [-1, 1, 1]
        entity.position.y = -20
        return entity
    }
}
