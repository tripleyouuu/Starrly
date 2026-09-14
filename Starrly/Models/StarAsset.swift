//
//  StarAsset.swift
//  Starrly
//
//  Created by Vitha Watson on 14/09/26.
//


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
}