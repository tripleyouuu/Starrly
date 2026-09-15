//
//  ScreenProjector.swift
//  Starrly
//
//  Created by Vitha Watson on 15/09/26.
//

import CoreGraphics
import simd


enum ScreenProjector {
    struct Projected {
        let point: CGPoint
        let isInFrontOfCamera: Bool
    }

    private static func localDirection(
        worldPosition: SIMD3<Float>,
        cameraYaw: Double,
        cameraPitch: Double
    ) -> SIMD3<Float> {
        let yawRotation = simd_quatf(angle: Float(cameraYaw * .pi / 180), axis: [0, 1, 0])
        let pitchRotation = simd_quatf(angle: Float(cameraPitch * .pi / 180), axis: [1, 0, 0])
        let cameraOrientation = yawRotation * pitchRotation
        return simd_act(cameraOrientation.inverse, normalize(worldPosition))
    }

    static func project(
        worldPosition: SIMD3<Float>,
        cameraYaw: Double,
        cameraPitch: Double,
        verticalFOVDegrees: Double,
        viewportSize: CGSize
    ) -> Projected {
        let direction = localDirection(worldPosition: worldPosition, cameraYaw: cameraYaw, cameraPitch: cameraPitch)
        let isInFront = direction.z < 0

        let vFOV = verticalFOVDegrees * .pi / 180
        let aspect = Double(viewportSize.width / max(viewportSize.height, 1))
        let hFOV = 2 * atan(tan(vFOV / 2) * aspect)

        let horizontalAngle = atan2(Double(direction.x), Double(-direction.z))
        let verticalAngle = atan2(Double(direction.y), Double(-direction.z))

        let screenX = viewportSize.width / 2 + CGFloat(tan(horizontalAngle) / tan(hFOV / 2)) * (viewportSize.width / 2)
        let screenY = viewportSize.height / 2 - CGFloat(tan(verticalAngle) / tan(vFOV / 2)) * (viewportSize.height / 2)

        return Projected(point: CGPoint(x: screenX, y: screenY), isInFrontOfCamera: isInFront)
    }

    static func isWithinFrustum(
        worldPosition: SIMD3<Float>,
        cameraYaw: Double,
        cameraPitch: Double,
        verticalFOVDegrees: Double,
        aspect: Double,
        margin: Double = 0.9
    ) -> Bool {
        let direction = localDirection(worldPosition: worldPosition, cameraYaw: cameraYaw, cameraPitch: cameraPitch)
        guard direction.z < 0 else { return false }

        let vFOV = verticalFOVDegrees * .pi / 180
        let hFOV = 2 * atan(tan(vFOV / 2) * aspect)

        let horizontalAngle = atan2(Double(direction.x), Double(-direction.z))
        let verticalAngle = atan2(Double(direction.y), Double(-direction.z))

        return abs(horizontalAngle) < (hFOV / 2) * margin && abs(verticalAngle) < (vFOV / 2) * margin
    }
}
