//
//  MediaCompressor.swift
//  Starrly
//
//  Created by Vitha Watson on 16/09/26.
//

import AppKit
import AVFoundation

enum MediaCompressor {
    private static let maxImageDimension: CGFloat = 2048
    private static let jpegQuality: CGFloat = 0.8
    private static let videoExtensions: Set<String> = ["mov", "mp4", "m4v"]
    static func process(_ data: Data, fileExtension: String) async -> (data: Data, fileExtension: String) {
        if videoExtensions.contains(fileExtension.lowercased()) {
            return await compressVideo(data, sourceExtension: fileExtension)
        }
        if let compressed = compressImage(data) {
            return (compressed, "jpg")
        }
        return (data, fileExtension)
    }

    static func compressImage(_ data: Data) -> Data? {
        guard let image = NSImage(data: data) else { return nil }
        let scaled = resized(image, maxDimension: maxImageDimension)
        guard let tiff = scaled.tiffRepresentation,
              let bitmap = NSBitmapImageRep(data: tiff),
              let jpeg = bitmap.representation(using: .jpeg, properties: [.compressionFactor: jpegQuality]) else {
            return nil
        }
        return jpeg
    }

    private static func resized(_ image: NSImage, maxDimension: CGFloat) -> NSImage {
        let size = image.size
        guard size.width > 0, size.height > 0 else { return image }
        let scale = min(1, maxDimension / max(size.width, size.height))
        guard scale < 1 else { return image }

        let newSize = NSSize(width: size.width * scale, height: size.height * scale)
        let canvas = NSImage(size: newSize)
        canvas.lockFocus()
        image.draw(in: NSRect(origin: .zero, size: newSize), from: .zero, operation: .copy, fraction: 1)
        canvas.unlockFocus()
        return canvas
    }


    static func compressVideo(_ data: Data, sourceExtension: String) async -> (data: Data, fileExtension: String) {
        let tempInput = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString + "." + sourceExtension)
        let tempOutput = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString + ".mov")
        defer {
            try? FileManager.default.removeItem(at: tempInput)
            try? FileManager.default.removeItem(at: tempOutput)
        }

        guard (try? data.write(to: tempInput)) != nil else { return (data, sourceExtension) }

        let asset = AVURLAsset(url: tempInput)
        guard let export = AVAssetExportSession(asset: asset, presetName: AVAssetExportPresetMediumQuality) else {
            return (data, sourceExtension)
        }
        export.outputURL = tempOutput
        export.outputFileType = .mov

        await withCheckedContinuation { continuation in
            export.exportAsynchronously {
                continuation.resume()
            }
        }

        guard export.status == .completed, let compressed = try? Data(contentsOf: tempOutput) else {
            return (data, sourceExtension)
        }
        return (compressed, "mov")
    }
}
