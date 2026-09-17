//
//  MusicArtistSection.swift
//  Auris
//
//  Created by Marcel Piešťanský on 09/16/2026.
//  Copyright © 2026 Marcel Piešťanský. All rights reserved.
//
//  This program is free software. You can redistribute and/or modify it in
//  accordance with the terms of the accompanying license agreement.
//

struct MusicArtistSection: Identifiable, Equatable, Sendable {
    var id: MusicArtistSectionKind {
        kind
    }

    let kind: MusicArtistSectionKind
    var items: [MusicItem]
    var nextPageCursor: MusicItemDetailPageCursor?
}
