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
        case .lavender: Color(hex: 0xEBE7FE)
        case .pink: Color(hex: 0xFEE7FE)
        case .warmGray: Color(hex: 0xEBE7EB)
        case .cream: Color(hex: 0xFEFAE7)
        case .skyBlue: Color(hex: 0xE7F6FE)
        }
    }
}