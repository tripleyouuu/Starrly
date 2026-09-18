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
        HStack(spacing: 20) {
            Text("Add Star…")
                .font(.system(size: 27, weight: .semibold))
                .foregroundStyle(Color.starrlyOffWhite)

            TextField("Skill Name", text: $name)
                .textFieldStyle(.plain)
                .font(.system(size: 27, weight: .semibold))
                .foregroundStyle(Color.starrlyOffWhite)
                .focused($isFocused)
                .padding(.horizontal, 24)
                .frame(maxWidth: 560, maxHeight: 80)
                .glassEffect(.starrly, in: RoundedRectangle(cornerRadius: 24))
                .onSubmit(submit)

            Button(action: submit) {
                Image(systemName: "checkmark")
                    .font(.system(size: 19, weight: .regular))
                    .foregroundStyle(Color.starrlyOffWhite)
                    .frame(width: 48, height: 48)
                    .contentShape(Circle())
            }
            .buttonStyle(.plain)
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
