//
//  VideoTrimmingViewController.swift
//  VideoTrimAndFilters
//
//  Created by Aamir on 03/11/2024.
//

import AVFoundation
import UIKit
import Combine

final class VideoTrimmingViewController: UIViewController {
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var trimButton: UIButton!
    @IBOutlet weak var rangeSlider: RangeSlider!

    var viewModel: VideoTrimmingViewModel!
    private var cancellables = Set<AnyCancellable>()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel.$player
            .sink { [weak self] player in
                guard let self = self, let player = player else { return }
                let playerLayer = AVPlayerLayer(player: player)
                playerLayer.frame = containerView.bounds
                playerLayer.videoGravity = .resizeAspect
                containerView.layer.addSublayer(playerLayer)
            }
            .store(in: &cancellables)
    }
}

// MARK: IBAction
private extension VideoTrimmingViewController {
    @IBAction func trimButtonTapped(_ sender: UIButton) {
        viewModel.onTrim.send((rangeSlider.startValue, rangeSlider.endValue))
    }
}
