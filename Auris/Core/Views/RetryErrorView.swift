//
//  RetryErrorView.swift
//  Auris
//
//  Created by Marcel Piešťanský on 09/16/2026.
//  Copyright © 2026 Marcel Piešťanský. All rights reserved.
//  
//  This program is free software. You can redistribute and/or modify it in
//  accordance with the terms of the accompanying license agreement.
//  

import SwiftUI

struct RetryErrorView: View {
    private let title: String
    private let message: String
    private let buttonTitle: String
    private let onReload: () async -> Void

    init(title: String, message: String, buttonTitle: String = "Try Again", onReload: @escaping () async -> Void) {
        self.title = title
        self.message = message
        self.buttonTitle = buttonTitle
        self.onReload = onReload
    }
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 60))
                .frame(width: 60, height: 60)
                .foregroundStyle(.secondary)

            VStack(spacing: 8) {
                Text(title)
                    .font(.largeTitle.bold())

                Text(message)
                    .font(.body)
                    .multilineTextAlignment(.center)
            }

            Button(buttonTitle) {
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
    RetryErrorView(title: "Something went wrong", message: "Auris couldn’t load your music library. Please try again.") { }
}
