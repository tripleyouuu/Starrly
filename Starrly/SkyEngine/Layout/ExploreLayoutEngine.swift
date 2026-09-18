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
    private static let maxLineAngularSpan: Double = 12
    private static let yawGapDegrees: Double = 16
    private static let maxPerRow = 10
    private static let maxRows = 3
    private static let rowBandWidth: Double = 20

    struct Placement {
        let position: SkyPosition
        let spreadScale: Double
        let localOrigin: CGPoint
        let pitchBand: ClosedRange<Double>
    }

    static func layout(for constellations: [Constellation]) -> [UUID: Placement] {
        let ordered = constellations.sorted { $0.createdAt < $1.createdAt }
        guard !ordered.isEmpty else { return [:] }

        let rowCount = rowCount(forConstellationCount: ordered.count)
        let gap = rowGap(forRowCount: rowCount)
        let topEdge = overallPitchRange(forRowCount: rowCount).upperBound

        var placements: [UUID: Placement] = [:]
        for (rowIndex, rowConstellations) in splitEvenly(ordered, into: rowCount).enumerated() {
            let rowTop = topEdge - Double(rowIndex) * (rowBandWidth + gap)
            let rowBottom = rowTop - rowBandWidth
            let pitchBand = rowBottom...rowTop
            placements.merge(layoutRow(rowConstellations, pitchBand: pitchBand)) { _, new in new }
        }
        return placements
    }
    static func overallPitchRange(constellationCount: Int) -> ClosedRange<Double> {
        overallPitchRange(forRowCount: rowCount(forConstellationCount: constellationCount))
    }

    static func densityScale(for constellationCount: Int) -> Double {
        max(0.4, 1.0 / Double(max(constellationCount, 1)).squareRoot())
    }

    private static func rowCount(forConstellationCount count: Int) -> Int {
        guard count > 0 else { return 1 }
        return min(maxRows, max(1, Int(ceil(Double(count) / Double(maxPerRow)))))
    }

    private static func overallPitchRange(forRowCount rowCount: Int) -> ClosedRange<Double> {
        switch rowCount {
        case 1: return minPitch...maxPitch
        case 2: return 20...70
        default: return 10...80
        }
    }

    private static func rowGap(forRowCount rowCount: Int) -> Double {
        switch rowCount {
        case 2: return 10
        case 3: return 5
        default: return 0
        }
    }

    private static func layoutRow(_ ordered: [Constellation], pitchBand: ClosedRange<Double>) -> [UUID: Placement] {
        guard !ordered.isEmpty else { return [:] }

        let midPitch = (pitchBand.lowerBound + pitchBand.upperBound) / 2
        let verticalSpan = pitchBand.upperBound - pitchBand.lowerBound

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
            var scale = min(maxSpreadScale, max(minSpreadScale, verticalSpan / yRange))

            let connectedStars = ConstellationPathBuilder.orderedConnectedStars(from: constellation.stars)
            let maxSegmentLength = zip(connectedStars, connectedStars.dropFirst())
                .map { star1, star2 -> Double in
                    let dx = Double(star1.localPosition.x - star2.localPosition.x)
                    let dy = Double(star1.localPosition.y - star2.localPosition.y)
                    return (dx * dx + dy * dy).squareRoot()
                }
                .max() ?? 0
            if maxSegmentLength > 0 {
                scale = max(minSpreadScale, min(scale, maxLineAngularSpan / maxSegmentLength))
            }

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
                localOrigin: metric.localOrigin,
                pitchBand: pitchBand
            )
            yawCursor += width + gap
        }
        return placements
    }

    private static func splitEvenly<T>(_ items: [T], into parts: Int) -> [[T]] {
        guard parts > 1 else { return [items] }
        let base = items.count / parts
        let remainder = items.count % parts
        var result: [[T]] = []
        var index = 0
        for rowIndex in 0..<parts {
            let count = base + (rowIndex < remainder ? 1 : 0)
            result.append(Array(items[index..<(index + count)]))
            index += count
        }
        return result
    }
}
