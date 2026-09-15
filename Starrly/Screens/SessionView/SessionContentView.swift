//
//  SessionContentView.swift
//  Starrly
//
//  Created by Vitha Watson on 14/09/26.
//


import SwiftUI
import PhotosUI
import SwiftData

struct SessionContentView: View {
    @Bindable var session: Session
    let onSave: () -> Void

    @Query private var allConstellations: [Constellation]
    @State private var photosPickerItem: PhotosPickerItem?

    var body: some View {
        ZStack {
            AmbientSkyView(constellations: allConstellations, isBlurred: true)
                .ignoresSafeArea()

            VStack(spacing: 20) {
                HStack {
                    Button(action: onSave) {
                        Image(systemName: "checkmark")
                            .foregroundStyle(Color.starrlyOffWhite)
                    }
                    .buttonStyle(.plain)
                    .padding(10)
                    .glassEffect(.starrly.interactive(), in: .circle)

                    Spacer()

                    SessionTitleField(title: $session.title)

                    Spacer()

                    PhotosPicker(selection: $photosPickerItem, matching: .any(of: [.images, .videos])) {
                        Image(systemName: "photo.on.rectangle")
                            .foregroundStyle(Color.starrlyOffWhite)
                    }
                    .buttonStyle(.plain)
                    .padding(10)
                    .glassEffect(.starrly.interactive(), in: .circle)
                }

                Text(session.createdAt.formatted(date: .abbreviated, time: .omitted))
                    .italic()
                    .foregroundStyle(Color.starrlyOffWhite)
                    .frame(maxWidth: .infinity, alignment: .leading)

                SessionBodyEditor(text: $session.body)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)

                if !session.mediaPaths.isEmpty {
                    MediaCarousel(filenames: session.mediaPaths) { filename in
                        session.mediaPaths.removeAll { $0 == filename }
                        MediaStorage.delete(filename)
                    }
                }
            }
            .padding(40)
        }
        .onChange(of: photosPickerItem) { _, newItem in
            handlePick(newItem)
        }
    }

    private func handlePick(_ item: PhotosPickerItem?) {
        guard let item else { return }
        Task {
            guard let data = try? await item.loadTransferable(type: Data.self) else { return }
            let fileExtension = item.supportedContentTypes.first?.preferredFilenameExtension ?? "dat"
            if let filename = MediaStorage.save(data, fileExtension: fileExtension) {
                session.mediaPaths.append(filename)
            }
        }
    }
}
