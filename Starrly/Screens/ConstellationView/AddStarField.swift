//
//  AddStarField.swift
//  Starrly
//
//  Created by Vitha Watson on 14/09/26.
//

import SwiftUI

struct AddStarField: View {
    @State private var name = ""
    @FocusState private var isFocused: Bool
    let onSubmit: (String) -> Void

    var body: some View {
        HStack(spacing: 10) {
            Text("Add Star…")
                .foregroundStyle(Color.starrlyOffWhite)

            TextField("Skill Name", text: $name)
                .textFieldStyle(.plain)
                .foregroundStyle(Color.starrlyOffWhite)
                .focused($isFocused)
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
                .glassEffect(.starrly, in: .capsule)
                .onSubmit(submit)

            Button(action: submit) {
                Image(systemName: "checkmark")
                    .foregroundStyle(Color.starrlyOffWhite)
            }
            .buttonStyle(.plain)
            .padding(10)
            .glassEffect(.starrly.interactive(), in: .circle)
        }
        .onAppear { isFocused = true }
    }

    private func submit() {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        onSubmit(trimmed)
        name = ""
        isFocused = true
    }
}
