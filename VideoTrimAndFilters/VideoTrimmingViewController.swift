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
        player = AVPlayer(playerItem: playerItem)
        
        // Set up the player layer
        playerLayer = AVPlayerLayer(player: player)
        playerLayer.frame = containerView.bounds
        playerLayer.videoGravity = .resizeAspect
        containerView.layer.addSublayer(playerLayer)
    }
    
    func playTrimmedSection() {
        guard let duration = player.currentItem?.duration else { return }
        
        let videoDuration = CMTimeGetSeconds(duration)
        let startTime = CMTime(seconds: Double(rangeSlider.startValue) * videoDuration, preferredTimescale: 600)
        let endTime = CMTime(seconds: Double(rangeSlider.endValue) * videoDuration, preferredTimescale: 600)
        
        // Seek to start time and play within the time range
        player.seek(to: startTime) { [weak self] _ in
            self?.player.play()
        }
        
        // Observe playback to stop at end time
        player.addPeriodicTimeObserver(forInterval: CMTime(seconds: 0.1, preferredTimescale: 600), queue: .main) { [weak self] time in
            if time >= endTime {
                self?.player.pause()
                self?.player.seek(to: startTime)
            }
        }
    }
}

// MARK: IBAction
private extension VideoTrimmingViewController {
    @IBAction func trimButtonTapped(_ sender: UIButton) {
        playTrimmedSection()
    }
}
