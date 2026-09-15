//
//  HomeErrorView.swift
//  Auris
//
//  Created by Marcel Piešťanský on 09/15/2026.
//  Copyright © 2026 Marcel Piešťanský. All rights reserved.
//  
//  This program is free software. You can redistribute and/or modify it in
//  accordance with the terms of the accompanying license agreement.
//  

import SwiftUI

struct HomeErrorView: View {
    private let onReload: () async -> Void

    init(onReload: @escaping () async -> Void) {
        self.onReload = onReload
    }

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 60))
                .frame(width: 60, height: 60)
                .foregroundStyle(.secondary)

            VStack(spacing: 8) {
                Text("Something went wrong")
                    .font(.largeTitle.bold())

                Text("Auris couldn’t load your music. Please try again.")
                    .font(.body)
                    .multilineTextAlignment(.center)
            }

            Button("Try Again") {
                Task {
                    await onReload()
                }
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }
}

#Preview {
    HomeErrorView {}
}
