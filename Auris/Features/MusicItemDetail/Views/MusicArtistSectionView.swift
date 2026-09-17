//
//  MusicArtistSectionView.swift
//  Auris
//
//  Created by Marcel Piešťanský on 09/16/2026.
//  Copyright © 2026 Marcel Piešťanský. All rights reserved.
//
//  This program is free software. You can redistribute and/or modify it in
//  accordance with the terms of the accompanying license agreement.
//

import SwiftUI

struct MusicArtistSectionView: View {
    let artistSection: MusicArtistSection
    let isLoading: Bool
    let didFail: Bool
    let loadNextPage: (MusicArtistSectionKind) async -> Void

    var body: some View {
        switch artistSection.kind {
        case .latestRelease:
            if let item = artistSection.items.first {
                MusicArtistLatestReleaseView(musicItem: item)
            }
        case .topSongs:
            MusicArtistTopSongsSectionView(artistSection: artistSection,
                                           isLoading: isLoading,
                                           didFail: didFail,
                                           loadNextPage: loadNextPage)
        case .albums, .singles, .appearsOn, .featuredPlaylists, .similarArtists:
            MusicArtistHorizontalSectionView(artistSection: artistSection,
                                             isLoading: isLoading,
                                             didFail: didFail,
                                             loadNextPage: loadNextPage)
        }
    }
}
