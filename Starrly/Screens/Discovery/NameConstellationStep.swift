//
//  NameConstellationStep.swift
//  Starrly
//
//  Created by Vitha Watson on 14/09/26.
//

import SwiftUI

struct NameConstellationStep: View {
    @State private var name = ""
    @FocusState private var isNameFocused: Bool
    let onBack: () -> Void
    let onSubmit: (String) -> Void

    var body: some View {
        ZStack {
            DiscoveryHeader(onBack: onBack)
                .frame(maxHeight: .infinity, alignment: .top)

            VStack(spacing: 20) {
                StreamingText(text: "You've found a new constellation! Give it a name.")
                    .font(.system(size: 21, weight: .semibold))
                    .foregroundStyle(Color.starrlyOffWhite)

                TextField("What are you learning?", text: $name)
                    .textFieldStyle(.plain)
                    .multilineTextAlignment(.center)
                    .font(.system(size: 27, weight: .semibold))
                    .foregroundStyle(Color.starrlyOffWhite)
                    .frame(width: 640, height: 80)
                    .glassEffect(.starrly, in: RoundedRectangle(cornerRadius: 24))
                    .focused($isNameFocused)
                    .onSubmit(submit)
            }
        }
        .padding(40)
        .onAppear {
            DispatchQueue.main.async {
                isNameFocused = true
            }
        }
    }

    private func submit() {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        onSubmit(trimmed)
    }
}
