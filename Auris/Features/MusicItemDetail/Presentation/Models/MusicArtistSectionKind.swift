//
//  MusicArtistSectionKind.swift
//  Auris
//
//  Created by Marcel Piešťanský on 09/16/2026.
//  Copyright © 2026 Marcel Piešťanský. All rights reserved.
//
//  This program is free software. You can redistribute and/or modify it in
//  accordance with the terms of the accompanying license agreement.
//

enum MusicArtistSectionKind: Hashable, Sendable {
    case latestRelease
    case topSongs
    case albums
    case singles
    case appearsOn
    case featuredPlaylists
    case similarArtists

    var title: String {
        switch self {
        case .latestRelease:
            "Latest Release"
        case .topSongs:
            "Top Songs"
        case .albums:
            "Albums"
        case .singles:
            "Singles & EPs"
        case .appearsOn:
            "Appears On"
        case .featuredPlaylists:
            "Featured Playlists"
        case .similarArtists:
            "Similar Artists"
        }
    }
}
