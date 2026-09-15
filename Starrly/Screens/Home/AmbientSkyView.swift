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

    var body: some View {
        RealityView { content in
            let rig = SkyCameraRig()
            rig.setInitial(yaw: 0, pitch: 20)

            content.camera = .virtual
            content.add(rig.rigEntity)
            content.add(await SkySphereEntity.make())
            content.add(await HorizonCylinderEntity.make())

            for constellation in constellations {
                guard let position = constellation.explorePosition else { continue }

                for star in constellation.stars {
                    let starEntity = await StarBillboardEntity.make(star: star)
                    starEntity.position = SkyProjection.starWorldPosition(star: star, constellationCentroid: position, radius: 490)
                    content.add(starEntity)
                }
            }
        }
        .blur(radius: isBlurred ? 20 : 0)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
