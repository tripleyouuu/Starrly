//
//  NameFirstStarStep.swift
//  Starrly
//
//  Created by Vitha Watson on 14/09/26.
//

import SwiftUI

struct NameFirstStarStep: View {
    @State private var name = ""
    let onBack: () -> Void
    let onSubmit: (String) -> Void

    var body: some View {
        VStack(spacing: 40) {
            DiscoveryHeader(onBack: onBack)

            Spacer()

            VStack(spacing: 20) {
                StarView(type: .protoStar, color: .lavender)
                    .frame(width: 60, height: 60)

                Text("To start exploring, define your first star here.")
                    .foregroundStyle(Color.starrlyOffWhite)

                TextField("What skill will you start with?", text: $name)
                    .textFieldStyle(.plain)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .foregroundStyle(Color.starrlyOffWhite)
                    .glassEffect(.starrly, in: .capsule)
                    .frame(maxWidth: 400)
                    .onSubmit(submit)
            }

            Spacer()
        }
        .padding(40)
    }

    private func submit() {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        onSubmit(trimmed)
    }
}
