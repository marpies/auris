//
//  HomeUnauthView.swift
//  Auris
//
//  Created by Marcel Piešťanský on 09/14/2026.
//  Copyright © 2026 Marcel Piešťanský. All rights reserved.
//  
//  This program is free software. You can redistribute and/or modify it in
//  accordance with the terms of the accompanying license agreement.
//  

import SwiftUI

struct HomeUnauthView: View {
    private let onRequestAuthorization: () async -> Void

    init(onRequestAuthorization: @escaping () async -> Void) {
        self.onRequestAuthorization = onRequestAuthorization
    }

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "music.note.house")
                .font(.system(size: 60))
                .frame(width: 60, height: 60)
                .foregroundStyle(.secondary)

            VStack(spacing: 8) {
                Text("Connect Apple Music")
                    .font(.largeTitle.bold())

                Text("Allow Auris to access your Apple Music library and enable features that use your music.")
                    .font(.body)
                    .multilineTextAlignment(.center)
            }

            Button("Allow Access") {
                Task {
                    await onRequestAuthorization()
                }
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }
}

#Preview {
    HomeUnauthView {}
}
