//
//  SearchTestRecentRepository.swift
//  AurisTests
//
//  Created by Marcel Piešťanský on 09/17/2026.
//  Copyright © 2026 Marcel Piešťanský. All rights reserved.
//
//  This program is free software. You can redistribute and/or modify it in
//  accordance with the terms of the accompanying license agreement.
//

@testable import Auris

@MainActor
final class SearchTestRecentRepository: RecentSearchRepository {
    var items: [MusicItem]

    init(items: [MusicItem] = []) {
        self.items = items
    }

    func load() async -> [MusicItem] {
        items
    }

    func record(item: MusicItem) async -> [MusicItem] {
        items.removeAll { $0.id == item.id }
        items.insert(item, at: 0)
        return items
    }
}
