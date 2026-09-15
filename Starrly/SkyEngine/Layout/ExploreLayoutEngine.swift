//
//  ExploreLayoutEngine.swift
//  Starrly
//
//  Created by Vitha Watson on 14/09/26.
//

import Foundation

enum ExploreLayoutEngine {
    
    static let minPitch: Double = 20
    static let maxPitch: Double = 40

    static func layout(for constellations: [Constellation]) -> [UUID: SkyPosition] {
        let ordered = constellations.sorted { $0.createdAt < $1.createdAt }
        let count = ordered.count
        guard count > 0 else { return [:] }

        let rows = max(1, min(5, Int(Double(count).squareRoot().rounded())))
        let rowSpacing = rows > 1 ? (maxPitch - minPitch) / Double(rows - 1) : 0

        var rowBuckets: [[Int]] = Array(repeating: [], count: rows)
        for index in 0..<count {
            rowBuckets[index % rows].append(index)
        }

        var positions: [UUID: SkyPosition] = [:]
        for (row, indices) in rowBuckets.enumerated() {
            guard !indices.isEmpty else { continue }
            let pitch = minPitch + rowSpacing * Double(row)
            let yawStep = 360.0 / Double(indices.count)
            let rowStagger = (360.0 / Double(rows)) * Double(row) / 2

            for (slot, index) in indices.enumerated() {
                let yaw = (yawStep * Double(slot) + rowStagger).truncatingRemainder(dividingBy: 360)
                positions[ordered[index].id] = SkyPosition(yaw: yaw, pitch: pitch)
            }
        }
        return positions
    }

    static func densityScale(for constellationCount: Int) -> Double {
        max(0.4, 1.0 / Double(max(constellationCount, 1)).squareRoot())
    }
}
