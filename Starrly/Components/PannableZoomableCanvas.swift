//
//  PannableZoomableCanvas.swift
//  Starrly
//
//  Created by Vitha Watson on 14/09/26.
//

import SwiftUI

struct PannableZoomableCanvas<Content: View>: View {
    let minScale: CGFloat
    let maxScale: CGFloat
    let allowsPanning: Bool
    let content: Content

    @State private var scale: CGFloat = 1
    @State private var offset: CGSize = .zero
    @GestureState private var dragOffset: CGSize = .zero
    @GestureState private var gestureScale: CGFloat = 1

    init(minScale: CGFloat = 0.5, maxScale: CGFloat = 2, allowsPanning: Bool = true, @ViewBuilder content: () -> Content) {
        self.minScale = minScale
        self.maxScale = maxScale
        self.allowsPanning = allowsPanning
        self.content = content()
    }

    var body: some View {
        content
            .scaleEffect(scale * gestureScale)
            .offset(x: offset.width + dragOffset.width, y: offset.height + dragOffset.height)
            .gesture(
                DragGesture()
                    .updating($dragOffset) { value, state, _ in
                        state = value.translation
                    }
                    .onEnded { value in
                        offset.width += value.translation.width
                        offset.height += value.translation.height
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
    }
}
