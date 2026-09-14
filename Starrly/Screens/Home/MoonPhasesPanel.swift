//
//  MoonPhasesPanel.swift
//  Starrly
//
//  Created by Vitha Watson on 14/09/26.
//

import SwiftUI

struct MoonPhasePanel: View {
    var body: some View {
        ZStack {
            Image("Moon")
                .resizable()
                .aspectRatio(contentMode: .fit)

            MoonPhaseMask(phase: MoonPhaseCalculator.currentPhase())
        }
        .clipShape(.circle)
    }
}
