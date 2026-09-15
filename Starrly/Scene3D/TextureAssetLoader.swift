//
//  TextureAssetLoader.swift
//  Starrly
//
//  Created by Vitha Watson on 14/09/26.
//

import RealityKit
import AppKit

enum TextureAssetLoader {
    /// Loads a `TextureResource` from an Asset Catalog image by decoding it through
    /// AppKit/CoreGraphics first. `TextureResource(named:)` goes through MTKTextureLoader,
    /// which fails with "Image decoding failed" for some of this project's PNGs (large,
    /// alpha-heavy exports from Figma); going through `NSImage`/`CGImage` avoids that path.
    static func loadTexture(named name: String) -> TextureResource? {
        guard let nsImage = NSImage(named: name) else { return nil }
        var rect = NSRect(origin: .zero, size: nsImage.size)
        guard let cgImage = nsImage.cgImage(forProposedRect: &rect, context: nil, hints: nil) else { return nil }
        return try? TextureResource(image: cgImage, withName: name, options: .init(semantic: .color))
    }
}
