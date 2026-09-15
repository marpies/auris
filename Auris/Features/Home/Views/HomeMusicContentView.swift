//
//  HomeMusicContentView.swift
//  Auris
//
//  Created by Marcel Piešťanský on 09/14/2026.
//  Copyright © 2026 Marcel Piešťanský. All rights reserved.
//  
//  This program is free software. You can redistribute and/or modify it in
//  accordance with the terms of the accompanying license agreement.
//  

import Foundation
import SwiftUI

struct HomeMusicContentView: View {
    private let columns: [GridItem] = [
        GridItem(.adaptive(minimum: 140), spacing: 16)
    ]
    
    private let items: [MusicItem]

    init(items: [MusicItem]) {
        self.items = items
    }
    
    var body: some View {
        LazyVGrid(columns: columns) {
            ForEach(items) { item in
                MusicItemView(item: item)
            }
        }
    }
}

#Preview {
    HomeMusicContentView(items: [])
}
