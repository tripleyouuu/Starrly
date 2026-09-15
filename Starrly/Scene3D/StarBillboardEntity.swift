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
        root.components.set(InputTargetComponent())

        let size = Float(40 * sizeScale)
        root.components.set(CollisionComponent(shapes: [.generateBox(size: [size, size, 0.1])]))

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
            let layerEntity = ModelEntity(mesh: mesh, materials: [material])
            layerEntity.position.z = Float(index) * 0.01
            root.addChild(layerEntity)
        }

        return root
    }
}
