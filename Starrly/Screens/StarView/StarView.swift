//
//  StarView.swift
//  Starrly
//
//  Created by Vitha Watson on 14/09/26.
//


import SwiftUI

struct StarView: View {
    let type: StarType
    let color: StarColor

    @State private var shadowRadius: CGFloat = 0
    @State private var pulseScale: CGFloat = 1
    @State private var haloScale: CGFloat = 1
    @State private var rotationDegrees: Double = 0

    var body: some View {
        ZStack {
            ForEach(StarAsset.layers(for: type), id: \.self) { layer in
                Image(layer)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .colorMultiply(color.color)
                    .scaleEffect(layerScale(for: layer))
                    .rotationEffect(.degrees(StarMotionSpec.layerRotates(type: type, layer: layer) ? rotationDegrees : 0))
            }
        }
        .shadow(color: Color.starrlyOffWhite, radius: shadowRadius)
        .onAppear(perform: startIdleMotion)
        .task { await startTwinkle() }
    }

    private func layerScale(for layer: String) -> CGFloat {
        let base = StarAsset.relativeScale(for: layer)
        if StarMotionSpec.layerShrinks(type: type, layer: layer) {
            return base * haloScale
        }
        if StarMotionSpec.layerPulses(type: type, layer: layer) {
            return base * pulseScale
        }
        return base
    }

    private func startIdleMotion() {
        if StarMotionSpec.pulsesAnyLayer(type) {
            withAnimation(.easeInOut(duration: StarMotionSpec.pulseDuration).repeatForever(autoreverses: true)) {
                pulseScale = StarMotionSpec.pulseGrowScale
            }
        }
        if StarMotionSpec.rotatesAnyLayer(type) {
            withAnimation(.linear(duration: StarMotionSpec.rotationDuration).repeatForever(autoreverses: false)) {
                rotationDegrees = 360
            }
        }
        if StarMotionSpec.shrinksAnyLayer(type) {
            withAnimation(.easeInOut(duration: StarMotionSpec.pulseDuration).repeatForever(autoreverses: true)) {
                haloScale = StarMotionSpec.haloShrinkScale
            }
        }
    }

    private func startTwinkle() async {
        let delay = Double.random(in: StarMotionSpec.twinkleDelayRange)
        let duration = Double.random(in: StarMotionSpec.twinkleDurationRange)
        try? await Task.sleep(for: .seconds(delay))
        guard !Task.isCancelled else { return }
        withAnimation(.easeInOut(duration: duration).repeatForever(autoreverses: true)) {
            shadowRadius = StarMotionSpec.twinkleShadowRadius * StarMotionSpec.twinkleIntensity(for: type)
        }
    }
}
