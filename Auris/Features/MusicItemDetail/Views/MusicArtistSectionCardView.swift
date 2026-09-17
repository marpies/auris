//
//  MusicArtistSectionCardView.swift
//  Auris
//
//  Created by Marcel Piešťanský on 09/16/2026.
//  Copyright © 2026 Marcel Piešťanský. All rights reserved.
//
//  This program is free software. You can redistribute and/or modify it in
//  accordance with the terms of the accompanying license agreement.
//

import SwiftUI

struct MusicArtistSectionCardView: View {
    let musicItem: MusicItem

    private var symbol: String {
        switch musicItem.type {
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

    private var artworkCornerRadius: CGFloat {
        musicItem.type == .artist ? 70 : 12
    }

    var body: some View {
        VStack(alignment: musicItem.type == .artist ? .center : .leading, spacing: 4) {
            ZStack {
                RoundedRectangle(cornerRadius: artworkCornerRadius)
                    .fill(.quaternary)

                AsyncImage(url: musicItem.imageURL) { image in
                    image
                        .resizable()
                        .scaledToFill()
                } placeholder: {
                    Image(systemName: symbol)
                        .font(.largeTitle)
                        .foregroundStyle(.secondary)
                }
            }
            .frame(width: 140, height: 140)
            .clipShape(.rect(cornerRadius: artworkCornerRadius))
            .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 2) {
                Text(musicItem.title)
                    .font(.caption.bold())
                    .lineLimit(1)

                Text(musicItem.subtitle)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
            .padding(.horizontal, 4)
        }
        .frame(width: 140, alignment: musicItem.type == .artist ? .center : .leading)
        .multilineTextAlignment(musicItem.type == .artist ? .center : .leading)
        .accessibilityElement(children: .combine)
    }
}
