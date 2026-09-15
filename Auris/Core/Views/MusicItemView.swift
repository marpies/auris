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
    private let item: MusicItem

    init(item: MusicItem) {
        self.item = item
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            GeometryReader { proxy in
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(.secondarySystemBackground))
                        .shadow(color: .black.opacity(0.15), radius: 4, x: 0, y: 3)

                    Image(systemName: "music.note")
                        .resizable()
                        .scaledToFit()
                        .frame(width: proxy.size.width * 0.5, height: proxy.size.height * 0.5)
                }
            }
            .aspectRatio(1, contentMode: .fit)
            .frame(maxWidth: .infinity)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(item.title)
                    .font(.headline)
                
                Text(item.subtitle)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .padding(.horizontal)
        }
    }
}

#Preview {
    MusicItemView(item: MusicItem(id: "song:example", type: .song, title: "I Bet You Look Good on the Dancefloor", subtitle: "Arctic Monkeys • 3m 38s", imageURL: nil))
}
