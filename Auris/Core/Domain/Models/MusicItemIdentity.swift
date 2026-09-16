//
//  MusicItemIdentity.swift
//  Auris
//
//  Created by Marcel Piešťanský on 09/16/2026.
//  Copyright © 2026 Marcel Piešťanský. All rights reserved.
//
//  This program is free software. You can redistribute and/or modify it in
//  accordance with the terms of the accompanying license agreement.
//

struct MusicItemIdentity: Hashable, Sendable {
    let sourceID: String
    let source: MusicItemSource
    let type: MusicItemType
}
