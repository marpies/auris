//
//  SearchMusicItemRowView.swift
//  Auris
//
//  Created by Marcel Piešťanský on 09/17/2026.
//  Copyright © 2026 Marcel Piešťanský. All rights reserved.
//
//  This program is free software. You can redistribute and/or modify it in
//  accordance with the terms of the accompanying license agreement.
//

import SwiftUI

struct SearchMusicItemRowView: View {
    let item: MusicItem
    let sourceDescription: String?

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(.secondary.opacity(0.15))

                if let imageURL = item.imageURL {
                    RemoteImageView(url: imageURL) { image in
                        image
                            .resizable()
                            .scaledToFill()
                    } placeholder: {
                        Image(systemName: itemIcon)
                            .foregroundStyle(.secondary)
                            .frame(width: 56, height: 56)
                    }
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                } else {
                    Image(systemName: itemIcon)
                        .foregroundStyle(.secondary)
                }
            }
            .frame(width: 56, height: 56)
            .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 2) {
                Text(item.title)
                    .font(.headline)
                    .lineLimit(2)

                Text(item.subtitle)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)

                if let sourceDescription {
                    Text(sourceDescription)
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                }
            }

            Spacer(minLength: 8)

            Image(systemName: "chevron.right")
                .font(.caption.bold())
                .foregroundStyle(.tertiary)
                .accessibilityHidden(true)
        }
        .padding(.vertical, 8)
        .contentShape(.rect)
    }

    private var itemIcon: String {
        switch item.type {
        case .song:
            return "music.note"
        case .album:
            return "rectangle.stack.badge.play"
        case .artist:
            return "music.mic"
        case .playlist:
            return "music.note.list"
        case .radio:
            return "dot.radiowaves.left.and.right"
        }
    }
}
