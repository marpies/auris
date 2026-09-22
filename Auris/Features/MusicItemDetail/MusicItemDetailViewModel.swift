//
//  MusicItemDetailViewModel.swift
//  Auris
//
//  Created by Marcel Piešťanský on 09/15/2026.
//  Copyright © 2026 Marcel Piešťanský. All rights reserved.
//
//  This program is free software. You can redistribute and/or modify it in
//  accordance with the terms of the accompanying license agreement.
//

import Foundation

@MainActor
@Observable
final class MusicItemDetailViewModel {
    let item: MusicItem
    private(set) var state: MusicItemDetailState = .loading
    private(set) var loadingSectionIDs: Set<MusicArtistSectionKind> = []
    private(set) var failedSectionIDs: Set<MusicArtistSectionKind> = []

    private let musicItemDetailRepository: any MusicItemDetailRepository
    private let musicItemDetailPresentationMapper = MusicItemDetailPresentationMapper()
    private var loadID: UUID?

    init(item: MusicItem, musicItemDetailRepository: any MusicItemDetailRepository) {
        self.item = item
        self.musicItemDetailRepository = musicItemDetailRepository
    }

    func load() async {
        let requestID = UUID()
        loadID = requestID
        state = .loading
        loadingSectionIDs.removeAll()
        failedSectionIDs.removeAll()

        do {
            let detail = try await musicItemDetailRepository.load(item: item)
            
            try Task.checkCancellation()
            
            guard loadID == requestID else { return }
            
            state = .content(musicItemDetailPresentationMapper.makeDetail(from: detail))
        } catch is CancellationError {
            return
        } catch {
            guard !Task.isCancelled,
                  loadID == requestID else { return }
            
            state = error is MusicItemDetailError ? .unavailable : .error
        }
    }

    func loadNextPage(sectionID: MusicArtistSectionKind) async {
        guard case .content(let detail) = state,
              case .artist(let artistDetail) = detail.content,
              let section = artistDetail.sections.first(where: { $0.id == sectionID }),
              let cursor = section.nextPageCursor,
              !loadingSectionIDs.contains(sectionID) else { return }

        let detailLoadID = loadID
        loadingSectionIDs.insert(sectionID)
        failedSectionIDs.remove(sectionID)

        defer {
            loadingSectionIDs.remove(sectionID)
        }

        do {
            let page = try await musicItemDetailRepository.loadNextPage(cursor: cursor)

            guard loadID == detailLoadID else { return }

            append(page: page, to: sectionID)
        } catch {
            guard !Task.isCancelled,
                  loadID == detailLoadID else { return }

            failedSectionIDs.insert(sectionID)
        }
    }

    private func append(page: MusicItemDetailPage, to sectionID: MusicArtistSectionKind) {
        guard case .content(let detail) = state,
              case .artist(var artistDetail) = detail.content,
              let sectionIndex = artistDetail.sections.firstIndex(where: { $0.id == sectionID }) else { return }

        let existingIDs = Set(artistDetail.sections[sectionIndex].items.map(\.id))
        let items = page.items.map(musicItemDetailPresentationMapper.makeItem)
        let newItems = items.filter { !existingIDs.contains($0.id) }
        artistDetail.sections[sectionIndex].items.append(contentsOf: newItems)
        artistDetail.sections[sectionIndex].nextPageCursor = page.nextPageCursor
        state = .content(MusicItemDetail(title: detail.title,
                                         subtitle: detail.subtitle,
                                         imageURL: detail.imageURL,
                                         content: .artist(artistDetail)))
    }
}
