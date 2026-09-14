//
//  AppState.swift
//  Starrly
//
//  Created by Vitha Watson on 14/09/26.
//

import Foundation
import Observation

enum Route: Hashable {
    case home
    case discovery
    case constellation(UUID)
    case star(UUID)
    case session(UUID)
    case explore
}

@Observable
final class AppState {
    var route: Route = .home
}
