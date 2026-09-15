//
//  ViewportReachability.swift
//  Starrly
//
//  Created by Vitha Watson on 14/09/26.
//

import CoreGraphics

func isWithinViewport(
    worldPoint: CGPoint,
    elementRadius: CGFloat,
    scale: CGFloat,
    offset: CGSize,
    center: CGPoint,
    geometrySize: CGSize
) -> Bool {
    let screenX = center.x + (worldPoint.x - center.x) * scale + offset.width
    let screenY = center.y + (worldPoint.y - center.y) * scale + offset.height
    return screenX - elementRadius >= 0
        && screenX + elementRadius <= geometrySize.width
        && screenY - elementRadius >= 0
        && screenY + elementRadius <= geometrySize.height
}
