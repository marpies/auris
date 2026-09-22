//
//  MusicSearchRepository.swift
//  Auris
//
//  Created by Marcel Piešťanský on 09/17/2026.
//  Copyright © 2026 Marcel Piešťanský. All rights reserved.
//
//  This program is free software. You can redistribute and/or modify it in
//  accordance with the terms of the accompanying license agreement.
//

protocol MusicSearchRepository {
    func loadGenres() async throws -> [MusicGenre]
    func search(term: String, target: MusicSearchTarget) async throws -> MusicSearchResults
    func loadCharts(genre: MusicGenre) async throws -> MusicSearchResults
}
