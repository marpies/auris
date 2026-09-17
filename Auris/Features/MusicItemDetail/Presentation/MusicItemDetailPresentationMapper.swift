//
//  MusicItemDetailPresentationMapper.swift
//  Auris
//
//  Created by Marcel Piešťanský on 09/16/2026.
//  Copyright © 2026 Marcel Piešťanský. All rights reserved.
//
//  This program is free software. You can redistribute and/or modify it in
//  accordance with the terms of the accompanying license agreement.
//

import Foundation

struct MusicItemDetailPresentationMapper {
    func makeDetail(from data: MusicItemDetailData) -> MusicItemDetail {
        switch data {
        case .song(let song):
            return MusicItemDetail(title: song.title,
                                   subtitle: song.artistName,
                                   imageURL: song.imageURL,
                                   content: .song(makeSong(from: song)))
        case .album(let album, let songs):
            return MusicItemDetail(title: album.title,
                                   subtitle: album.artistName,
                                   imageURL: album.imageURL,
                                   content: .songs(songs.map(makeSong)))
        case .playlist(let playlist, let songs):
            return MusicItemDetail(title: playlist.name,
                                   subtitle: populated(playlist.curatorName),
                                   imageURL: playlist.imageURL,
                                   content: .songs(songs.map(makeSong)))
        case .artist(let artist, let relationships):
            var sections: [MusicArtistSection] = []

            if let album = relationships.latestRelease {
                let item = makeItem(from: .album(album))
                sections.append(MusicArtistSection(kind: .latestRelease, items: [item], nextPageCursor: nil))
            }

            let pages: [(MusicArtistSectionKind, MusicItemDetailPage?)] = [
                (.topSongs, relationships.topSongs),
                (.albums, relationships.fullAlbums),
                (.singles, relationships.singles),
                (.appearsOn, relationships.appearsOnAlbums),
                (.featuredPlaylists, relationships.featuredPlaylists),
                (.similarArtists, relationships.similarArtists)
            ]

            for (kind, page) in pages {
                guard let page, !page.items.isEmpty else { continue }

                sections.append(MusicArtistSection(kind: kind,
                                                   items: page.items.map(makeItem),
                                                   nextPageCursor: page.nextPageCursor))
            }

            let biography = populated(artist.standardEditorialNotes) ?? populated(artist.shortEditorialNotes)
            let detail = MusicArtistDetail(biography: biography, sections: sections)
            return MusicItemDetail(title: artist.name,
                                   subtitle: artistSubtitle(artist),
                                   imageURL: artist.imageURL,
                                   content: .artist(detail))
        }
    }

    func makeItem(from metadata: MusicItemMetadata) -> MusicItem {
        switch metadata {
        case .song(let song):
            let duration = makeSong(from: song).formattedDuration
            let subtitle = duration.map { "\(song.artistName) • \($0)" } ?? song.artistName
            return MusicItem(sourceID: song.sourceID,
                             source: song.source,
                             type: .song,
                             title: song.title,
                             subtitle: subtitle,
                             imageURL: song.imageURL)
        case .album(let album):
            return MusicItem(sourceID: album.sourceID,
                             source: album.source,
                             type: .album,
                             title: album.title,
                             subtitle: "\(album.artistName) • \(album.trackCount) tracks",
                             imageURL: album.imageURL)
        case .playlist(let playlist):
            return MusicItem(sourceID: playlist.sourceID,
                             source: playlist.source,
                             type: .playlist,
                             title: playlist.name,
                             subtitle: populated(playlist.curatorName) ?? "Playlist",
                             imageURL: playlist.imageURL)
        case .artist(let artist):
            return MusicItem(sourceID: artist.sourceID,
                             source: artist.source,
                             type: .artist,
                             title: artist.name,
                             subtitle: artistSubtitle(artist) ?? "Artist",
                             imageURL: artist.imageURL)
        }
    }

    private func makeSong(from song: MusicSongMetadata) -> MusicItemSong {
        MusicItemSong(title: song.title,
                      artist: song.artistName,
                      album: song.albumTitle,
                      duration: song.duration)
    }

    private func artistSubtitle(_ artist: MusicArtistMetadata) -> String? {
        let genres = (artist.genreNames ?? []).filter { !$0.isEmpty }
        return populated(genres.prefix(2).joined(separator: " • "))
    }

    private func populated(_ value: String?) -> String? {
        value.flatMap { $0.isEmpty ? nil : $0 }
    }
}
