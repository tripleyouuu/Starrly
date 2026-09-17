//
//  OrbitMapView.swift
//  Starrly
//
//  Created by Vitha Watson on 14/09/26.
//

import SwiftUI

private struct AnnulusHitShape: Shape {
    let radius: CGFloat
    let bandWidth: CGFloat

    func path(in rect: CGRect) -> Path {
        let center = CGPoint(x: rect.midX, y: rect.midY)
        var path = Path()
        path.addArc(center: center, radius: radius + bandWidth / 2, startAngle: .degrees(0), endAngle: .degrees(360), clockwise: false)
        path.addArc(center: center, radius: max(0, radius - bandWidth / 2), startAngle: .degrees(0), endAngle: .degrees(360), clockwise: true)
        return path
    }
}

struct OrbitMapView: View {
    let star: Star
    let onSelect: (Session) -> Void

    @State private var startDate = Date()
    @State private var selectedSessionID: UUID?
    @State private var pauseStartElapsed: Double?
    @State private var pausedDurations: [UUID: Double] = [:]

    private var orderedSessions: [Session] {
        star.sessions.sorted { $0.createdAt < $1.createdAt }
    }

    private var ringCount: Int {
        max(4, orderedSessions.count)
    }

    private let ringSpacing: CGFloat = 45
    private let baseRadius: CGFloat = 60
    private let baseAngularSpeed: Double = 8
    private let angularSpeedPerRing: Double = 4
    private let ringHitBandWidth: CGFloat = 32
    private let planetSize: CGFloat = 64

    var body: some View {
        PannableZoomableCanvas(minScale: 0.5, maxScale: 3.5, initialScale: 1.5, allowsPanning: false) { scale, offset in
            GeometryReader { geometry in
                let center = CGPoint(x: geometry.size.width / 2, y: geometry.size.height / 2)

                TimelineView(.animation) { timeline in
                    let elapsed = timeline.date.timeIntervalSince(startDate)

                    ZStack {
                        ForEach(0..<ringCount, id: \.self) { index in
                            let r = radius(for: index)
                            let hitSize = r * 2 + ringHitBandWidth
                            let isReachable = isWithinViewport(
                                worldPoint: center,
                                elementRadius: r + ringHitBandWidth / 2,
                                scale: scale,
                                offset: offset,
                                center: center,
                                geometrySize: geometry.size
                            )

                            Circle()
                                .strokeBorder(Color.starrlyOffWhite.opacity(0.3), lineWidth: 1)
                                .frame(width: r * 2, height: r * 2)
                                .position(center)

                            if isReachable {
                                Color.clear
                                    .frame(width: hitSize, height: hitSize)
                                    .contentShape(AnnulusHitShape(radius: r, bandWidth: ringHitBandWidth))
                                    .position(center)
                                    .onTapGesture {
                                        guard index < orderedSessions.count else { return }
                                        select(orderedSessions[index])
                                    }
                            }
                        }

                        StarView(type: star.type, color: star.color)
                            .frame(width: 24, height: 24)
                            .position(center)

                        ForEach(Array(orderedSessions.enumerated()), id: \.element.id) { index, session in
                            let point = position(for: index, session: session, center: center, globalElapsed: elapsed)
                            let isReachable = isWithinViewport(
                                worldPoint: point,
                                elementRadius: (planetSize + 16) / 2,
                                scale: scale,
                                offset: offset,
                                center: center,
                                geometrySize: geometry.size
                            )

                            Image(session.shape.assetName)
                                .resizable()
                                .frame(width: planetSize, height: planetSize)
                                .position(point)

                            if isReachable {
                                Color.clear
                                    .frame(width: planetSize + 16, height: planetSize + 16)
                                    .contentShape(Circle())
                                    .position(point)
                                    .onTapGesture {
                                        select(session)
                                    }
                            }
                        }
                    }
                }
            }
        } overlay: { scale, offset in
            GeometryReader { geometry in
                let center = CGPoint(x: geometry.size.width / 2, y: geometry.size.height / 2)

                if let selectedSessionID,
                   let index = orderedSessions.firstIndex(where: { $0.id == selectedSessionID }) {
                    let session = orderedSessions[index]
                    let worldPoint = position(
                        for: index,
                        session: session,
                        center: center,
                        globalElapsed: Date().timeIntervalSince(startDate)
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
                            Text(session.displayTitle)
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
                            onSelect(session)
                        }
                    }
                }
            }
            .clipped()
        }
        .contentShape(Rectangle())
        .onTapGesture {
            deselect()
        }
    }

    private func radius(for index: Int) -> CGFloat {
        baseRadius + CGFloat(index) * ringSpacing
    }

    private func angularSpeed(for index: Int) -> Double {
        baseAngularSpeed + Double(index) * angularSpeedPerRing
    }

    private func position(for index: Int, session: Session, center: CGPoint, globalElapsed: Double) -> CGPoint {
        let elapsed = effectiveElapsed(for: session.id, globalElapsed: globalElapsed)
        let angleDegrees = Double(index) * 40 + angularSpeed(for: index) * elapsed
        let angle = angleDegrees * .pi / 180
        let r = radius(for: index)
        return CGPoint(x: center.x + r * cos(angle), y: center.y + r * sin(angle))
    }

    private func effectiveElapsed(for sessionID: UUID, globalElapsed: Double) -> Double {
        var paused = pausedDurations[sessionID] ?? 0
        if selectedSessionID == sessionID, let pauseStartElapsed {
            paused += max(0, globalElapsed - pauseStartElapsed)
        }
        return max(0, globalElapsed - paused)
    }

    private func select(_ session: Session) {
        if selectedSessionID == session.id { return }
        let now = Date().timeIntervalSince(startDate)
        if let previousID = selectedSessionID, let pauseStartElapsed {
            pausedDurations[previousID, default: 0] += max(0, now - pauseStartElapsed)
        }
        selectedSessionID = session.id
        pauseStartElapsed = now
    }

    private func deselect() {
        let now = Date().timeIntervalSince(startDate)
        if let previousID = selectedSessionID, let pauseStartElapsed {
            pausedDurations[previousID, default: 0] += max(0, now - pauseStartElapsed)
        }
        selectedSessionID = nil
        pauseStartElapsed = nil
    }
}
