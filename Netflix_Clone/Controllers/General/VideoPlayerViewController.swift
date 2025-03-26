// VideoPlayerViewController.swift
// Netflix_Clone
//
// Created by mohamed reda oumahdi on 28/03/2025.
//

import UIKit
import AVKit
import AVFoundation

class VideoPlayerViewController: UIViewController {
    
    // MARK: - Properties
    
    private var videoURL: URL
    private var videoTitle: String
    private var playerController: AVPlayerViewController?
    private var player: AVPlayer?
    
    // UI Elements
    private let closeButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "xmark.circle.fill"), for: .normal)
        button.tintColor = .white
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = DesignSystem.Typography.subtitle
        label.numberOfLines = 2
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        label.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        label.layer.cornerRadius = 8
        label.clipsToBounds = true
        return label
    }()
    
    private let controlsContainer: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.alpha = 0 // Hidden initially
        return view
    }()
    
    private let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.color = .white
        indicator.hidesWhenStopped = true
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }()
    
    // MARK: - Initialization
    
    init(videoURL: URL, title: String) {
        self.videoURL = videoURL
        self.videoTitle = title
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .fullScreen
        modalTransitionStyle = .crossDissolve
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupPlayer()
        setupUI()
        setupGestures()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        player?.play()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        player?.pause()
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    // MARK: - Setup Methods
    
    private func setupPlayer() {
        // Create player
        player = AVPlayer(url: videoURL)
        
        // Add observer for buffering state
        player?.addObserver(self, forKeyPath: "timeControlStatus", options: [.old, .new], context: nil)
        
        // Setup player controller for full playback controls
        playerController = AVPlayerViewController()
        playerController?.player = player
        playerController?.view.frame = view.bounds
        playerController?.showsPlaybackControls = true
        
        // Add player controller as child
        if let playerController = playerController {
            addChild(playerController)
            view.addSubview(playerController.view)
            playerController.didMove(toParent: self)
            
            // Set constraints
            playerController.view.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                playerController.view.topAnchor.constraint(equalTo: view.topAnchor),
                playerController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                playerController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                playerController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
            ])
        }
        
        // Start playing
        player?.play()
    }
    
    private func setupUI() {
        view.backgroundColor = .black
        
        // Add loading indicator
        view.addSubview(activityIndicator)
        activityIndicator.startAnimating()
        
        // Add close button
        view.addSubview(closeButton)
        closeButton.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
        
        // Add title label
        view.addSubview(titleLabel)
        titleLabel.text = videoTitle
        titleLabel.alpha = 0
        
        // Setup constraints
        NSLayoutConstraint.activate([
            // Activity indicator
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            // Close button
            closeButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            closeButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            closeButton.widthAnchor.constraint(equalToConstant: 44),
            closeButton.heightAnchor.constraint(equalToConstant: 44),
            
            // Title label
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32),
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16)
        ])
        
        // Fade in title after a delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            UIView.animate(withDuration: 0.5) {
                self.titleLabel.alpha = 1.0
            }
            
            // Auto-hide title after 3 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                UIView.animate(withDuration: 0.5) {
                    self.titleLabel.alpha = 0.0
                }
            }
        }
    }
    
    private func setupGestures() {
        // Add tap gesture to toggle controls visibility
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        view.addGestureRecognizer(tapGesture)
        
        // Add swipe down gesture to dismiss
        let swipeDownGesture = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipeDown))
        swipeDownGesture.direction = .down
        view.addGestureRecognizer(swipeDownGesture)
    }
    
    // MARK: - Action Methods
    
    @objc private func closeButtonTapped() {
        dismiss(animated: true)
    }
    
    @objc private func handleTap() {
        // Toggle title visibility
        UIView.animate(withDuration: 0.3) {
            self.titleLabel.alpha = self.titleLabel.alpha == 0 ? 1.0 : 0.0
        }
        
        // Also toggle the AVPlayerViewController controls
        if let playerController = playerController {
            playerController.showsPlaybackControls.toggle()
        }
    }
    
    @objc private func handleSwipeDown() {
        dismiss(animated: true)
    }
    
    // MARK: - Observer Methods
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "timeControlStatus", let player = player {
            DispatchQueue.main.async {
                if player.timeControlStatus == .playing {
                    self.activityIndicator.stopAnimating()
                } else {
                    self.activityIndicator.startAnimating()
                }
            }
        }
    }
    
    // MARK: - Cleanup
    
    deinit {
        player?.removeObserver(self, forKeyPath: "timeControlStatus")
        NotificationCenter.default.removeObserver(self)
    }
}

// MARK: - Factory Method

extension VideoPlayerViewController {
    /// Factory method to create VideoPlayerViewController from a YouTube video ID
    static func createWithYouTubeID(_ videoID: String, title: String) -> VideoPlayerViewController? {
        // For YouTube videos, use the embedded URL format
        guard let url = URL(string: "https://www.youtube.com/embed/\(videoID)") else {
            return nil
        }
        
        return VideoPlayerViewController(videoURL: url, title: title)
    }
}
