//
//  MusicArtistSectionFooterView.swift
//  Auris
//
//  Created by Marcel Piešťanský on 09/16/2026.
//  Copyright © 2026 Marcel Piešťanský. All rights reserved.
//
//  This program is free software. You can redistribute and/or modify it in
//  accordance with the terms of the accompanying license agreement.
//

import SwiftUI

struct MusicArtistSectionFooterView: View {
    let isLoading: Bool
    let didFail: Bool
    let retry: () -> Void

    var body: some View {
        Group {
            if isLoading {
                ProgressView()
            } else if didFail {
                Button("Try Again", action: retry)
                    .buttonStyle(.bordered)
            }
        }
        .frame(minWidth: isLoading || didFail ? 80 : 0)
    }
}
