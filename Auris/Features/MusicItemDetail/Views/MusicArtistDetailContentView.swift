//
//  MusicArtistDetailContentView.swift
//  Auris
//
//  Created by Marcel Piešťanský on 09/16/2026.
//  Copyright © 2026 Marcel Piešťanský. All rights reserved.
//
//  This program is free software. You can redistribute and/or modify it in
//  accordance with the terms of the accompanying license agreement.
//

import SwiftUI

struct MusicArtistDetailContentView: View {
    let artistDetail: MusicArtistDetail
    let loadingSectionIDs: Set<MusicArtistSectionKind>
    let failedSectionIDs: Set<MusicArtistSectionKind>
    let loadNextPage: (MusicArtistSectionKind) async -> Void

    var body: some View {
        if artistDetail.sections.isEmpty, artistDetail.biography == nil {
            ContentUnavailableView("No Artist Details",
                                   systemImage: "music.mic",
                                   description: Text("No additional information is available for this artist."))
                .padding(.horizontal)
        } else {
            LazyVStack(spacing: 32) {
                ForEach(artistDetail.sections) { section in
                    MusicArtistSectionView(artistSection: section,
                                           isLoading: loadingSectionIDs.contains(section.id),
                                           didFail: failedSectionIDs.contains(section.id),
                                           loadNextPage: loadNextPage)
                }

                if let biography = artistDetail.biography, !biography.isEmpty {
                    MusicArtistAboutView(biography: biography)
                }
            }
        }
    }
}
