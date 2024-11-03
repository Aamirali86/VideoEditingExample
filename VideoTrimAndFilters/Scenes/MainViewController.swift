//
//  MainViewController.swift
//  VideoTrimAndFilters
//
//  Created by Aamir on 02/11/2024.
//

import UIKit
import Combine

final class MainViewController: UIViewController {
    private let viewModel = MainViewModel()
    @IBOutlet private var thumbnailView: UIImageView!
    private var cancellables = Set<AnyCancellable>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupImageView()
        setupNavigationBarButton()
        
        viewModel.$thumbnailImage
            .compactMap { $0 }
            .receive(on: DispatchQueue.main)
            .assign(to: \.image, on: thumbnailView)
            .store(in: &cancellables)
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
        let vm = VideoTrimmingViewModel(videoURL: url)
        vc.viewModel = vm
        present(vc, animated: true)
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
            viewModel.generateThumbnail(for: videoURL)
        }
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}
