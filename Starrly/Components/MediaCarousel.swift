//
//  MediaCarousel.swift
//  Starrly
//
//  Created by Vitha Watson on 14/09/26.
//


import SwiftUI
import AVKit

struct MediaCarousel: View {
    let filenames: [String]
    let onRemove: (String) -> Void

    @State private var selectedFilename: String?
    @State private var playingFilename: String?

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 20) {
                Spacer(minLength: 0)

                ForEach(filenames, id: \.self) { filename in
                    itemView(for: filename)
                        .frame(height: 200)
                        .onTapGesture {
                            selectedFilename = (selectedFilename == filename) ? nil : filename
                        }
                        .overlay(alignment: .topTrailing) {
                            if selectedFilename == filename {
                                Button {
                                    onRemove(filename)
                                } label: {
                                    Image(systemName: "xmark")
                                        .foregroundStyle(Color.starrlyOffWhite)
                                }
                                .buttonStyle(.plain)
                                .padding(6)
                                .glassEffect(.starrly.interactive(), in: .circle)
                                .padding(6)
                            }
                        }
                }

                Spacer(minLength: 0)
            }
        }
    }

    @ViewBuilder
    private func itemView(for filename: String) -> some View {
        let url = MediaStorage.url(for: filename)
        if isVideo(url) {
            if playingFilename == filename {
                VideoPlayer(player: AVPlayer(url: url))
                    .aspectRatio(contentMode: .fit)
            } else {
                ZStack {
                    Color.starrlyBlue.opacity(0.2)
                    Image(systemName: "play.fill")
                        .foregroundStyle(Color.starrlyOffWhite)
                }
                .aspectRatio(1, contentMode: .fit)
                .onTapGesture {
                    playingFilename = filename
                }
            }
        } else if let image = NSImage(contentsOf: url) {
            Image(nsImage: image)
                .resizable()
                .aspectRatio(contentMode: .fit)
        }
    }

    private func isVideo(_ url: URL) -> Bool {
        ["mov", "mp4", "m4v"].contains(url.pathExtension.lowercased())
    }
}
