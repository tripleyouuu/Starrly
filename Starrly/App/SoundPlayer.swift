//
//  SoundPlayer.swift
//  Starrly
//
//  Created by Vitha Watson on 16/09/26.
//

import AVFoundation
import Observation

@Observable
final class SoundPlayer {
    private let settings: AppSettings
    private var ambiencePlayer: AVAudioPlayer?
    private var oneShotPlayers: [AVAudioPlayer] = []

    private static let chimeNames = ["chime1", "chime2", "chime3"]
    private static let revealNames = ["reveal1", "reveal2", "reveal3"]

    init(settings: AppSettings) {
        self.settings = settings
    }

    func startAmbience() {
        guard ambiencePlayer == nil, let url = Bundle.main.url(forResource: "ambience", withExtension: "mp3") else { return }
        guard let player = try? AVAudioPlayer(contentsOf: url) else { return }
        player.numberOfLoops = -1
        player.volume = settings.isSoundEnabled ? 1 : 0
        player.prepareToPlay()
        player.play()
        ambiencePlayer = player
    }

   func applySoundEnabled() {
        ambiencePlayer?.volume = settings.isSoundEnabled ? 1 : 0
    }

    func playRandomChime() {
        playRandomOneShot(from: Self.chimeNames)
    }

    func playRandomReveal() {
        playRandomOneShot(from: Self.revealNames)
    }

    private func playRandomOneShot(from names: [String]) {
        guard settings.isSoundEnabled, let name = names.randomElement() else { return }
        guard let url = Bundle.main.url(forResource: name, withExtension: "mp3") else { return }
        guard let player = try? AVAudioPlayer(contentsOf: url) else { return }
        oneShotPlayers.removeAll { !$0.isPlaying }
        player.prepareToPlay()
        player.play()
        oneShotPlayers.append(player)
    }
}
