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
        let placements = ExploreLayoutEngine.layout(for: constellations)

        for constellation in constellations {
            guard let placement = placements[constellation.id] else { continue }
            constellation.explorePosition = placement.position

            if includeHitVolumes {
                content.add(makeConstellationHitVolume(constellation: constellation, at: placement.position, scale: scale))
            }

            var starPositions: [UUID: SIMD3<Float>] = [:]

            for star in constellation.stars {
                let worldPosition = SkyProjection.starWorldPosition(
                    star: star,
                    constellationCentroid: placement.position,
                    localOrigin: placement.localOrigin,
                    radius: 490,
                    spreadScale: placement.spreadScale
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
