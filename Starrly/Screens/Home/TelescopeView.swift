//
//  TelescopeView.swift
//  Starrly
//
//  Created by Vitha Watson on 14/09/26.
//

import SwiftUI

struct TelescopeView: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image("Telescope")
                .resizable()
                .aspectRatio(contentMode: .fit)
        }
        .buttonStyle(.plain)
    }
}
