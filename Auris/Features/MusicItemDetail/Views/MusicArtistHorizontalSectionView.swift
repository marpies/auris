//
//  MusicArtistHorizontalSectionView.swift
//  Auris
//
//  Created by Marcel Piešťanský on 09/16/2026.
//  Copyright © 2026 Marcel Piešťanský. All rights reserved.
//
//  This program is free software. You can redistribute and/or modify it in
//  accordance with the terms of the accompanying license agreement.
//

import SwiftUI

struct MusicArtistHorizontalSectionView: View {
    let artistSection: MusicArtistSection
    let isLoading: Bool
    let didFail: Bool
    let loadNextPage: (MusicArtistSectionKind) async -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(artistSection.kind.title)
                .font(.title2.bold())
                .padding(.horizontal)
                .accessibilityAddTraits(.isHeader)

            ScrollView(.horizontal) {
                LazyHStack(alignment: .top, spacing: 16) {
                    ForEach(artistSection.items) { item in
                        NavigationLink(value: item) {
                            MusicArtistSectionCardView(musicItem: item)
                        }
                        .buttonStyle(.plain)
                        .task(id: artistSection.nextPageCursor) {
                            guard item.id == artistSection.items.last?.id,
                                  artistSection.nextPageCursor != nil else { return }

                            await loadNextPage(artistSection.id)
                        }
                    }

                    MusicArtistSectionFooterView(isLoading: isLoading,
                                                 didFail: didFail,
                                                 retry: retry)
                }
                .padding(.horizontal)
            }
            .scrollIndicators(.hidden)
        }
    }

    private func retry() {
        Task {
            await loadNextPage(artistSection.id)
        }
    }
}
