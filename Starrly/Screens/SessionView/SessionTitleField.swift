//
//  SessionTitleField.swift
//  Starrly
//
//  Created by Vitha Watson on 14/09/26.
//

import SwiftUI

struct SessionTitleField: View {
    @Binding var title: String
    @State private var isEditing = false
    @State private var draft = ""
    @FocusState private var isFocused: Bool

    var body: some View {
        if isEditing {
            TextField("New Session", text: $draft)
                .textFieldStyle(.plain)
                .multilineTextAlignment(.center)
                .font(.title2)
                .foregroundStyle(Color.starrlyOffWhite)
                .focused($isFocused)
                .onAppear {
                    draft = title
                    isFocused = true
                }
                .onSubmit(commit)
                .onChange(of: isFocused) { _, focused in
                    if !focused { commit() }
                }
        } else {
            Text(title)
                .font(.title2)
                .foregroundStyle(Color.starrlyOffWhite)
                .onTapGesture {
                    isEditing = true
                }
        }
    }

    private func commit() {
        let trimmed = draft.trimmingCharacters(in: .whitespacesAndNewlines)
        title = trimmed.isEmpty ? "New Session" : trimmed
        isEditing = false
    }
}
