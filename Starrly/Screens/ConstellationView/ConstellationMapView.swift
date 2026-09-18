//
//  ConstellationMapView.swift
//  Starrly
//
//  Created by Vitha Watson on 14/09/26.
//

import SwiftUI

struct ConstellationMapView: View {
    let stars: [Star]
    let onSelect: (Star) -> Void

    @State private var selectedStarID: UUID?

    private var connectedStars: [Star] {
        ConstellationPathBuilder.orderedConnectedStars(from: stars)
    }

    private var maxPanDistance: CGFloat {
        guard !stars.isEmpty else { return 200 }
        let xs = stars.map(\.localPosition.x)
        let ys = stars.map(\.localPosition.y)
        let width = (xs.max() ?? 0) - (xs.min() ?? 0)
        let height = (ys.max() ?? 0) - (ys.min() ?? 0)
        return max(width, height) / 2 + 150
    }

    var body: some View {
        PannableZoomableCanvas(maxPanDistance: maxPanDistance) { scale, offset in
            GeometryReader { geometry in
                let center = CGPoint(x: geometry.size.width / 2, y: geometry.size.height / 2)

                ZStack {
                    Canvas { context, _ in
                        guard connectedStars.count > 1 else { return }
                        var path = Path()
                        for (index, star) in connectedStars.enumerated() {
                            let point = CGPoint(
                                x: center.x + star.localPosition.x,
                                y: center.y + star.localPosition.y
                            )
                            if index == 0 {
                                path.move(to: point)
                            } else {
                                path.addLine(to: point)
                            }
                        }
                        context.stroke(path, with: .color(Color.starrlyOffWhite), lineWidth: 0.5)
                    }

                    ForEach(stars) { star in
                        let point = CGPoint(
                            x: center.x + star.localPosition.x,
                            y: center.y + star.localPosition.y
                        )
                        let isReachable = isWithinViewport(
                            worldPoint: point,
                            elementRadius: 24,
                            scale: scale,
                            offset: offset,
                            center: center,
                            geometrySize: geometry.size
                        )

                        StarView(type: star.type, color: star.color)
                            .frame(width: 32, height: 32)
                            .position(point)

                        if isReachable {
                            Color.clear
                                .frame(width: 48, height: 48)
                                .contentShape(Circle())
                                .position(point)
                                .onTapGesture {
                                    selectedStarID = star.id
                                }
                        }
                    }
                }
            }
        } overlay: { scale, offset in
            GeometryReader { geometry in
                let center = CGPoint(x: geometry.size.width / 2, y: geometry.size.height / 2)

                if let selectedStarID, let star = stars.first(where: { $0.id == selectedStarID }) {
                    let worldPoint = CGPoint(
                        x: center.x + star.localPosition.x,
                        y: center.y + star.localPosition.y
                    )
                    let isReachable = isWithinViewport(
                        worldPoint: worldPoint,
                        elementRadius: 0,
                        scale: scale,
                        offset: offset,
                        center: center,
                        geometrySize: geometry.size
                    )

                    if isReachable {
                        let screenPoint = CGPoint(
                            x: center.x + (worldPoint.x - center.x) * scale + offset.width,
                            y: center.y + (worldPoint.y - center.y) * scale + offset.height
                        )

                        HStack(spacing: 6) {
                            Text(star.name)
                                .lineLimit(1)
                                .frame(maxWidth: 140, alignment: .leading)

                            Image(systemName: "chevron.right")
                        }
                        .font(.system(size: 13, weight: .regular))
                        .foregroundStyle(Color.starrlyOffWhite)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .fixedSize()
                        .contentShape(Capsule())
                        .glassEffect(.starrly.interactive(), in: .capsule)
                        .position(x: screenPoint.x, y: screenPoint.y - 24)
                        .onTapGesture {
                            onSelect(star)
                        }
                    }
                }
            }
            .clipped()
        }
        .contentShape(Rectangle())
        .onTapGesture {
            selectedStarID = nil
        }
    }
}
