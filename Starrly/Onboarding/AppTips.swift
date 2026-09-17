//
//  AppTips.swift
//  Starrly
//
//  Created by Vitha Watson on 16/09/26.
//

import SwiftUI
import TipKit

private let tipTitleFont = Font.system(size: 21, weight: .semibold)
private let tipMessageFont = Font.system(size: 19, weight: .regular)

struct TelescopeTip: Tip {
    var title: Text { Text("Hello, there!").font(tipTitleFont) }
    var message: Text? { Text("Use the telescope, or click here, to \"discover\" your first learning journey.").font(tipMessageFont) }
    var options: [Option] { [Tips.MaxDisplayCount(1)] }
}

struct ConstellationMapTip: Tip {
    static let dismissedEvent = Tips.Event(id: "constellation-map-tip-dismissed")

    var title: Text { Text("Your Constellation Map").font(tipTitleFont) }
    var message: Text? {
        Text("This is where you'll watch your constellation grow as you find more stars, aka skills to learn on this journey! Use your trackpad to zoom and pan around, and click on stars to reveal their name and navigate to the skill.")
            .font(tipMessageFont)
    }
    var options: [Option] { [Tips.MaxDisplayCount(1)] }
}

struct MemberStarsTip: Tip {
    var title: Text { Text("Member Stars").font(tipTitleFont) }
    var message: Text? {
        Text("You can add as many stars as you want, but they won't connect till you actually practice those skills.")
            .font(tipMessageFont)
    }
    var rules: [Rule] {
        #Rule(ConstellationMapTip.dismissedEvent) { $0.donations.count > 0 }
    }
    var options: [Option] { [Tips.MaxDisplayCount(1)] }
}

struct StarMapTip: Tip {
    static let dismissedEvent = Tips.Event(id: "star-map-tip-dismissed")

    var title: Text { Text("Your Star's Orbit").font(tipTitleFont) }
    var message: Text? {
        Text("This is where you'll watch your star grow through its lifecycle and glow brighter as you practice its skill! Use your trackpad to zoom in, and click on the planets/orbits to reveal their name and navigate to the session.")
            .font(tipMessageFont)
    }
    var options: [Option] { [Tips.MaxDisplayCount(1)] }
}

struct RecordSessionTip: Tip {
    var title: Text { Text("Record Your Progress").font(tipTitleFont) }
    var message: Text? {
        Text("When you've spent some time practicing this skill, record your progress with a journal entry, or upload photos and videos of your learnings.")
            .font(tipMessageFont)
    }
    var rules: [Rule] {
        #Rule(StarMapTip.dismissedEvent) { $0.donations.count > 0 }
    }
    var options: [Option] { [Tips.MaxDisplayCount(1)] }
}

struct SessionTitleTip: Tip {
    var title: Text { Text("Session Title").font(tipTitleFont) }
    var message: Text? {
        Text("You can change the session name for your reference, or leave it as it is to save it as today's date.")
            .font(tipMessageFont)
    }
    var options: [Option] { [Tips.MaxDisplayCount(1)] }
}

struct ExploreCapsuleTip: Tip {
    var title: Text { Text("Your Night Sky").font(tipTitleFont) }
    var message: Text? {
        Text("Welcome to your own personal night sky! As you discover more learning journeys, learn new skills, and most importantly, practice, this sky will light up. Pan around this interface and click on constellation names to navigate to them. Happy learning!")
            .font(tipMessageFont)
    }
    var options: [Option] { [Tips.MaxDisplayCount(1)] }
}
