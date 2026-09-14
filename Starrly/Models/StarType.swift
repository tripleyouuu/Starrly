//
//  StarType.swift
//  Starrly
//
//  Created by Vitha Watson on 14/09/26.
//

enum StarType: CaseIterable {
    case protoStar
    case dwarf
    case giant
    case supernova
    case neutronStar

    static func forSessionCount(_ count: Int) -> StarType {
        switch count {
        case 0: .protoStar
        case 1: .dwarf
        case 2: .giant
        case 3: .supernova
        default: .neutronStar
        }
    }

    var label: String {
        switch self {
        case .protoStar: "Proto Star"
        case .dwarf: "Brown Dwarf"
        case .giant: "Red Giant"
        case .supernova: "Supernova"
        case .neutronStar: "Neutron Star"
        }
    }
}
