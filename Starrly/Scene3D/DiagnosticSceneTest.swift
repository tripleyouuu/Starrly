//
//  DiagnosticSceneTest.swift
//  Starrly
//
//  Created by Vitha Watson on 14/09/26.
//

import SwiftUI
import RealityKit
import AppKit

struct DiagnosticSceneTest: View {
    var body: some View {
        RealityView { content in
            content.camera = .virtual

            let camera = PerspectiveCamera()
            camera.position = [0, 0, 0]
            content.add(camera)

            var material = UnlitMaterial()
            material.color = .init(tint: NSColor.red)
            let box = ModelEntity(mesh: .generateBox(size: 0.5), materials: [material])
            box.position = [0, 0, -2]
            content.add(box)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
