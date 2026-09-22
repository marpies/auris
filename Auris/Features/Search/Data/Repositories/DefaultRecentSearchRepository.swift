//
//  DefaultRecentSearchRepository.swift
//  Auris
//
//  Created by Marcel Piešťanský on 09/17/2026.
//  Copyright © 2026 Marcel Piešťanský. All rights reserved.
//
//  This program is free software. You can redistribute and/or modify it in
//  accordance with the terms of the accompanying license agreement.
//

import Foundation

final class DefaultRecentSearchRepository: RecentSearchRepository {
    private static let maximumItemCount = 10
    private static let storageKey = "search.recentItems"

    private let userDefaults: UserDefaults
    private let decoder = JSONDecoder()
    private let encoder = JSONEncoder()

    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }

    func load() async -> [MusicItem] {
        guard let data = userDefaults.data(forKey: Self.storageKey),
              let storedItems = try? decoder.decode([StoredRecentSearchItem].self, from: data) else { return [] }

        return storedItems.compactMap { $0.makeMusicItem() }
    }

    func record(item: MusicItem) async -> [MusicItem] {
        var items = await load()
        items.removeAll { $0.id == item.id }
        items.insert(item, at: 0)
        items = Array(items.prefix(Self.maximumItemCount))

        let storedItems = items.map(StoredRecentSearchItem.init)

        if let data = try? encoder.encode(storedItems) {
            userDefaults.set(data, forKey: Self.storageKey)
        }

        return items
    }
}
