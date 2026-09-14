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
    static func make(star: Star) -> Entity {
        let root = Entity()
        root.name = "star:\(star.id.uuidString)"
        root.components.set(BillboardComponent())
        root.components.set(InputTargetComponent())
        root.components.set(CollisionComponent(shapes: [.generateBox(size: [4, 4, 0.1])]))

        for (index, layerName) in StarAsset.layers(for: star.type).enumerated() {
            let mesh = MeshResource.generatePlane(width: 4, height: 4)
            var material = UnlitMaterial()
            if let texture = try? TextureResource.load(named: layerName) {
                material.color = .init(tint: NSColor(star.color.color), texture: .init(texture))
            }
            material.blending = .transparent(opacity: .init(floatLiteral: 1))
            let layerEntity = ModelEntity(mesh: mesh, materials: [material])
            layerEntity.position.z = Float(index) * 0.01
            root.addChild(layerEntity)
        }

        return root
    }
}
