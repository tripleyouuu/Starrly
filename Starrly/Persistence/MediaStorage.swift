//
//  MediaStorage.swift
//  Starrly
//
//  Created by Vitha Watson on 14/09/26.
//

import Foundation

enum MediaStorage {
    static func save(_ data: Data, fileExtension: String) -> String? {
        let filename = UUID().uuidString + "." + fileExtension
        let fileURL = directory.appendingPathComponent(filename)
        do {
            try data.write(to: fileURL)
            return filename
        } catch {
            return nil
        }
    }

    static func url(for filename: String) -> URL {
        directory.appendingPathComponent(filename)
    }

    static func delete(_ filename: String) {
        try? FileManager.default.removeItem(at: url(for: filename))
    }

    private static var directory: URL {
        let base = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
        let mediaDirectory = base.appendingPathComponent("Media", isDirectory: true)
        try? FileManager.default.createDirectory(at: mediaDirectory, withIntermediateDirectories: true)
        return mediaDirectory
    }
}
