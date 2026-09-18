//
//  StarAsset.swift
//  Starrly
//
//  Created by Vitha Watson on 14/09/26.
//

import CoreGraphics

enum StarAsset {
    static func layers(for type: StarType) -> [String] {
        switch type {
        case .protoStar: ["ProtoStar"]
        case .dwarf: ["DwarfStar"]
        case .giant: ["GiantStar"]
        case .supernova: ["SupernovaStar"]
        case .neutronStar: ["NeutronStarBase", "NeutronStarBeams", "NeutronStarHalo"]
        }
    }
    
    static func relativeScale(for layer: String) -> CGFloat {
        switch layer {
        case "NeutronStarBeams": 3.2
        case "NeutronStarHalo": 1.9
        default: 1
        }
    }

    /// A gradual overall size increase as a star progresses through its lifecycle, so a neutron
    /// star reads as visibly more grown than a proto star even before animation is factored in.
    static func sizeMultiplier(for type: StarType) -> CGFloat {
        switch type {
        case .protoStar: 1.0
        case .dwarf: 1.1
        case .giant: 1.2
        case .supernova: 1.3
        case .neutronStar: 1.4
        }
    }
}
