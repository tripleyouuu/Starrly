//
//  AmbientSkyView.swift
//  Starrly
//
//  Created by Vitha Watson on 14/09/26.
//


import SwiftUI
import RealityKit

struct AmbientSkyView: View {
    let constellations: [Constellation]
    var isBlurred: Bool = false
    var autoPan: Bool = false

    @Environment(AppSettings.self) private var settings
    @State private var rig = SkyCameraRig()
    @State private var startDate = Date()

    private let panDegreesPerSecond: Double = 1.5

    var body: some View {
        TimelineView(.animation) { timeline in
            RealityView { content in
                rig.setInitial(yaw: 0, pitch: SkyCameraRig.defaultPitch)
                content.camera = .virtual
                content.add(rig.rigEntity)
                content.add(await SkySphereEntity.make())

                await ConstellationSceneBuilder.populate(content: content, constellations: constellations, includeHitVolumes: false, animatesStars: settings.isMotionEnabled)
            }
            .onChange(of: timeline.date) { _, newDate in
                guard autoPan, settings.isMotionEnabled else { return }
                let elapsed = newDate.timeIntervalSince(startDate)
                rig.setYaw(elapsed * panDegreesPerSecond)
            }
        }
        .blur(radius: isBlurred ? 20 : 0)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
