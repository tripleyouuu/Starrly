//
//  ContentView.swift
//  Starrly
//
//  Created by Vitha Watson on 14/09/26.
//

import SwiftUI

struct ContentView: View {
    @State private var appState = AppState()

    var body: some View {
        ZStack {
            Color(Color.starrlyBackground)
                .ignoresSafeArea()

            switch appState.route {
            case .home:
                EmptyView()
            case .discovery:
                EmptyView()
            case .constellation:
                EmptyView()
            case .star:
                EmptyView()
            case .session:
                EmptyView()
            case .explore:
                EmptyView()
            }
        }
        .environment(appState)
    }
}

#Preview {
    ContentView()
}
