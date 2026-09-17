//
//  MusicItemMetadata.swift
//  Auris
//
//  Created by Marcel Piešťanský on 09/16/2026.
//  Copyright © 2026 Marcel Piešťanský. All rights reserved.
//
//  This program is free software. You can redistribute and/or modify it in
//  accordance with the terms of the accompanying license agreement.
//

enum MusicItemMetadata: Equatable, Sendable {
    case song(MusicSongMetadata)
    case album(MusicAlbumMetadata)
    case playlist(MusicPlaylistMetadata)
    case artist(MusicArtistMetadata)
}
