//
//  MusicArtistDetailHeaderView.swift
//  Auris
//
//  Created by Marcel Piešťanský on 09/16/2026.
//  Copyright © 2026 Marcel Piešťanský. All rights reserved.
//
//  This program is free software. You can redistribute and/or modify it in
//  accordance with the terms of the accompanying license agreement.
//

import SwiftUI

struct MusicArtistDetailHeaderView: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    let title: String
    let subtitle: String?
    let imageURL: URL?

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            AsyncImage(url: imageURL) { image in
                image
                    .resizable()
                    .scaledToFill()
            } placeholder: {
                Rectangle()
                    .fill(.quaternary)
                    .overlay {
                        Image(systemName: "music.mic")
                            .font(.largeTitle)
                            .foregroundStyle(.secondary)
                    }
            }
            .accessibilityHidden(true)

            LinearGradient(colors: [.clear, .black.opacity(0.8)],
                           startPoint: .center,
                           endPoint: .bottom)
        }
        .aspectRatio(1, contentMode: .fill)
        .containerRelativeFrame(.horizontal)
        .clipped()
        .visualEffect { [reduceMotion] content, proxy in
            let pullDistance = max(proxy.frame(in: .scrollView).minY, 0)
            let height = max(proxy.size.height, 1)
            let scale = reduceMotion ? 1 : 1 + pullDistance / height
            return content
                .scaleEffect(scale, anchor: .bottom)
        }
        .overlay(alignment: .bottomLeading) {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.largeTitle.bold())
                    .foregroundStyle(.white)
                
                if let subtitle, !subtitle.isEmpty {
                    Text(subtitle)
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.85))
                }
            }
            .padding(20)
        }
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(.isHeader)
    }
}
