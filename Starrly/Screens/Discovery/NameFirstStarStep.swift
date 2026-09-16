//
//  NameFirstStarStep.swift
//  Starrly
//
//  Created by Vitha Watson on 14/09/26.
//

import SwiftUI

struct NameFirstStarStep: View {
    @State private var name = ""
    @State private var starColor: StarColor = .lavender
    @FocusState private var isNameFocused: Bool
    let onBack: () -> Void
    let onSubmit: (String) -> Void

    var body: some View {
        ZStack {
            DiscoveryHeader(onBack: onBack)
                .frame(maxHeight: .infinity, alignment: .top)

            VStack(spacing: 20) {
                StreamingText(text: "To start exploring, define your first star here.")
                    .font(.system(size: 21, weight: .semibold))
                    .foregroundStyle(Color.starrlyOffWhite)

                TextField("What skill will you start with?", text: $name)
                    .textFieldStyle(.plain)
                    .multilineTextAlignment(.center)
                    .font(.system(size: 27, weight: .semibold))
                    .foregroundStyle(Color.starrlyOffWhite)
                    .frame(width: 640, height: 80)
                    .glassEffect(.starrly, in: RoundedRectangle(cornerRadius: 24))
                    .focused($isNameFocused)
                    .onSubmit(submit)
            }
            .overlay(alignment: .top) {
                StarView(type: .protoStar, color: starColor)
                    .frame(width: 60, height: 60)
                    .animation(.easeInOut(duration: 1.2), value: starColor)
                    .offset(y: -84)
            }
        }
        .padding(40)
        .onAppear {
            DispatchQueue.main.async {
                isNameFocused = true
            }
        }
        .task {
            await cycleStarColors()
        }
    }

    private func cycleStarColors() async {
        let colors = StarColor.allCases
        var index = 0
        while !Task.isCancelled {
            try? await Task.sleep(nanoseconds: 1_500_000_000)
            index = (index + 1) % colors.count
            starColor = colors[index]
        }
    }

    private func submit() {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        onSubmit(trimmed)
    }
}
