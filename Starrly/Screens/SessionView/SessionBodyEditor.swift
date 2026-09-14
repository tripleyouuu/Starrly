//
//  SessionBodyEditor.swift
//  Starrly
//
//  Created by Vitha Watson on 14/09/26.
//

import SwiftUI

struct SessionBodyEditor: View {
    @Binding var text: String

    var body: some View {
        TextEditor(text: $text)
            .scrollContentBackground(.hidden)
            .foregroundStyle(Color.starrlyOffWhite)
            .onChange(of: text) { _, newValue in
                text = Self.autoBullet(newValue)
            }
    }

    private static func autoBullet(_ text: String) -> String {
        guard text.hasSuffix(" ") else { return text }
        var lines = text.components(separatedBy: "\n")
        guard let lastIndex = lines.indices.last else { return text }
        if lines[lastIndex] == "- " {
            lines[lastIndex] = "• "
        }
        return lines.joined(separator: "\n")
    }
}
