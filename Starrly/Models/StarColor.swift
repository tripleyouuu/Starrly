//
//  StarColor.swift
//  Starrly
//
//  Created by Vitha Watson on 14/09/26.
//


import SwiftUI

enum StarColor: Int, Codable, CaseIterable {
    case lavender
    case pink
    case warmGray
    case cream
    case skyBlue

    var color: Color {
        switch self {
        case .lavender: return Color(hex: 0xEBE7FE)
        case .pink: return Color(hex: 0xFEF7FE)
        case .warmGray: return Color(hex: 0xEBEBEB)
        case .cream: return Color(hex: 0xFEFAE7)
        case .skyBlue: return Color(hex: 0xE7F6FE)
        }
    }
}
