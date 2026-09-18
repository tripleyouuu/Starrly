//
//  MoonPhaseMask.swift
//  Starrly
//
//  Created by Vitha Watson on 14/09/26.
//


import SwiftUI

struct MoonPhaseMask: View {
    let phase: MoonPhase

    var body: some View {
        Canvas { context, size in
            let r = min(size.width, size.height) / 2
            let center = CGPoint(x: size.width / 2, y: size.height / 2)
            let angle = angleForPhase(phase)
            let k = cos(angle)
            let waxing = angle <= .pi

            var path = Path()
            path.addArc(
                center: center,
                radius: r,
                startAngle: .degrees(waxing ? 90 : -90),
                endAngle: .degrees(waxing ? -90 : 90),
                clockwise: waxing
            )

            var terminator = Path()
            terminator.addArc(
                center: .zero,
                radius: r,
                startAngle: .degrees(waxing ? -90 : 90),
                endAngle: .degrees(waxing ? 90 : -90),
                clockwise: waxing
            )
            let transform = CGAffineTransform(translationX: center.x, y: center.y)
                .scaledBy(x: k, y: 1)
            terminator = terminator.applying(transform)

            path.addPath(terminator)
            path.closeSubpath()

            context.fill(path, with: .color(Color.starrlyBackground))
        }
        .blur(radius: 4)
    }

    private func angleForPhase(_ phase: MoonPhase) -> Double {
        let index = MoonPhase.allCases.firstIndex(of: phase) ?? 0
        return Double(index) / Double(MoonPhase.allCases.count) * 2 * .pi
    }
}