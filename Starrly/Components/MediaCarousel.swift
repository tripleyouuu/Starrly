//
//  MediaCarousel.swift
//  Starrly
//
//  Created by Vitha Watson on 14/09/26.
//


import SwiftUI
import AVKit

private let carouselHeight: CGFloat = 360
private let fallbackAspectRatio: CGFloat = 16.0 / 9.0

struct MediaCarousel: View {
    let filenames: [String]
    let onRemove: (String) -> Void

    @State private var selectedFilename: String?
    @State private var playingFilename: String?
    @State private var activePlayer: AVPlayer?
    @State private var thumbnails: [String: NSImage] = [:]
    @State private var aspectRatios: [String: CGFloat] = [:]

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 20) {
                Spacer(minLength: 0)

                ForEach(filenames, id: \.self) { filename in
                    itemView(for: filename)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            handleTap(on: filename)
                        }
                        .overlay(alignment: .topTrailing) {
                            if selectedFilename == filename {
                                Button {
                                    remove(filename)
                                } label: {
                                    Image(systemName: "xmark")
                                        .foregroundStyle(Color.starrlyOffWhite)
                                        .frame(width: 32, height: 32)
                                        .contentShape(Circle())
                                }
                                .buttonStyle(.plain)
                                .glassEffect(.starrly.interactive(), in: .circle)
                                .padding(6)
                            }
                        }
                }

                Spacer(minLength: 0)
            }
        }
        .frame(height: carouselHeight)
    }

    @ViewBuilder
    private func itemView(for filename: String) -> some View {
        let url = MediaStorage.url(for: filename)
        if isVideo(url) {
            let width = carouselHeight * (aspectRatios[filename] ?? fallbackAspectRatio)

            if playingFilename == filename, let activePlayer {
                VideoPlayer(player: activePlayer)
                    .frame(width: width, height: carouselHeight)
                    .clipped()
            } else {
                ZStack {
                    if let thumbnail = thumbnails[filename] {
                        Image(nsImage: thumbnail)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: width, height: carouselHeight)
                            .clipped()
                    } else {
                        Color.starrlyBlue.opacity(0.2)
                            .frame(width: width, height: carouselHeight)
                    }

                    Image(systemName: "play.fill")
                        .font(.system(size: 28))
                        .foregroundStyle(Color.starrlyOffWhite)
                        .padding(22)
                        .background(Circle().fill(Color.black.opacity(0.4)))
                }
                .frame(width: width, height: carouselHeight)
                .task(id: filename) {
                    guard thumbnails[filename] == nil else { return }
                    let info = await Self.loadVideoInfo(for: url)
                    if let thumbnail = info.thumbnail {
                        thumbnails[filename] = thumbnail
                    }
                    aspectRatios[filename] = info.aspectRatio
                }
            }
        } else if let image = NSImage(contentsOf: url) {
            Image(nsImage: image)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(height: carouselHeight)
        }
    }

    private func handleTap(on filename: String) {
        let url = MediaStorage.url(for: filename)
        if isVideo(url), playingFilename != filename {
            activePlayer = AVPlayer(url: url)
            playingFilename = filename
            activePlayer?.play()
        }
        selectedFilename = (selectedFilename == filename) ? nil : filename
    }

    private func remove(_ filename: String) {
        if playingFilename == filename {
            activePlayer?.pause()
            activePlayer = nil
            playingFilename = nil
        }
        if selectedFilename == filename {
            selectedFilename = nil
        }
        thumbnails[filename] = nil
        aspectRatios[filename] = nil
        onRemove(filename)
    }

    private func isVideo(_ url: URL) -> Bool {
        ["mov", "mp4", "m4v"].contains(url.pathExtension.lowercased())
    }

    private static func loadVideoInfo(for url: URL) async -> (thumbnail: NSImage?, aspectRatio: CGFloat) {
        let asset = AVURLAsset(url: url)

        var aspectRatio = fallbackAspectRatio
        if let track = try? await asset.loadTracks(withMediaType: .video).first,
           let naturalSize = try? await track.load(.naturalSize),
           let transform = try? await track.load(.preferredTransform) {
            let size = naturalSize.applying(transform)
            let width = abs(size.width)
            let height = abs(size.height)
            if height > 0 {
                aspectRatio = width / height
            }
        }

        let generator = AVAssetImageGenerator(asset: asset)
        generator.appliesPreferredTrackTransform = true
        let thumbnail = (try? await generator.image(at: .zero).image).map { NSImage(cgImage: $0, size: .zero) }

        return (thumbnail, aspectRatio)
    }
}
