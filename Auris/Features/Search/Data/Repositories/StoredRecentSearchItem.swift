//
//  StoredRecentSearchItem.swift
//  Auris
//
//  Created by Marcel Piešťanský on 09/17/2026.
//  Copyright © 2026 Marcel Piešťanský. All rights reserved.
//
//  This program is free software. You can redistribute and/or modify it in
//  accordance with the terms of the accompanying license agreement.
//

import Foundation

struct StoredRecentSearchItem: Codable {
    let sourceID: String
    let source: String
    let type: String
    let title: String
    let subtitle: String
    let imageURL: URL?

    init(item: MusicItem) {
        sourceID = item.sourceID
        source = item.source.storageValue
        type = item.type.storageValue
        title = item.title
        subtitle = item.subtitle
        imageURL = item.imageURL
    }

    func makeMusicItem() -> MusicItem? {
        guard let source = MusicItemSource(storageValue: source),
              let type = MusicItemType(storageValue: type) else { return nil }

        return MusicItem(sourceID: sourceID,
                         source: source,
                         type: type,
                         title: title,
                         subtitle: subtitle,
                         imageURL: imageURL)
    }
}

private extension MusicItemSource {
    var storageValue: String {
        switch self {
        case .library:
            return "library"
        case .catalog:
            return "catalog"
        }
    }

    init?(storageValue: String) {
        switch storageValue {
        case "library":
            self = .library
        case "catalog":
            self = .catalog
        default:
            return nil
        }
    }
}

private extension MusicItemType {
    var storageValue: String {
        switch self {
        case .song:
            return "song"
        case .album:
            return "album"
        case .artist:
            return "artist"
        case .playlist:
            return "playlist"
        case .radio:
            return "radio"
        }
    }

    init?(storageValue: String) {
        switch storageValue {
        case "song":
            self = .song
        case "album":
            self = .album
        case "artist":
            self = .artist
        case "playlist":
            self = .playlist
        case "radio":
            self = .radio
        default:
            return nil
        }
    }
}
