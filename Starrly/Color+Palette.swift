//
//  Color+Palette.swift
//  Starrly
//
//  Created by Vitha Watson on 14/09/26.
//


import SwiftUI

extension Color {
    init(hex: UInt32) {
        let r = Double((hex >> 16) & 0xFF) / 255
        let g = Double((hex >> 8) & 0xFF) / 255
        let b = Double(hex & 0xFF) / 255
        self.init(red: r, green: g, blue: b)
    }

    static let starrlyBackground = Color(hex: 0x010318)
    static let starrlyBlue = Color(hex: 0x3453B2)
    static let starrlyOffWhite = Color(hex: 0xF2F2F3)
}
