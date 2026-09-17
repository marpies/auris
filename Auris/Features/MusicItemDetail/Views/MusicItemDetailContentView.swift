//
//  MusicItemDetailContentView.swift
//  Auris
//
//  Created by Marcel Piešťanský on 09/15/2026.
//  Copyright © 2026 Marcel Piešťanský. All rights reserved.
//
//  This program is free software. You can redistribute and/or modify it in
//  accordance with the terms of the accompanying license agreement.
//

import SwiftUI

struct MusicItemDetailContentView: View {
    let content: MusicItemDetailContent
    let loadingSectionIDs: Set<MusicArtistSectionKind>
    let failedSectionIDs: Set<MusicArtistSectionKind>
    let loadNextPage: (MusicArtistSectionKind) async -> Void

    var body: some View {
        switch content {
        case .song(let song):
            VStack(alignment: .leading, spacing: 12) {
                if let album = song.album, !album.isEmpty {
                    LabeledContent("Album", value: album)
                }
                
                if let duration = song.formattedDuration {
                    LabeledContent("Duration", value: duration)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        case .songs(let songs):
            if songs.isEmpty {
                ContentUnavailableView("No Songs", systemImage: "music.note.list", description: Text("This item contains no songs."))
            } else {
                LazyVStack(spacing: 0) {
                    ForEach(songs.indices, id: \.self) { index in
                        MusicItemSongRowView(song: songs[index])
                        
                        if index < songs.count - 1 {
                            Divider()
                        }
                    }
                }
            }
        case .artist(let detail):
            MusicArtistDetailContentView(artistDetail: detail,
                                         loadingSectionIDs: loadingSectionIDs,
                                         failedSectionIDs: failedSectionIDs,
                                         loadNextPage: loadNextPage)
        }
    }
}
