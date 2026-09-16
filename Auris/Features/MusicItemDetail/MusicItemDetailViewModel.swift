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

    private let musicItemDetailRepository: any MusicItemDetailRepository
    private var loadID: UUID?

    init(item: MusicItem, musicItemDetailRepository: any MusicItemDetailRepository) {
        self.item = item
        self.musicItemDetailRepository = musicItemDetailRepository
    }

    func load() async {
        let requestID = UUID()
        loadID = requestID
        state = .loading

        do {
            let detail = try await musicItemDetailRepository.load(item: item)
            
            try Task.checkCancellation()
            
            guard loadID == requestID else { return }
            
            state = .content(detail)
        } catch {
            guard !Task.isCancelled, !(error is CancellationError),
                  loadID == requestID else { return }
            
            state = error is MusicItemDetailError ? .unavailable : .error
        }
    }
}
