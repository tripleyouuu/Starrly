//
//  ConstellationMapView.swift
//  Starrly
//
//  Created by Vitha Watson on 14/09/26.
//

import SwiftUI

struct ConstellationMapView: View {
    let stars: [Star]
    @State private var hoveredStarID: UUID?

    private var connectedStars: [Star] {
        ConstellationPathBuilder.orderedConnectedStars(from: stars)
    }

    var body: some View {
        PannableZoomableCanvas {
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
                        context.stroke(path, with: .color(Color.starrlyOffWhite), lineWidth: 1)
                    }

                    ForEach(stars) { star in
                        StarView(type: star.type, color: star.color)
                            .frame(width: 32, height: 32)
                            .position(
                                x: center.x + star.localPosition.x,
                                y: center.y + star.localPosition.y
                            )
                            .onHover { isHovering in
                                hoveredStarID = isHovering ? star.id : nil
                            }
                            .overlay(alignment: .top) {
                                if hoveredStarID == star.id {
                                    HoverLabel(text: star.name)
                                        .offset(y: -24)
                                }
                            }
                    }
                }
            }
        }
    }
}
