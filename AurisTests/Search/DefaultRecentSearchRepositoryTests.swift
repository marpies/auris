//
//  DefaultRecentSearchRepositoryTests.swift
//  AurisTests
//
//  Created by Marcel Piešťanský on 09/17/2026.
//  Copyright © 2026 Marcel Piešťanský. All rights reserved.
//
//  This program is free software. You can redistribute and/or modify it in
//  accordance with the terms of the accompanying license agreement.
//

import Foundation
import Testing
@testable import Auris

@MainActor
struct DefaultRecentSearchRepositoryTests {
    @Test func persistsItemsAcrossRepositoryInstances() async throws {
        let (userDefaults, suiteName) = try makeUserDefaults()
        defer { userDefaults.removePersistentDomain(forName: suiteName) }
        let item = makeItem(sourceID: "song", source: .catalog)
        let repository = DefaultRecentSearchRepository(userDefaults: userDefaults)
        _ = await repository.record(item: item)
        let restoredRepository = DefaultRecentSearchRepository(userDefaults: userDefaults)
        let restoredItems = await restoredRepository.load()
        #expect(restoredItems == [item])
    }

    @Test func movesDuplicateToFrontAndKeepsSourcesDistinct() async throws {
        let (userDefaults, suiteName) = try makeUserDefaults()
        defer { userDefaults.removePersistentDomain(forName: suiteName) }
        let repository = DefaultRecentSearchRepository(userDefaults: userDefaults)
        let catalogItem = makeItem(sourceID: "shared", source: .catalog)
        let libraryItem = makeItem(sourceID: "shared", source: .library)
        let otherItem = makeItem(sourceID: "other", source: .catalog)
        _ = await repository.record(item: catalogItem)
        _ = await repository.record(item: libraryItem)
        _ = await repository.record(item: otherItem)
        let items = await repository.record(item: catalogItem)
        #expect(items == [catalogItem, otherItem, libraryItem])
    }

    @Test func limitsStoredItemsToTen() async throws {
        let (userDefaults, suiteName) = try makeUserDefaults()
        defer { userDefaults.removePersistentDomain(forName: suiteName) }
        let repository = DefaultRecentSearchRepository(userDefaults: userDefaults)

        for index in 0..<12 {
            _ = await repository.record(item: makeItem(sourceID: "\(index)", source: .catalog))
        }

        let items = await repository.load()
        #expect(items.count == 10)
        #expect(items.first?.sourceID == "11")
        #expect(items.last?.sourceID == "2")
    }

    @Test func invalidStoredDataReturnsEmptyList() async throws {
        let (userDefaults, suiteName) = try makeUserDefaults()
        defer { userDefaults.removePersistentDomain(forName: suiteName) }
        userDefaults.set(Data("invalid".utf8), forKey: "search.recentItems")
        let repository = DefaultRecentSearchRepository(userDefaults: userDefaults)
        let items = await repository.load()
        #expect(items.isEmpty)
    }

    private func makeUserDefaults() throws -> (UserDefaults, String) {
        let suiteName = "DefaultRecentSearchRepositoryTests.\(UUID().uuidString)"
        let userDefaults = try #require(UserDefaults(suiteName: suiteName))
        return (userDefaults, suiteName)
    }

    private func makeItem(sourceID: String, source: MusicItemSource) -> MusicItem {
        MusicItem(sourceID: sourceID,
                  source: source,
                  type: .song,
                  title: "Song \(sourceID)",
                  subtitle: "Artist",
                  imageURL: nil)
    }
}
