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
    @State private var lastDragTranslation: CGSize = .zero
    @State private var sceneResetToken = UUID()
    @State private var centeredConstellationID: UUID?

    private static let sphereRadius: Double = 490
    private static let verticalFOV: Double = 60

    var body: some View {
        ZStack {
            RealityView { content in
                cameraRig.setInitial(yaw: 0, pitch: SkyCameraRig.defaultPitch)
                content.camera = .virtual
                content.add(cameraRig.rigEntity)
                content.add(await SkySphereEntity.make())

                await ConstellationSceneBuilder.populate(content: content, constellations: constellations, includeHitVolumes: false)
            }
            .gesture(
                DragGesture()
                    .onChanged { value in
                        let deltaX = value.translation.width - lastDragTranslation.width
                        let deltaY = value.translation.height - lastDragTranslation.height
                        lastDragTranslation = value.translation
                        centeredConstellationID = nil
                        cameraRig.pan(deltaYaw: -deltaX * 0.2, deltaPitch: deltaY * 0.2)
                    }
                    .onEnded { _ in
                        lastDragTranslation = .zero
                    }
            )
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .id(sceneResetToken)

            GeometryReader { geometry in
                TimelineView(.animation) { timeline in
                    let _ = cameraRig.tick(at: timeline.date)
                    let placements = ExploreLayoutEngine.layout(for: constellations)

                    ForEach(constellations) { constellation in
                        if let placement = placements[constellation.id],
                           let screenPoint = capsulePoint(for: constellation, placement: placement, viewportSize: geometry.size) {
                            constellationCapsule(constellation: constellation, placement: placement, screenPoint: screenPoint)
                        }
                    }
                }
            }

            ExploreOverlayUI(
                onBack: { appState.route = .home },
                onDiscover: { appState.route = .discovery },
                onResetLayout: resetLayout
            )
        }
    }

    private func constellationCapsule(
        constellation: Constellation,
        placement: ExploreLayoutEngine.Placement,
        screenPoint: CGPoint
    ) -> some View {
        HStack(spacing: 6) {
            Text(constellation.name)
                .lineLimit(1)
                .frame(maxWidth: 140, alignment: .leading)

            Image(systemName: "chevron.right")
        }
        .font(.system(size: 13, weight: .regular))
        .foregroundStyle(Color.starrlyOffWhite)
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .fixedSize()
        .glassEffect(.clear.interactive(), in: .capsule)
        .position(screenPoint)
        .onTapGesture {
            handleCapsuleTap(constellation, placement: placement)
        }
    }

    private func handleCapsuleTap(_ constellation: Constellation, placement: ExploreLayoutEngine.Placement) {
        if centeredConstellationID == constellation.id {
            appState.route = .constellation(constellation.id, returnTo: .explore)
            return
        }
        // SkyProjection places world objects using the opposite yaw sign convention
        // from how SkyCameraRig actually orients the camera — negate to compensate.
        cameraRig.startAnimating(toYaw: -placement.position.yaw, pitch: placement.position.pitch)
        centeredConstellationID = constellation.id
    }

    private func capsulePoint(
        for constellation: Constellation,
        placement: ExploreLayoutEngine.Placement,
        viewportSize: CGSize
    ) -> CGPoint? {
        let starWorldPositions = constellation.stars.map {
            SkyProjection.starWorldPosition(
                star: $0,
                constellationCentroid: placement.position,
                localOrigin: placement.localOrigin,
                radius: Self.sphereRadius,
                spreadScale: placement.spreadScale
            )
        }
        guard !starWorldPositions.isEmpty else { return nil }

        let aspect = Double(viewportSize.width / max(viewportSize.height, 1))
        let visibleCount = starWorldPositions.filter {
            ScreenProjector.isWithinFrustum(
                worldPosition: $0,
                cameraYaw: cameraRig.yaw,
                cameraPitch: cameraRig.pitch,
                verticalFOVDegrees: Self.verticalFOV,
                aspect: aspect
            )
        }.count
        guard Double(visibleCount) / Double(starWorldPositions.count) > 0.5 else { return nil }

        let centroidWorld = SkyProjection.worldPosition(for: placement.position, radius: Self.sphereRadius)
        let projected = ScreenProjector.project(
            worldPosition: centroidWorld,
            cameraYaw: cameraRig.yaw,
            cameraPitch: cameraRig.pitch,
            verticalFOVDegrees: Self.verticalFOV,
            viewportSize: viewportSize
        )
        return projected.isInFrontOfCamera ? projected.point : nil
    }

    private func resetLayout() {
        cameraRig = SkyCameraRig()
        sceneResetToken = UUID()
        centeredConstellationID = nil
    }
}
