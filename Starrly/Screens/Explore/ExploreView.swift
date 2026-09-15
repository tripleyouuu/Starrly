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
    @State private var capsuleScreenPoints: [UUID: CGPoint] = [:]
    @State private var lastManualPanAt: Date = .distantPast
    @State private var lastTickDate: Date?
    @State private var cameraContent: RealityViewCameraContent?

    private static let sphereRadius: Double = 490
    private static let autoPanDegreesPerSecond: Double = 1.5
    private static let manualPanPauseDuration: TimeInterval = 5

    var body: some View {
        ZStack {
            GeometryReader { geometry in
                TimelineView(.animation) { timeline in
                    ZStack {
                        RealityView { content in
                            cameraRig.setInitial(yaw: 0, pitch: SkyCameraRig.defaultPitch)
                            content.camera = .virtual
                            content.add(cameraRig.rigEntity)
                            content.add(await SkySphereEntity.make())
                            await ConstellationSceneBuilder.populate(content: content, constellations: constellations, includeHitVolumes: false)
                            cameraContent = content
                        } update: { content in
                            cameraContent = content
                        }
                        .gesture(dragGesture, including: centeredConstellationID == nil ? .all : .none)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .id(sceneResetToken)
                        .onChange(of: timeline.date) { _, newDate in
                            tick(at: newDate)
                            updateCapsulePoints(viewportSize: geometry.size)
                        }

                        if centeredConstellationID != nil {
                            Color.clear
                                .contentShape(Rectangle())
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                .onTapGesture { handleBackgroundTap() }
                        }

                        ForEach(constellations) { constellation in
                            if let screenPoint = capsuleScreenPoints[constellation.id] {
                                constellationCapsule(constellation: constellation, screenPoint: screenPoint)
                            }
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

    private var dragGesture: some Gesture {
        DragGesture()
            .onChanged { value in
                let deltaX = value.translation.width - lastDragTranslation.width
                let deltaY = value.translation.height - lastDragTranslation.height
                lastDragTranslation = value.translation
                lastManualPanAt = Date()
                cameraRig.pan(deltaYaw: -deltaX * 0.2, deltaPitch: deltaY * 0.2)
            }
            .onEnded { _ in
                lastDragTranslation = .zero
            }
    }

    private func constellationCapsule(constellation: Constellation, screenPoint: CGPoint) -> some View {
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
            handleCapsuleTap(constellation)
        }
    }

    private func handleCapsuleTap(_ constellation: Constellation) {
        if centeredConstellationID == constellation.id {
            appState.route = .constellation(constellation.id, returnTo: .explore)
            return
        }
        guard let placement = ExploreLayoutEngine.layout(for: constellations)[constellation.id] else { return }
        centeredConstellationID = constellation.id
        // SkyProjection places world objects using the opposite yaw sign convention
        // from how SkyCameraRig actually orients the camera — negate to compensate.
        cameraRig.startAnimating(
            toYaw: -placement.position.yaw,
            pitch: placement.position.pitch,
            fieldOfView: SkyCameraRig.zoomedFieldOfView
        )
    }

    private func handleBackgroundTap() {
        guard centeredConstellationID != nil else { return }
        centeredConstellationID = nil
        cameraRig.startAnimating(toYaw: cameraRig.yaw, pitch: cameraRig.pitch, fieldOfView: SkyCameraRig.defaultFieldOfView)
    }

    private func tick(at now: Date) {
        cameraRig.tick(at: now)
        defer { lastTickDate = now }

        let isPaused = centeredConstellationID != nil
            || cameraRig.isAnimating
            || now.timeIntervalSince(lastManualPanAt) < Self.manualPanPauseDuration

        guard !isPaused, let previous = lastTickDate else { return }
        let elapsed = now.timeIntervalSince(previous)
        guard elapsed > 0, elapsed < 1 else { return }
        cameraRig.autoPanStep(deltaYaw: elapsed * Self.autoPanDegreesPerSecond)
    }

    private func updateCapsulePoints(viewportSize: CGSize) {
        guard let content = cameraContent, viewportSize.width > 0, viewportSize.height > 0 else { return }
        let placements = ExploreLayoutEngine.layout(for: constellations)
        var newPoints: [UUID: CGPoint] = [:]

        for constellation in constellations {
            guard let placement = placements[constellation.id] else { continue }
            let starWorldPositions = constellation.stars.map {
                SkyProjection.starWorldPosition(
                    star: $0,
                    constellationCentroid: placement.position,
                    localOrigin: placement.localOrigin,
                    radius: Self.sphereRadius,
                    spreadScale: placement.spreadScale
                )
            }
            guard !starWorldPositions.isEmpty else { continue }

            let visibleCount = starWorldPositions
                .compactMap { content.project(point: $0, to: .local) }
                .filter { isWithinViewport(point: $0, size: viewportSize) }
                .count
            guard Double(visibleCount) / Double(starWorldPositions.count) > 0.5 else { continue }

            let centroidWorld = SkyProjection.worldPosition(for: placement.position, radius: Self.sphereRadius)
            guard let centroidScreen = content.project(point: centroidWorld, to: .local),
                  isWithinViewport(point: centroidScreen, size: viewportSize) else { continue }
            newPoints[constellation.id] = centroidScreen
        }

        capsuleScreenPoints = newPoints
    }

    private func isWithinViewport(point: CGPoint, size: CGSize) -> Bool {
        point.x >= 0 && point.x <= size.width && point.y >= 0 && point.y <= size.height
    }

    private func resetLayout() {
        cameraRig = SkyCameraRig()
        sceneResetToken = UUID()
        centeredConstellationID = nil
        lastManualPanAt = .distantPast
        lastTickDate = nil
        cameraContent = nil
        capsuleScreenPoints = [:]
    }
}
