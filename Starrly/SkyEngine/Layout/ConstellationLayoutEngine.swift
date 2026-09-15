//
//  ConstellationLayoutEngine.swift
//  Starrly
//
//  Created by Vitha Watson on 14/09/26.
//

import Foundation
import CoreGraphics

enum ConstellationLayoutEngine {
    static let minDistance: Double = 60
    static let maxDistance: Double = 220

    static func placeNewStar(among existing: [CGPoint]) -> CGPoint {
        guard !existing.isEmpty else {
            return .zero
        }

        let centroid = centroid(of: existing)

        for _ in 0..<200 {
            let angle = Double.random(in: 0..<(2 * .pi))
            let distance = Double.random(in: minDistance...maxDistance)
            let candidate = CGPoint(
                x: centroid.x + cos(angle) * distance,
                y: centroid.y + sin(angle) * distance
            )

            if isFarEnough(candidate, from: existing) {
                return candidate
            }
        }

        return CGPoint(
            x: centroid.x + Double.random(in: -maxDistance...maxDistance),
            y: centroid.y + Double.random(in: -maxDistance...maxDistance)
        )
    }

    static func resolveIntersections(for constellation: Constellation) {
        let path = ConstellationPathBuilder.orderedConnectedStars(from: constellation.stars)
        guard let newest = path.last else { return }

        let allSegments = zip(path, path.dropFirst()).map { ($0.localPosition, $1.localPosition) }
        guard allSegments.count > 2 else { return }
        let earlierSegments = Array(allSegments.dropLast(2))
        let newSegmentStart = path[path.count - 2].localPosition

        func crossesAnEarlierSegment(_ candidate: CGPoint) -> Bool {
            earlierSegments.contains { segmentsIntersect(newSegmentStart, candidate, $0.0, $0.1) }
        }

        guard crossesAnEarlierSegment(newest.localPosition) else { return }

        let others = constellation.stars.filter { $0.id != newest.id }.map(\.localPosition)
        for _ in 0..<200 {
            let candidate = placeNewStar(among: others)
            if !crossesAnEarlierSegment(candidate) {
                newest.localPosition = candidate
                return
            }
        }
    }

    private static func segmentsIntersect(_ p1: CGPoint, _ p2: CGPoint, _ p3: CGPoint, _ p4: CGPoint) -> Bool {
        func orientation(_ a: CGPoint, _ b: CGPoint, _ c: CGPoint) -> Int {
            let value = (b.y - a.y) * (c.x - b.x) - (b.x - a.x) * (c.y - b.y)
            if abs(value) < 1e-9 { return 0 }
            return value > 0 ? 1 : 2
        }
        func onSegment(_ a: CGPoint, _ b: CGPoint, _ c: CGPoint) -> Bool {
            min(a.x, c.x) <= b.x && b.x <= max(a.x, c.x) && min(a.y, c.y) <= b.y && b.y <= max(a.y, c.y)
        }

        let o1 = orientation(p1, p2, p3)
        let o2 = orientation(p1, p2, p4)
        let o3 = orientation(p3, p4, p1)
        let o4 = orientation(p3, p4, p2)

        if o1 != o2 && o3 != o4 { return true }
        if o1 == 0 && onSegment(p1, p3, p2) { return true }
        if o2 == 0 && onSegment(p1, p4, p2) { return true }
        if o3 == 0 && onSegment(p3, p1, p4) { return true }
        if o4 == 0 && onSegment(p3, p2, p4) { return true }
        return false
    }

    private static func isFarEnough(_ point: CGPoint, from existing: [CGPoint]) -> Bool {
        existing.allSatisfy { distance($0, point) >= minDistance }
    }

    private static func distance(_ a: CGPoint, _ b: CGPoint) -> Double {
        sqrt(pow(a.x - b.x, 2) + pow(a.y - b.y, 2))
    }

    private static func centroid(of points: [CGPoint]) -> CGPoint {
        let sum = points.reduce(CGPoint.zero) { CGPoint(x: $0.x + $1.x, y: $0.y + $1.y) }
        return CGPoint(x: sum.x / Double(points.count), y: sum.y / Double(points.count))
    }
}
