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
            TextField(Session.defaultTitle, text: $draft)
                .textFieldStyle(.plain)
                .multilineTextAlignment(.center)
                .font(.system(size: 33, weight: .bold))
                .foregroundStyle(Color.starrlyOffWhite)
                .lineLimit(1)
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
                .font(.system(size: 33, weight: .bold))
                .foregroundStyle(Color.starrlyOffWhite)
                .lineLimit(1)
                .truncationMode(.tail)
                .onTapGesture {
                    isEditing = true
                }
        }
    }

    private func commit() {
        let trimmed = draft.trimmingCharacters(in: .whitespacesAndNewlines)
        title = trimmed.isEmpty ? Session.defaultTitle : trimmed
        isEditing = false
    }
}
