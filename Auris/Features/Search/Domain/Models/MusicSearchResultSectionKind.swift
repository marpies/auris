//
//  MusicSearchResultSectionKind.swift
//  Auris
//
//  Created by Marcel Piešťanský on 09/17/2026.
//  Copyright © 2026 Marcel Piešťanský. All rights reserved.
//
//  This program is free software. You can redistribute and/or modify it in
//  accordance with the terms of the accompanying license agreement.
//

import Foundation

enum MusicSearchResultSectionKind: Int, Identifiable, Hashable, Sendable {
    var id: Int { rawValue }
    
    case topResults
    case songs
    case albums
    case artists
    case playlists

    var title: LocalizedStringResource {
        switch self {
        case .topResults:
            return "Top Results"
        case .songs:
            return "Songs"
        case .albums:
            return "Albums"
        case .artists:
            return "Artists"
        case .playlists:
            return "Playlists"
        }
    }
}
