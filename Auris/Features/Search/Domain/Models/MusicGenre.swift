//
//  MusicGenre.swift
//  Auris
//
//  Created by Marcel Piešťanský on 09/17/2026.
//  Copyright © 2026 Marcel Piešťanský. All rights reserved.
//
//  This program is free software. You can redistribute and/or modify it in
//  accordance with the terms of the accompanying license agreement.
//

struct MusicGenre: Identifiable, Equatable, Hashable, Sendable {
    var id: String { sourceID }

    let sourceID: String
    let name: String
}
