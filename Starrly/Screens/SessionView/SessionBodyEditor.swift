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
            .font(.system(size: 19))
            .foregroundStyle(Color.starrlyOffWhite)
            .onChange(of: text) { _, newValue in
                text = Self.autoBullet(newValue)
            }
    }

    private static func autoBullet(_ text: String) -> String {
        if text.hasSuffix(" ") {
            var lines = text.components(separatedBy: "\n")
            if let lastIndex = lines.indices.last, lines[lastIndex] == "- " {
                lines[lastIndex] = "• "
                return lines.joined(separator: "\n")
            }
        }

        if text.hasSuffix("\n") {
            var lines = text.components(separatedBy: "\n")
            let previousIndex = lines.count - 2
            guard lines.indices.contains(previousIndex) else { return text }
            let previousLine = lines[previousIndex]

            if previousLine == "• " {
                lines[previousIndex] = ""
                return lines.joined(separator: "\n")
            } else if previousLine.hasPrefix("• "), !previousLine.dropFirst(2).isEmpty {
                lines[lines.count - 1] = "• "
                return lines.joined(separator: "\n")
            }
        }

        return text
    }
}
