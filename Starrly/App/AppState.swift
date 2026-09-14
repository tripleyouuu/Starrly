//
//  AppState.swift
//  Starrly
//
//  Created by Vitha Watson on 14/09/26.
//

import Foundation
import Observation

indirect enum Route: Hashable {
    case home
    case discovery
    case constellation(UUID, returnTo: Route)
    case star(UUID, returnTo: Route)
    case session(UUID, starReturnTo: Route)
    case explore
}

@Observable
final class AppState {
    var route: Route = .home
}
