//
//  TextureAssetLoader.swift
//  Starrly
//
//  Created by Vitha Watson on 14/09/26.
//

import RealityKit
import AppKit

enum TextureAssetLoader {
    static func loadTexture(named name: String, mipmapsMode: TextureResource.MipmapsMode = .allocateAndGenerateAll) -> TextureResource? {
        guard let nsImage = NSImage(named: name) else { return nil }
        var rect = NSRect(origin: .zero, size: nsImage.size)
        guard let cgImage = nsImage.cgImage(forProposedRect: &rect, context: nil, hints: nil) else { return nil }
        return try? TextureResource(image: cgImage, withName: name, options: .init(semantic: .color, mipmapsMode: mipmapsMode))
    }
}
