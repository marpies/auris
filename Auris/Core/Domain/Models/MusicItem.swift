//
//  MusicItem.swift
//  Auris
//
//  Created by Marcel Piešťanský on 09/14/2026.
//  Copyright © 2026 Marcel Piešťanský. All rights reserved.
//  
//  This program is free software. You can redistribute and/or modify it in
//  accordance with the terms of the accompanying license agreement.
//  

import Foundation

enum MusicItemType: Hashable, Sendable {
    case song, album, playlist, radio
}

struct MusicItem: Identifiable, Equatable, Hashable, Sendable {
    let id: String
    let type: MusicItemType
    let title: String
    let subtitle: String
    let imageURL: URL?
}
