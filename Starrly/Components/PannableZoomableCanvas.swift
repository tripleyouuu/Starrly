//
//  PannableZoomableCanvas.swift
//  Starrly
//
//  Created by Vitha Watson on 14/09/26.
//

import SwiftUI

struct PannableZoomableCanvas<Content: View, Overlay: View>: View {
    let minScale: CGFloat
    let maxScale: CGFloat
    let allowsPanning: Bool
    let maxPanDistance: CGFloat?
    let content: (CGFloat, CGSize) -> Content
    let overlay: (CGFloat, CGSize) -> Overlay

    @State private var scale: CGFloat
    @State private var offset: CGSize = .zero
    @GestureState private var dragOffset: CGSize = .zero
    @GestureState private var gestureScale: CGFloat = 1

    init(
        minScale: CGFloat = 0.5,
        maxScale: CGFloat = 2,
        initialScale: CGFloat = 1,
        allowsPanning: Bool = true,
        maxPanDistance: CGFloat? = nil,
        @ViewBuilder content: @escaping (_ scale: CGFloat, _ offset: CGSize) -> Content,
        @ViewBuilder overlay: @escaping (_ scale: CGFloat, _ offset: CGSize) -> Overlay
    ) {
        self.minScale = minScale
        self.maxScale = maxScale
        self.allowsPanning = allowsPanning
        self.maxPanDistance = maxPanDistance
        self.content = content
        self.overlay = overlay
        _scale = State(initialValue: initialScale)
    }

    private func clamped(_ size: CGSize) -> CGSize {
        guard let maxPanDistance else { return size }
        return CGSize(
            width: min(max(size.width, -maxPanDistance), maxPanDistance),
            height: min(max(size.height, -maxPanDistance), maxPanDistance)
        )
    }

    var body: some View {
        let currentScale = scale * gestureScale
        let currentOffset = clamped(
            CGSize(width: offset.width + dragOffset.width, height: offset.height + dragOffset.height)
        )

        ZStack {
            content(currentScale, currentOffset)
                .scaleEffect(currentScale)
                .offset(currentOffset)
                .gesture(
                    DragGesture()
                        .updating($dragOffset) { value, state, _ in
                            state = value.translation
                        }
                        .onEnded { value in
                            offset = clamped(
                                CGSize(
                                    width: offset.width + value.translation.width,
                                    height: offset.height + value.translation.height
                                )
                            )
                        },
                    including: allowsPanning ? .all : .none
                )
                .gesture(
                    MagnificationGesture()
                        .updating($gestureScale) { value, state, _ in
                            state = value
                        }
                        .onEnded { value in
                            scale = min(max(scale * value, minScale), maxScale)
                        }
                )
                .clipped()

            overlay(currentScale, currentOffset)
        }
    }
}

extension PannableZoomableCanvas where Overlay == EmptyView {
    init(
        minScale: CGFloat = 0.5,
        maxScale: CGFloat = 2,
        initialScale: CGFloat = 1,
        allowsPanning: Bool = true,
        maxPanDistance: CGFloat? = nil,
        @ViewBuilder content: @escaping (_ scale: CGFloat, _ offset: CGSize) -> Content
    ) {
        self.init(
            minScale: minScale,
            maxScale: maxScale,
            initialScale: initialScale,
            allowsPanning: allowsPanning,
            maxPanDistance: maxPanDistance,
            content: content,
            overlay: { _, _ in EmptyView() }
        )
    }
}
