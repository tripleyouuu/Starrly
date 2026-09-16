//
//  StarMotionSpec.swift
//  Starrly
//
//  Created by Vitha Watson on 16/09/26.
//

import CoreGraphics
import Foundation

enum StarMotionSpec {
    static let pulseGrowScale: CGFloat = 1.35
    static let pulseDuration: TimeInterval = 4.0
    static let rotationDuration: TimeInterval = 8.0
    static let haloShrinkScale: CGFloat = 0.745

    static let twinkleShadowRadius: CGFloat = 25
    static let twinkleDurationRange: ClosedRange<Double> = 1.4...3.0
    static let twinkleDelayRange: ClosedRange<Double> = 0...2.5

    static func layerPulses(type: StarType, layer: String) -> Bool {
        switch type {
        case .dwarf, .supernova: return true
        case .neutronStar: return layer == "NeutronStarBeams"
        default: return false
        }
    }

    static func layerRotates(type: StarType, layer: String) -> Bool {
        switch type {
        case .giant, .supernova: return true
        case .neutronStar: return layer == "NeutronStarBeams"
        default: return false
        }
    }

    static func layerShrinks(type: StarType, layer: String) -> Bool {
        type == .neutronStar && layer == "NeutronStarHalo"
    }

    static func pulsesAnyLayer(_ type: StarType) -> Bool {
        StarAsset.layers(for: type).contains { layerPulses(type: type, layer: $0) }
    }

    static func rotatesAnyLayer(_ type: StarType) -> Bool {
        StarAsset.layers(for: type).contains { layerRotates(type: type, layer: $0) }
    }

    static func shrinksAnyLayer(_ type: StarType) -> Bool {
        StarAsset.layers(for: type).contains { layerShrinks(type: type, layer: $0) }
    }

    static func twinkleIntensity(for type: StarType) -> CGFloat {
        switch type {
        case .protoStar: return 0.05
        case .dwarf: return 0.10
        case .giant: return 0.15
        case .supernova: return 0.20
        case .neutronStar: return 0.25
        }
    }
}
