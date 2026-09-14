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
