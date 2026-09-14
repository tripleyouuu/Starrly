//
//  ExploreView.swift
//  Starrly
//
//  Created by Vitha Watson on 14/09/26.
//

import SwiftUI
import RealityKit
import SwiftData

struct ExploreView: View {
    @Environment(AppState.self) private var appState
    @Query private var constellations: [Constellation]

    @State private var cameraRig = SkyCameraRig()
    @State private var interactionState: ExploreInteractionState = .idle
    @State private var lastDragTranslation: CGSize = .zero

    private var labelText: String? {
        switch interactionState {
        case .idle:
            return nil
        case .constellationName(let id):
            return constellations.first { $0.id == id }?.name
        case .starName(let starID, let constellationID):
            return constellations
                .first { $0.id == constellationID }?
                .stars.first { $0.id == starID }?
                .name
        }
    }

    var body: some View {
        ZStack {
            RealityView { content in
                content.camera = .virtual
                content.add(cameraRig.rigEntity)
                content.add(SkySphereEntity.make())
                content.add(HorizonCylinderEntity.make())

                for constellation in constellations {
                    guard let position = constellation.explorePosition else { continue }

                    content.add(makeConstellationHitVolume(constellation: constellation, at: position))

                    for star in constellation.stars {
                        let starEntity = StarBillboardEntity.make(star: star)
                        starEntity.position = starWorldPosition(star: star, constellationCentroid: position)
                        content.add(starEntity)
                    }
                }
            }
            .gesture(
                DragGesture()
                    .onChanged { value in
                        let deltaX = value.translation.width - lastDragTranslation.width
                        let deltaY = value.translation.height - lastDragTranslation.height
                        lastDragTranslation = value.translation
                        cameraRig.pan(deltaYaw: -deltaX * 0.2, deltaPitch: deltaY * 0.2)
                    }
                    .onEnded { _ in
                        lastDragTranslation = .zero
                    }
            )
            .gesture(
                SpatialTapGesture()
                    .targetedToAnyEntity()
                    .onEnded { value in
                        handleTap(entity: value.entity)
                    }
            )

            ExploreOverlayUI(
                labelText: labelText,
                onBack: { appState.route = .home },
                onDiscover: { appState.route = .discovery }
            )
        }
    }

    private func handleTap(entity: Entity) {
        let target = resolveTarget(from: entity)
        let (newState, action) = ExploreInteractionStateMachine.handleTap(target, state: interactionState)
        interactionState = newState

        switch action {
        case .navigateToConstellation(let id):
            appState.route = .constellation(id, returnTo: .explore)
        case .navigateToStar(let id):
            appState.route = .star(id, returnTo: .explore)
        case .none:
            break
        }
    }

    private func resolveTarget(from entity: Entity) -> TapTarget? {
        var current: Entity? = entity
        while let e = current {
            if e.name.hasPrefix("star:"), let uuid = UUID(uuidString: String(e.name.dropFirst(5))) {
                if let constellation = constellations.first(where: { c in c.stars.contains { $0.id == uuid } }) {
                    return .star(uuid, constellationID: constellation.id)
                }
            }
            if e.name.hasPrefix("constellation:"), let uuid = UUID(uuidString: String(e.name.dropFirst(14))) {
                return .constellation(uuid)
            }
            current = e.parent
        }
        return nil
    }

    private func makeConstellationHitVolume(constellation: Constellation, at position: SkyPosition) -> Entity {
        let entity = Entity()
        entity.name = "constellation:\(constellation.id.uuidString)"
        entity.components.set(InputTargetComponent())
        entity.components.set(CollisionComponent(shapes: [.generateSphere(radius: 12)]))
        entity.position = worldPosition(for: position, radius: 490)
        return entity
    }

    private func starWorldPosition(star: Star, constellationCentroid: SkyPosition) -> SIMD3<Float> {
        let scale = 0.05
        let position = SkyPosition(
            yaw: constellationCentroid.yaw + star.localPosition.x * scale,
            pitch: constellationCentroid.pitch + star.localPosition.y * scale
        )
        return worldPosition(for: position, radius: 490)
    }

    private func worldPosition(for position: SkyPosition, radius: Double) -> SIMD3<Float> {
        let yawRadians = position.yaw * .pi / 180
        let pitchRadians = position.pitch * .pi / 180
        let x = radius * cos(pitchRadians) * sin(yawRadians)
        let y = radius * sin(pitchRadians)
        let z = -radius * cos(pitchRadians) * cos(yawRadians)
        return SIMD3<Float>(Float(x), Float(y), Float(z))
    }
}
