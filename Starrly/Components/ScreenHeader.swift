//
//  ScreenHeader.swift
//  Starrly
//
//  Created by Vitha Watson on 16/09/26.
//

import SwiftUI

struct ScreenHeader: View {
    let title: String
    let onBack: () -> Void

    var body: some View {
        ZStack {
            HStack {
                BackButton(action: onBack)
                Spacer()
            }

            Text(title)
                .font(.system(size: 33, weight: .bold))
                .foregroundStyle(Color.starrlyOffWhite)
                .lineLimit(1)
                .truncationMode(.tail)
                .padding(.horizontal, 64)
        }
        .frame(maxWidth: .infinity, minHeight: 48, maxHeight: 48)
    }
}
