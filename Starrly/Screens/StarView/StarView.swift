//
//  StarView.swift
//  Starrly
//
//  Created by Vitha Watson on 14/09/26.
//


import SwiftUI

struct StarView: View {
    let type: StarType
    let color: StarColor

    var body: some View {
        ZStack {
            ForEach(StarAsset.layers(for: type), id: \.self) { layer in
                Image(layer)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .colorMultiply(color.color)
                    .scaleEffect(StarAsset.relativeScale(for: layer))
            }
        }
    }
}