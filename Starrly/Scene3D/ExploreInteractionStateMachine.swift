//
//  ExploreInteractionStateMachine.swift
//  Starrly
//
//  Created by Vitha Watson on 14/09/26.
//

import Foundation

enum ExploreInteractionState: Equatable {
    case idle
    case constellationName(UUID)
    case starName(UUID, constellationID: UUID)
}

enum TapTarget {
    case constellation(UUID)
    case star(UUID, constellationID: UUID)
}

enum ExploreInteractionAction {
    case none
    case navigateToConstellation(UUID)
    case navigateToStar(UUID)
}

enum ExploreInteractionStateMachine {
    static func handleTap(
        _ target: TapTarget?,
        state: ExploreInteractionState
    ) -> (ExploreInteractionState, ExploreInteractionAction) {
        switch (state, target) {
        case (.idle, .some(.constellation(let id))):
            return (.constellationName(id), .none)
        case (.idle, .some(.star(_, let constellationID))):
            return (.constellationName(constellationID), .none)
        case (.idle, nil):
            return (.idle, .none)

        case (.constellationName(let activeID), .some(.constellation(let id))) where id == activeID:
            return (.idle, .navigateToConstellation(id))
        case (.constellationName(let activeID), .some(.star(let starID, let constellationID))) where constellationID == activeID:
            return (.starName(starID, constellationID: constellationID), .none)
        case (.constellationName, _):
            return (.idle, .none)

        case (.starName(let activeStarID, let constellationID), .some(.star(let starID, let tappedConstellationID)))
            where tappedConstellationID == constellationID && starID == activeStarID:
            return (.idle, .navigateToStar(starID))
        case (.starName(_, let constellationID), .some(.star(let starID, let tappedConstellationID)))
            where tappedConstellationID == constellationID:
            return (.starName(starID, constellationID: constellationID), .none)
        case (.starName, _):
            return (.idle, .none)
        }
    }
}
