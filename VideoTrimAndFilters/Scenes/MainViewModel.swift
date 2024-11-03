//
//  MainViewModel.swift
//  VideoTrimAndFilters
//
//  Created by Aamir on 03/11/2024.
//

import AVFoundation
import Combine
import UIKit

final class MainViewModel {
    @Published var thumbnailImage: UIImage?
    
    func generateThumbnail(for url: URL) {
        let asset = AVAsset(url: url)
        let assetImageGenerator = AVAssetImageGenerator(asset: asset)
        assetImageGenerator.appliesPreferredTrackTransform = true

        let time = CMTime(seconds: 1, preferredTimescale: 600)
        assetImageGenerator.generateCGImagesAsynchronously(forTimes: [NSValue(time: time)]) { _, image, _, result, error in
            if let error = error {
                debugPrint("Error generating thumbnail: \(error)")
                return
            }
            
            guard let image = image else { return }
            DispatchQueue.main.async { [weak self] in
                self?.thumbnailImage = UIImage(cgImage: image)
            }
        }
    }
}
