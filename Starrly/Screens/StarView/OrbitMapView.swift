//
//  OrbitMapView.swift
//  Starrly
//
//  Created by Vitha Watson on 14/09/26.
//

import SwiftUI

struct OrbitMapView: View {
    let star: Star
    let onSelect: (Session) -> Void

    @State private var hoveredSessionID: UUID?

    private var orderedSessions: [Session] {
        star.sessions.sorted { $0.createdAt < $1.createdAt }
    }

    private var ringCount: Int {
        max(3, orderedSessions.count)
    }

    private let ringSpacing: CGFloat = 30
    private let baseRadius: CGFloat = 40

    var body: some View {
        PannableZoomableCanvas(minScale: 1, maxScale: 2, allowsPanning: false) {
            GeometryReader { geometry in
                let center = CGPoint(x: geometry.size.width / 2, y: geometry.size.height / 2)

                ZStack {
                    ForEach(0..<ringCount, id: \.self) { index in
                        Circle()
                            .strokeBorder(Color.starrlyOffWhite.opacity(0.3), lineWidth: 1)
                            .frame(width: radius(for: index) * 2, height: radius(for: index) * 2)
                            .position(center)
                    }

                    StarView(type: star.type, color: star.color)
                        .frame(width: 32, height: 32)
                        .position(center)

                    ForEach(Array(orderedSessions.enumerated()), id: \.element.id) { index, session in
                        let angle = Double(index) * 40 * .pi / 180
                        let r = radius(for: index)
                        let point = CGPoint(
                            x: center.x + r * cos(angle),
                            y: center.y + r * sin(angle)
                        )

                        Image(session.shape.assetName)
                            .resizable()
                            .frame(width: 16, height: 16)
                            .contentShape(Rectangle())
                            .position(point)
                            .onHover { isHovering in
                                hoveredSessionID = isHovering ? session.id : nil
                            }
                            .onTapGesture {
                                onSelect(session)
                            }
                            .overlay(alignment: .top) {
                                HoverLabel(text: session.displayTitle)
                                    .offset(y: -20)
                                    .opacity(hoveredSessionID == session.id ? 1 : 0)
                            }
                    }
                }
            }
        }
    }

    private func radius(for index: Int) -> CGFloat {
        baseRadius + CGFloat(index) * ringSpacing
    }
}
