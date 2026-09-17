//
//  MusicItemDetailHeaderView.swift
//  Auris
//
//  Created by Marcel Piešťanský on 09/15/2026.
//  Copyright © 2026 Marcel Piešťanský. All rights reserved.
//
//  This program is free software. You can redistribute and/or modify it in
//  accordance with the terms of the accompanying license agreement.
//

import SwiftUI

struct MusicItemDetailHeaderView: View {
    let title: String
    let subtitle: String?
    let imageURL: URL?
    let type: MusicItemType

    private var symbol: String {
        switch type {
        case .song:
            "music.note"
        case .album:
            "rectangle.stack.badge.play"
        case .artist:
            "music.mic"
        case .playlist:
            "music.note.list"
        case .radio:
            "dot.radiowaves.left.and.right"
        }
    }

    var body: some View {
        VStack(spacing: 16) {
            AsyncImage(url: imageURL) { image in
                image
                    .resizable()
                    .scaledToFit()
            } placeholder: {
                RoundedRectangle(cornerRadius: 12)
                    .fill(.quaternary)
                    .overlay {
                        Image(systemName: symbol)
                            .font(.largeTitle)
                            .foregroundStyle(.secondary)
                    }
            }
            .aspectRatio(1, contentMode: .fit)
            .frame(maxWidth: 320)
            .clipShape(.rect(cornerRadius: 12))
            .accessibilityHidden(true)

            VStack(spacing: 4) {
                Text(title)
                    .font(.title2.bold())
                    .accessibilityAddTraits(.isHeader)
                
                if let subtitle, !subtitle.isEmpty {
                    Text(subtitle)
                        .foregroundStyle(.secondary)
                }
            }
            .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
    }
}
