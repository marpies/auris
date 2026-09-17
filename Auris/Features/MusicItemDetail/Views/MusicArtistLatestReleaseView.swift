//
//  MusicArtistLatestReleaseView.swift
//  Auris
//
//  Created by Marcel Piešťanský on 09/16/2026.
//  Copyright © 2026 Marcel Piešťanský. All rights reserved.
//
//  This program is free software. You can redistribute and/or modify it in
//  accordance with the terms of the accompanying license agreement.
//

import SwiftUI

struct MusicArtistLatestReleaseView: View {
    let musicItem: MusicItem

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(MusicArtistSectionKind.latestRelease.title)
                .font(.title2.bold())
                .accessibilityAddTraits(.isHeader)

            NavigationLink(value: musicItem) {
                HStack(spacing: 16) {
                    AsyncImage(url: musicItem.imageURL) { image in
                        image
                            .resizable()
                            .scaledToFill()
                    } placeholder: {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(.quaternary)
                            .overlay {
                                Image(systemName: "rectangle.stack.badge.play")
                                    .font(.title)
                                    .foregroundStyle(.secondary)
                            }
                    }
                    .frame(width: 112, height: 112)
                    .clipShape(.rect(cornerRadius: 12))
                    .accessibilityHidden(true)

                    VStack(alignment: .leading, spacing: 4) {
                        Text(musicItem.title)
                            .font(.headline)
                            .lineLimit(2)

                        Text(musicItem.subtitle)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .lineLimit(2)
                    }

                    Spacer(minLength: 0)
                }
                .contentShape(.rect)
                .accessibilityElement(children: .combine)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal)
    }
}
