//
//  ExploreLayoutEngine.swift
//  Starrly
//
//  Created by Vitha Watson on 14/09/26.
//

import Foundation
import CoreGraphics

enum ExploreLayoutEngine {

    static let minPitch: Double = 20
    static let maxPitch: Double = 40
    static let minSpreadScale: Double = 0.05
    static let maxSpreadScale: Double = 1.2
    private static let yawGapDegrees: Double = 16

    struct Placement {
        let position: SkyPosition
        let spreadScale: Double
        let localOrigin: CGPoint
    }

    static func layout(for constellations: [Constellation]) -> [UUID: Placement] {
        let ordered = constellations.sorted { $0.createdAt < $1.createdAt }
        guard !ordered.isEmpty else { return [:] }

        let midPitch = (minPitch + maxPitch) / 2
        let verticalSpan = maxPitch - minPitch

        struct Metric {
            let id: UUID
            let spreadScale: Double
            let angularWidth: Double
            let localOrigin: CGPoint
        }

        let metrics: [Metric] = ordered.map { constellation in
            let points = constellation.stars.map(\.localPosition)
            guard points.count > 1,
                  let minY = points.map(\.y).min(), let maxY = points.map(\.y).max(),
                  let minX = points.map(\.x).min(), let maxX = points.map(\.x).max() else {
                return Metric(id: constellation.id, spreadScale: maxSpreadScale, angularWidth: 6, localOrigin: points.first ?? .zero)
            }
            let yRange = max(maxY - minY, 1)
            let xRange = max(maxX - minX, 1)
            let scale = min(maxSpreadScale, max(minSpreadScale, verticalSpan / yRange))
            let origin = CGPoint(x: (minX + maxX) / 2, y: (minY + maxY) / 2)
            return Metric(id: constellation.id, spreadScale: scale, angularWidth: xRange * scale, localOrigin: origin)
        }

        let totalWidth = metrics.reduce(0.0) { $0 + $1.angularWidth } + yawGapDegrees * Double(metrics.count)
        let shrink = totalWidth > 360 ? 360 / totalWidth : 1
        let extraPerGap = totalWidth < 360 ? (360 - totalWidth) / Double(metrics.count) : 0

        var placements: [UUID: Placement] = [:]
        var yawCursor: Double = 0
        for metric in metrics {
            let width = metric.angularWidth * shrink
            let gap = (yawGapDegrees + extraPerGap) * shrink
            let yaw = (yawCursor + width / 2).truncatingRemainder(dividingBy: 360)
            placements[metric.id] = Placement(
                position: SkyPosition(yaw: yaw, pitch: midPitch),
                spreadScale: metric.spreadScale * shrink,
                localOrigin: metric.localOrigin
            )
            yawCursor += width + gap
        }
        return placements
    }

    static func densityScale(for constellationCount: Int) -> Double {
        max(0.4, 1.0 / Double(max(constellationCount, 1)).squareRoot())
    }
}
