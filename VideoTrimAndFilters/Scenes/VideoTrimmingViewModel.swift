//
//  VideoTrimmingViewModel.swift
//  VideoTrimAndFilters
//
//  Created by Aamir on 03/11/2024.
//

import AVFoundation
import Combine
import UIKit

final class VideoTrimmingViewModel {
    @Published var player: AVPlayer?
    @Published var playerLayer: AVPlayerLayer?
    
    // Input
    let onTrim = PassthroughSubject<(CGFloat, CGFloat), Never>()
    
    var videoURL: URL
    private var cancellables = Set<AnyCancellable>()
    
    init(videoURL: URL) {
        self.videoURL = videoURL
        bindInput()
        setupPlayer()
    }
}

// MARK: Binding
private extension VideoTrimmingViewModel {
    func bindInput() {
        onTrim
            .sink { [weak self] startValue, endVlaue in
                self?.playTrimmedSection(startValue: startValue, endValue: endVlaue)
            }
            .store(in: &cancellables)
    }
}

// MARK: Helper
private extension VideoTrimmingViewModel {
    func setupPlayer() {
        let asset = AVAsset(url: videoURL)
        let playerItem = AVPlayerItem(asset: asset)
        
        Task {
            do {
                if let videoComposition = try await createSepiaVideoComposition(asset: asset) {
                    playerItem.videoComposition = videoComposition
                    self.player = AVPlayer(playerItem: playerItem)
                }
            } catch {
                print("Failed to create sepia video composition: \(error)")
            }
        }
    }
    
    func playTrimmedSection(startValue: CGFloat, endValue: CGFloat) {
        guard let player = player, let duration = player.currentItem?.duration else { return }
        
        let videoDuration = CMTimeGetSeconds(duration)
        let startTime = CMTime(seconds: Double(startValue) * videoDuration, preferredTimescale: 600)
        let endTime = CMTime(seconds: Double(endValue) * videoDuration, preferredTimescale: 600)
        
        player.seek(to: startTime) { [weak self] _ in
            self?.player?.play()
        }
        
        player.addPeriodicTimeObserver(forInterval: CMTime(seconds: 0.1, preferredTimescale: 600), queue: .main) { [weak self] time in
            if time >= endTime {
                self?.player?.pause()
                self?.player?.seek(to: startTime)
            }
        }
    }
    
    func createSepiaVideoComposition(asset: AVAsset) async throws -> AVMutableVideoComposition? {
        let videoTracks = try await asset.loadTracks(withMediaType: .video)
        
        guard let videoTrack = videoTracks.first else {
            print("No video tracks found")
            return nil
        }
        
        let trackSize = try await videoTrack.load(.naturalSize)
        
        let composition = AVMutableVideoComposition(asset: asset) { request in
            DispatchQueue.global(qos: .userInitiated).async {
                let filter = CIFilter(name: "CISepiaTone")
                filter?.setValue(request.sourceImage, forKey: kCIInputImageKey)
                filter?.setValue(0.8, forKey: kCIInputIntensityKey)
                
                let output = filter?.outputImage ?? request.sourceImage
                
                DispatchQueue.main.async {
                    request.finish(with: output, context: nil)
                }
            }
        }
        
        composition.renderSize = trackSize
        composition.frameDuration = CMTime(value: 1, timescale: 30)
        return composition
    }
}
