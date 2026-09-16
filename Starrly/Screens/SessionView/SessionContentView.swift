//
//  SessionContentView.swift
//  Starrly
//
//  Created by Vitha Watson on 14/09/26.
//


import SwiftUI
import PhotosUI
import SwiftData
import UniformTypeIdentifiers
import TipKit

struct SessionContentView: View {
    @Bindable var session: Session
    let onSave: () -> Void

    @Query private var allConstellations: [Constellation]
    @State private var photosPickerItems: [PhotosPickerItem] = []
    @State private var pendingMediaCount = 0

    var body: some View {
        ZStack {
            AmbientSkyView(constellations: allConstellations, isBlurred: true)
                .ignoresSafeArea()

            GeometryReader { geometry in
                let carouselHeight = max(160, min(360, geometry.size.height * 0.4))

            VStack(spacing: 32) {
                HStack {
                    Button(action: onSave) {
                        Image(systemName: "checkmark")
                            .font(.system(size: 19, weight: .regular))
                            .foregroundStyle(Color.starrlyOffWhite)
                            .frame(width: 48, height: 48)
                            .contentShape(Circle())
                    }
                    .buttonStyle(.plain)
                    .glassEffect(.starrly.interactive(), in: .circle)

                    Spacer()

                    SessionTitleField(title: $session.title)
                        .popoverTip(SessionTitleTip(), arrowEdge: .bottom)

                    Spacer()

                    PhotosPicker(selection: $photosPickerItems, matching: .any(of: [.images, .videos])) {
                        Image(systemName: "photo.on.rectangle")
                            .font(.system(size: 19, weight: .regular))
                            .foregroundStyle(Color.starrlyOffWhite)
                            .frame(width: 48, height: 48)
                            .contentShape(Circle())
                    }
                    .buttonStyle(.plain)
                    .glassEffect(.starrly.interactive(), in: .circle)
                }

                Text(session.createdAt.formatted(date: .abbreviated, time: .omitted))
                    .font(.system(size: 13))
                    .italic()
                    .foregroundStyle(Color.starrlyOffWhite)
                    .frame(maxWidth: .infinity, alignment: .leading)

                if pendingMediaCount > 0 {
                    HStack(spacing: 10) {
                        ProgressView()
                            .controlSize(.small)
                        Text(pendingMediaCount == 1 ? "Adding media…" : "Adding \(pendingMediaCount) items…")
                            .font(.system(size: 15))
                            .foregroundStyle(Color.starrlyOffWhite)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }

                if !session.mediaPaths.isEmpty {
                    MediaCarousel(filenames: session.mediaPaths, height: carouselHeight) { filename in
                        session.mediaPaths.removeAll { $0 == filename }
                        MediaStorage.delete(filename)
                    }
                }

                SessionBodyEditor(text: $session.body)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .onPasteCommand(of: [.fileURL, .image, .movie], perform: handleProviders)
                    .onDrop(of: [.fileURL, .image, .movie], isTargeted: nil) { providers in
                        handleProviders(providers)
                        return true
                    }
            }
            .padding(40)
            }
        }
        .onChange(of: photosPickerItems) { _, newItems in
            handlePick(newItems)
        }
        .onPasteCommand(of: [.fileURL, .image, .movie], perform: handleProviders)
        .onDrop(of: [.fileURL, .image, .movie], isTargeted: nil) { providers in
            handleProviders(providers)
            return true
        }
    }

    private func handleProviders(_ providers: [NSItemProvider]) {
        for provider in providers {
            pendingMediaCount += 1

            if provider.canLoadObject(ofClass: URL.self) {
                _ = provider.loadObject(ofClass: URL.self) { url, _ in
                    Task { @MainActor in
                        defer { pendingMediaCount -= 1 }
                        guard let url, let data = try? Data(contentsOf: url) else { return }
                        let fileExtension = url.pathExtension.isEmpty ? "dat" : url.pathExtension
                        await addMedia(data: data, fileExtension: fileExtension)
                    }
                }
            } else if provider.hasItemConformingToTypeIdentifier(UTType.movie.identifier) {
                provider.loadDataRepresentation(forTypeIdentifier: UTType.movie.identifier) { data, _ in
                    Task { @MainActor in
                        defer { pendingMediaCount -= 1 }
                        guard let data else { return }
                        await addMedia(data: data, fileExtension: "mov")
                    }
                }
            } else if provider.hasItemConformingToTypeIdentifier(UTType.image.identifier) {
                provider.loadDataRepresentation(forTypeIdentifier: UTType.image.identifier) { data, _ in
                    Task { @MainActor in
                        defer { pendingMediaCount -= 1 }
                        guard let data else { return }
                        await addMedia(data: data, fileExtension: "png")
                    }
                }
            } else {
                pendingMediaCount -= 1
            }
        }
    }

    private func addMedia(data: Data, fileExtension: String) async {
        let (finalData, finalExtension) = await MediaCompressor.process(data, fileExtension: fileExtension)
        if let filename = MediaStorage.save(finalData, fileExtension: finalExtension) {
            session.mediaPaths.append(filename)
        }
    }

    private func handlePick(_ items: [PhotosPickerItem]) {
        guard !items.isEmpty else { return }
        photosPickerItems = []
        pendingMediaCount += items.count
        Task {
            let filenames = await withTaskGroup(of: (Int, String?).self) { group in
                for (index, item) in items.enumerated() {
                    group.addTask {
                        guard let data = try? await item.loadTransferable(type: Data.self) else {
                            return (index, nil)
                        }
                        let fileExtension = item.supportedContentTypes.first?.preferredFilenameExtension ?? "dat"
                        let (finalData, finalExtension) = await MediaCompressor.process(data, fileExtension: fileExtension)
                        return (index, MediaStorage.save(finalData, fileExtension: finalExtension))
                    }
                }
                var results: [(Int, String)] = []
                for await (index, filename) in group {
                    if let filename {
                        results.append((index, filename))
                    }
                }
                return results.sorted { $0.0 < $1.0 }.map(\.1)
            }
            session.mediaPaths.append(contentsOf: filenames)
            pendingMediaCount -= items.count
        }
    }
}
