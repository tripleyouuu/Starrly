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
    @State private var sceneResetToken = UUID()

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
                cameraRig.setInitial(yaw: 0, pitch: SkyCameraRig.defaultPitch)
                content.camera = .virtual
                content.add(cameraRig.rigEntity)
                content.add(await SkySphereEntity.make())

                await ConstellationSceneBuilder.populate(content: content, constellations: constellations, includeHitVolumes: true)
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
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .id(sceneResetToken)

            ExploreOverlayUI(
                labelText: labelText,
                onBack: { appState.route = .home },
                onDiscover: { appState.route = .discovery },
                onResetLayout: resetLayout
            )
        }
    }

    private func resetLayout() {
        cameraRig = SkyCameraRig()
        sceneResetToken = UUID()
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
}
