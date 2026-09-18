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

    static let radialGlowTexture: TextureResource? = {
        let size = 128
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        guard let context = CGContext(
            data: nil,
            width: size,
            height: size,
            bitsPerComponent: 8,
            bytesPerRow: 0,
            space: colorSpace,
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
        ) else { return nil }

        let center = CGPoint(x: CGFloat(size) / 2, y: CGFloat(size) / 2)
        let colors = [
            CGColor(red: 1, green: 1, blue: 1, alpha: 1),
            CGColor(red: 1, green: 1, blue: 1, alpha: 0)
        ]
        guard let gradient = CGGradient(colorsSpace: colorSpace, colors: colors as CFArray, locations: [0, 1]) else { return nil }
        context.drawRadialGradient(
            gradient,
            startCenter: center, startRadius: 0,
            endCenter: center, endRadius: CGFloat(size) / 2,
            options: []
        )

        guard let cgImage = context.makeImage() else { return nil }
        return try? TextureResource(image: cgImage, withName: "RadialGlow", options: .init(semantic: .color, mipmapsMode: .allocateAndGenerateAll))
    }()
}
