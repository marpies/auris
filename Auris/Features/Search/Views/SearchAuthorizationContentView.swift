//
//  SearchAuthorizationContentView.swift
//  Auris
//
//  Created by Marcel Piešťanský on 09/17/2026.
//  Copyright © 2026 Marcel Piešťanský. All rights reserved.
//
//  This program is free software. You can redistribute and/or modify it in
//  accordance with the terms of the accompanying license agreement.
//

import SwiftUI

struct SearchAuthorizationContentView: View {
    let state: SearchAccessState
    let requestAuthorization: () async -> Void

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 60))
                .frame(width: 60, height: 60)
                .foregroundStyle(.secondary)

            VStack(spacing: 8) {
                Text(title)
                    .font(.largeTitle.bold())

                Text(message)
                    .multilineTextAlignment(.center)
            }

            if state == .unauth {
                Button("Allow Access", action: requestAccess)
                    .buttonStyle(.borderedProminent)
            }
        }
        .padding()
    }

    private var icon: String {
        switch state {
        case .unauth:
            return "music.note"
        case .denied:
            return "nosign"
        case .restricted:
            return "lock.shield"
        case .loading, .content:
            return "music.note"
        }
    }

    private var title: String {
        switch state {
        case .unauth:
            return "Connect Apple Music"
        case .denied:
            return "Access Denied"
        case .restricted:
            return "Apple Music Is Restricted"
        case .loading, .content:
            return "Apple Music"
        }
    }

    private var message: String {
        switch state {
        case .unauth:
            return "Allow Auris to search Apple Music and your music library."
        case .denied:
            return "Allow Apple Music access in Settings to use Search."
        case .restricted:
            return "Apple Music access is restricted on this device."
        case .loading, .content:
            return ""
        }
    }

    private func requestAccess() {
        Task {
            await requestAuthorization()
        }
    }
}
