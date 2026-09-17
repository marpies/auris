//
//  MusicArtistPaginationBatch.swift
//  Auris
//
//  Created by Marcel Piešťanský on 09/16/2026.
//  Copyright © 2026 Marcel Piešťanský. All rights reserved.
//
//  This program is free software. You can redistribute and/or modify it in
//  accordance with the terms of the accompanying license agreement.
//

import MusicKit

nonisolated enum MusicArtistPaginationBatch: Sendable {
    case songs(MusicItemCollection<Song>)
    case albums(MusicItemCollection<Album>)
    case playlists(MusicItemCollection<Playlist>)
    case artists(MusicItemCollection<Artist>)

    var hasNextBatch: Bool {
        switch self {
        case .songs(let collection):
            collection.hasNextBatch
        case .albums(let collection):
            collection.hasNextBatch
        case .playlists(let collection):
            collection.hasNextBatch
        case .artists(let collection):
            collection.hasNextBatch
        }
    }
}
