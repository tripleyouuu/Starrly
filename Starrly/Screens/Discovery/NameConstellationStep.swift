//
//  NameConstellationStep.swift
//  Starrly
//
//  Created by Vitha Watson on 14/09/26.
//

import SwiftUI

struct NameConstellationStep: View {
    @State private var name = ""
    let onBack: () -> Void
    let onSubmit: (String) -> Void

    var body: some View {
        VStack(spacing: 40) {
            DiscoveryHeader(onBack: onBack)

            Spacer()

            VStack(spacing: 20) {
                Text("You've found a new constellation! Give it a name.")
                    .foregroundStyle(Color.starrlyOffWhite)

                TextField("What are you learning?", text: $name)
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
