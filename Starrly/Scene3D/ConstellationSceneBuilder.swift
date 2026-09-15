//
//  ConstellationSceneBuilder.swift
//  Starrly
//
//  Created by Vitha Watson on 15/09/26.
//

import Foundation
import RealityKit
import SwiftUI

enum ConstellationSceneBuilder {
    static func populate(content: some RealityViewContentProtocol, constellations: [Constellation], includeHitVolumes: Bool) async {
        let scale = ExploreLayoutEngine.densityScale(for: constellations.count)
        let positions = ExploreLayoutEngine.layout(for: constellations)

        for constellation in constellations {
            guard let position = positions[constellation.id] else { continue }
            constellation.explorePosition = position

            if includeHitVolumes {
                content.add(makeConstellationHitVolume(constellation: constellation, at: position, scale: scale))
            }

            var starPositions: [UUID: SIMD3<Float>] = [:]

            for star in constellation.stars {
                let worldPosition = SkyProjection.starWorldPosition(
                    star: star,
                    constellationCentroid: position,
                    radius: 490,
                    spreadScale: 0.7 * scale
                )
                starPositions[star.id] = worldPosition

                let starEntity = await StarBillboardEntity.make(star: star, sizeScale: scale)
                starEntity.position = worldPosition
                content.add(starEntity)
            }

            let orderedStars = ConstellationPathBuilder.orderedConnectedStars(from: constellation.stars)
            for (previous, current) in zip(orderedStars, orderedStars.dropFirst()) {
                guard let start = starPositions[previous.id], let end = starPositions[current.id] else { continue }
                content.add(ConstellationLineEntity.make(from: start, to: end))
            }
        }
    }

    private static func makeConstellationHitVolume(constellation: Constellation, at position: SkyPosition, scale: Double) -> Entity {
        let entity = Entity()
        entity.name = "constellation:\(constellation.id.uuidString)"
        entity.components.set(InputTargetComponent())
        entity.components.set(CollisionComponent(shapes: [.generateSphere(radius: Float(12 * scale))]))
        entity.position = SkyProjection.worldPosition(for: position, radius: 490)
        return entity
    }
}
