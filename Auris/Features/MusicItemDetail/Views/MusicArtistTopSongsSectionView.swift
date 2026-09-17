//
//  MusicArtistTopSongsSectionView.swift
//  Auris
//
//  Created by Marcel Piešťanský on 09/16/2026.
//  Copyright © 2026 Marcel Piešťanský. All rights reserved.
//
//  This program is free software. You can redistribute and/or modify it in
//  accordance with the terms of the accompanying license agreement.
//

import SwiftUI

struct MusicArtistTopSongsSectionView: View {
    let artistSection: MusicArtistSection
    let isLoading: Bool
    let didFail: Bool
    let loadNextPage: (MusicArtistSectionKind) async -> Void

    private var songColumns: [(id: MusicItemIdentity, items: ArraySlice<MusicItem>)] {
        stride(from: 0, to: artistSection.items.count, by: 4).map { start in
            let end = min(start + 4, artistSection.items.count)
            return (id: artistSection.items[start].id, items: artistSection.items[start..<end])
        }
    }

    var body: some View {
        let columns = songColumns

        VStack(alignment: .leading, spacing: 12) {
            Text(artistSection.kind.title)
                .font(.title2.bold())
                .padding(.horizontal, 16)
                .accessibilityAddTraits(.isHeader)

            ScrollView(.horizontal) {
                LazyHStack(alignment: .top, spacing: 16) {
                    ForEach(columns, id: \.id) { column in
                        VStack(spacing: 0) {
                            ForEach(column.items) { item in
                                NavigationLink(value: item) {
                                    MusicArtistTopSongRowView(musicItem: item)
                                }
                                .buttonStyle(.plain)

                                if item.id != column.items.last?.id {
                                    Divider()
                                }
                            }
                        }
                        .containerRelativeFrame(.horizontal) { width, _ in
                            max(width - 32, 0)
                        }
                        .task(id: artistSection.nextPageCursor) {
                            guard column.id == columns.last?.id,
                                  artistSection.nextPageCursor != nil else { return }

                            await loadNextPage(artistSection.id)
                        }
                    }

                    MusicArtistSectionFooterView(isLoading: isLoading,
                                                 didFail: didFail,
                                                 retry: retry)
                }
                .scrollTargetLayout()
                .padding(.trailing, 32)
            }
            .contentMargins(.horizontal, 16, for: .scrollContent)
            .scrollTargetBehavior(.viewAligned)
            .scrollIndicators(.hidden)
        }
    }

    private func retry() {
        Task {
            await loadNextPage(artistSection.id)
        }
    }
}
