//
//  NukeImageLoader.swift
//  Auris
//
//  Created by Marcel Piešťanský on 09/23/2026.
//  Copyright © 2026 Marcel Piešťanský. All rights reserved.
//  
//  This program is free software. You can redistribute and/or modify it in
//  accordance with the terms of the accompanying license agreement.
//  

import Foundation
import Nuke
import UIKit

struct NukeImageLoader: ImageLoading {
    private let imagePipeline: ImagePipeline

    init(imagePipeline: ImagePipeline) {
        self.imagePipeline = imagePipeline
    }

    func loadImage(from url: URL) async throws -> ImageLoadResult {
        let request: ImageRequest

        if url.scheme?.lowercased() == String.musicKitScheme {
            request = ImageRequest(id: url.absoluteString, data: {
                let (data, _) = try await URLSession.shared.data(for: URLRequest(url: url))
                return data
            })
        } else {
            request = ImageRequest(url: url)
        }

        let response = try await imagePipeline.imageTask(with: request).response
        return ImageLoadResult(image: response.image, wasCached: response.cacheType != nil)
    }
}
