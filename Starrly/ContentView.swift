import SwiftUI

import SwiftUI

struct ContentView: View {
    @State private var appState = AppState()

    var body: some View {
        ZStack {
            Color.starrlyBackground
                .ignoresSafeArea()

            switch appState.route {
            case .home:
                HomeView()
            case .discovery:
                DiscoveryFlowView()
            case .constellation(let id, let returnTo):
                ConstellationView(constellationID: id, returnTo: returnTo)
            case .star(let id, let returnTo):
                StarDetailView(starID: id, returnTo: returnTo)
            case .session(let id, let starReturnTo):
                let _ = (id, starReturnTo)
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
