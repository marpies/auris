//
//  SearchGenreTileView.swift
//  Auris
//
//  Created by Marcel Piešťanský on 09/17/2026.
//  Copyright © 2026 Marcel Piešťanský. All rights reserved.
//
//  This program is free software. You can redistribute and/or modify it in
//  accordance with the terms of the accompanying license agreement.
//

import SwiftUI

struct SearchGenreTileView: View {
    private static let colors: [Color] = [
        .pink,
        .purple,
        .indigo,
        .blue,
        .teal,
        .green,
        .orange,
        .red
    ]

    let genre: MusicGenre

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            RoundedRectangle(cornerRadius: 12)
                .fill(Self.colors[colorIndex].gradient)

            Text(genre.name)
                .font(.headline)
                .foregroundStyle(.white)
                .multilineTextAlignment(.leading)
                .padding(12)
        }
        .frame(maxWidth: .infinity)
        .frame(minHeight: 100)
        .accessibilityElement(children: .combine)
        .accessibilityHint("Shows popular music in this genre")
    }

    private var colorIndex: Int {
        genre.name.unicodeScalars.reduce(0) { partialResult, scalar in
            (partialResult + Int(scalar.value)) % Self.colors.count
        }
    }
}
