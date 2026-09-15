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
}
