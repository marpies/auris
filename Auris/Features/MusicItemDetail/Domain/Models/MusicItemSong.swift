//
//  MusicItemSong.swift
//  Auris
//
//  Created by Marcel Piešťanský on 09/15/2026.
//  Copyright © 2026 Marcel Piešťanský. All rights reserved.
//
//  This program is free software. You can redistribute and/or modify it in
//  accordance with the terms of the accompanying license agreement.
//

import Foundation

struct MusicItemSong: Equatable, Sendable {
    let title: String
    let artist: String
    let album: String?
    let duration: TimeInterval?

    var formattedDuration: String? {
        duration.map {
            Duration.seconds($0).formatted(
                .units(allowed: [.minutes, .seconds], width: .abbreviated, maximumUnitCount: 2)
            )
        }
    }
}
