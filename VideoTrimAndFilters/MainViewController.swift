//
//  MainViewController.swift
//  VideoTrimAndFilters
//
//  Created by Aamir on 02/11/2024.
//

import UIKit
import AVKit

class MainViewController: UIViewController {
    @IBOutlet private var thumbnailView: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupImageView()
        setupNavigationBarButton()
    }
}

// MARK: UI
private extension MainViewController {
    func setupNavigationBarButton() {
        let button = UIBarButtonItem(title: "Tap Me", style: .plain, target: self, action: #selector(barButtonTapped))
        navigationItem.rightBarButtonItem = button
        navigationItem.title = "Video Editing app"
    }
    
    func setupImageView() {
        thumbnailView.contentMode = .scaleAspectFill
        thumbnailView.clipsToBounds = true
    }
}

// MARK: Helper
private extension MainViewController {
    func previewVideo(url: URL) {
        let storyboard = UIStoryboard(name: "VideoTrimmingViewController", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "VideoTrimmingViewController") as! VideoTrimmingViewController
        vc.videoURL = url
        present(vc, animated: true)
    }
    
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
                self?.thumbnailView.image = UIImage(cgImage: image)
            }
        }
    }
}

// MARK: Action
private extension MainViewController {
    @objc private func barButtonTapped() {
        selectVideoFromGallery()
    }

    @IBAction func selectVideoFromGallery() {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.mediaTypes = ["public.movie"]
        imagePickerController.sourceType = .photoLibrary
        present(imagePickerController, animated: true, completion: nil)
    }
}

// MARK: Image picker Delegate
extension MainViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        
        if let videoURL = info[.mediaURL] as? URL {
            previewVideo(url: videoURL)
            generateThumbnail(for: videoURL)
        }
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}
