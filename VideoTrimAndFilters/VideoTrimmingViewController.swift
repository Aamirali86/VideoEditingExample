//
//  VideoTrimmingViewController.swift
//  VideoTrimAndFilters
//
//  Created by Aamir on 03/11/2024.
//

import AVFoundation
import UIKit

final class VideoTrimmingViewController: UIViewController {
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var trimButton: UIButton!
    @IBOutlet weak var rangeSlider: RangeSlider!

    var player: AVPlayer!
    var playerLayer: AVPlayerLayer!
    var videoURL: URL!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupPlayer()
    }
}

// MARK: Helper
private extension VideoTrimmingViewController {
    func setupPlayer() {
        let asset = AVAsset(url: videoURL)
        let playerItem = AVPlayerItem(asset: asset)
        Task {
            do {
                if let videoComposition = try await createSepiaVideoComposition(asset: asset) {
                    playerItem.videoComposition = videoComposition
                    self.player = AVPlayer(playerItem: playerItem)
                    
                    self.playerLayer = AVPlayerLayer(player: self.player)
                    self.playerLayer.frame = self.containerView.bounds
                    self.playerLayer.videoGravity = .resizeAspect
                    self.containerView.layer.addSublayer(self.playerLayer)
                }
            } catch {
                print("Failed to create sepia video composition: \(error)")
            }
        }
    }
    
    func playTrimmedSection() {
        guard let duration = player.currentItem?.duration else { return }
        
        let videoDuration = CMTimeGetSeconds(duration)
        let startTime = CMTime(seconds: Double(rangeSlider.startValue) * videoDuration, preferredTimescale: 600)
        let endTime = CMTime(seconds: Double(rangeSlider.endValue) * videoDuration, preferredTimescale: 600)
        
        player.seek(to: startTime) { [weak self] _ in
            self?.player.play()
        }
        
        player.addPeriodicTimeObserver(forInterval: CMTime(seconds: 0.1, preferredTimescale: 600), queue: .main) { [weak self] time in
            if time >= endTime {
                self?.player.pause()
                self?.player.seek(to: startTime)
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
                filter?.setValue(0.8, forKey: kCIInputIntensityKey) // Adjust intensity
                
                let output = filter?.outputImage ?? request.sourceImage
                
                DispatchQueue.main.async {
                    request.finish(with: output, context: nil)
                }
            }
        }
        
        composition.renderSize = trackSize
        composition.frameDuration = CMTime(value: 1, timescale: 30) // 30 FPS
        return composition
    }
}

// MARK: IBAction
private extension VideoTrimmingViewController {
    @IBAction func trimButtonTapped(_ sender: UIButton) {
        playTrimmedSection()
    }
}
