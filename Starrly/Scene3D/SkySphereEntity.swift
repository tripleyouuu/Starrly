//
//  SkySphereEntity.swift
//  Starrly
//
//  Created by Vitha Watson on 14/09/26.
//

import RealityKit
import AppKit
import Metal

enum SkySphereEntity {
    static func make() async -> Entity {
        let mesh = MeshResource.generateSphere(radius: 500)
        var material = UnlitMaterial()
        if let texture = TextureAssetLoader.loadTexture(named: "SkySphere", mipmapsMode: .none) {
            let samplerDescriptor = MTLSamplerDescriptor()
            samplerDescriptor.sAddressMode = .clampToEdge
            samplerDescriptor.tAddressMode = .clampToEdge
            samplerDescriptor.magFilter = .linear
            samplerDescriptor.minFilter = .linear
            let sampler = MaterialParameters.Texture.Sampler(samplerDescriptor)
            material.color = .init(texture: .init(texture, sampler: sampler))
        } else {
            material.color = .init(tint: NSColor.red)
        }
        material.faceCulling = .none
        let entity = ModelEntity(mesh: mesh, materials: [material])
        entity.scale = [-1, 1, 1]
        return entity
    }
}
