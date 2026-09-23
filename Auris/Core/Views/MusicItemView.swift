//
//  MusicItemView.swift
//  Auris
//
//  Created by Marcel Piešťanský on 09/14/2026.
//  Copyright © 2026 Marcel Piešťanský. All rights reserved.
//  
//  This program is free software. You can redistribute and/or modify it in
//  accordance with the terms of the accompanying license agreement.
//  

import SwiftUI

struct MusicItemView: View {
    private var itemIcon: String {
        switch item.type {
        case .song:
            return "music.note"
        case .album:
            return "rectangle.stack.badge.play"
        case .artist:
            return "music.mic"
        case .playlist:
            return "music.note.list"
        case .radio:
            return "dot.radiowaves.left.and.right"
        }
    }
    
    private let item: MusicItem

    init(item: MusicItem) {
        self.item = item
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            GeometryReader { proxy in
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(.secondarySystemBackground))
                        .shadow(color: .black.opacity(0.15), radius: 4, x: 0, y: 3)
                    
                    if let artworkURL = item.imageURL {                        
                        RemoteImageView(url: artworkURL) { image in
                            image
                                .resizable()
                                .scaledToFit()
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                        } placeholder: {
                            placeholderImage(proxy: proxy)
                        }
                    } else {
                        placeholderImage(proxy: proxy)
                    }
                }
            }
            .aspectRatio(1, contentMode: .fit)
            .frame(maxWidth: .infinity)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(item.title)
                    .lineLimit(1)
                    .font(.caption.bold())
                
                Text(item.subtitle)
                    .lineLimit(1)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding(.horizontal, 4)
        }
    }
    
    private func placeholderImage(proxy: GeometryProxy) -> some View {
        Image(systemName: itemIcon)
            .resizable()
            .scaledToFit()
            .frame(width: proxy.size.width * 0.5, height: proxy.size.height * 0.5)
    }
}

#Preview {
    let item = MusicItem(sourceID: "example",
                         source: .library,
                         type: .song,
                         title: "I Bet You Look Good on the Dancefloor",
                         subtitle: "Arctic Monkeys • 3m 38s",
                         imageURL: nil)
    MusicItemView(item: item)
}
