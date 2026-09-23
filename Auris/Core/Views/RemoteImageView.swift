//
//  RemoteImageView.swift
//  Auris
//
//  Created by Marcel Piešťanský on 09/23/2026.
//  Copyright © 2026 Marcel Piešťanský. All rights reserved.
//  
//  This program is free software. You can redistribute and/or modify it in
//  accordance with the terms of the accompanying license agreement.
//  

import SwiftUI
import UIKit

struct RemoteImageView<Content: View, Placeholder: View>: View {
    @Environment(\.imageLoader) private var imageLoader
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var loadedImage: (url: URL, image: UIImage)?

    let url: URL?
    let content: (Image) -> Content
    let placeholder: () -> Placeholder

    private var currentImage: UIImage? {
        guard let url, let loadedImage, loadedImage.url == url else { return nil }
        return loadedImage.image
    }

    init(url: URL?,
         @ViewBuilder content: @escaping (Image) -> Content,
         @ViewBuilder placeholder: @escaping () -> Placeholder) {
        self.url = url
        self.content = content
        self.placeholder = placeholder
        
        print(String(describing: url))
    }

    var body: some View {
        ZStack {
            placeholder()
                .opacity(currentImage == nil ? 1 : 0)
                .accessibilityHidden(currentImage != nil)

            if let currentImage {
                content(Image(uiImage: currentImage))
                    .transition(.opacity)
            }
        }
        .task(id: url) {
            guard loadedImage?.url != url else { return }
            loadedImage = nil

            guard let url else { return }
            guard let imageLoader else {
                preconditionFailure("Missing image loader in the SwiftUI environment")
            }

            do {
                let image = try await imageLoader.loadImage(from: url)
                guard !Task.isCancelled else { return }

                if reduceMotion {
                    loadedImage = (url: url, image: image)
                } else {
                    withAnimation(.easeInOut(duration: 0.25)) {
                        loadedImage = (url: url, image: image)
                    }
                }
            } catch {
                // Keep the caller's placeholder visible on load failure.
            }
        }
    }
}
