// ContentDetailBottomSheet.swift
// Netflix_Clone
//

import UIKit

class ContentDetailBottomSheet: UIViewController {
    
    // MARK: - Properties
    
    private var viewModel: TitlePreviewViewModel
    private var initialHeight: CGFloat = 0
    private var targetHeight: CGFloat = 0
    private var currentHeight: CGFloat = 0
    private var panGestureRecognizer: UIPanGestureRecognizer!
    
    private var runningAnimators: [UIViewPropertyAnimator] = []
    private var animationProgress: [CGFloat] = []
    
    private let dimmedBackgroundView = UIView()
    private let contentView = UIView()
    private let grabberView = UIView()
    
    // MARK: - UI Components
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = false
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()
    
    private let containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let posterImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 8
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 24, weight: .bold)
        label.textColor = .label
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let infoLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.textColor = .secondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let genreStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 8
        stackView.alignment = .center
        stackView.distribution = .fillProportionally
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private let overviewLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15, weight: .regular)
        label.textColor = .label
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let playButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Play", for: .normal)
        button.setImage(UIImage(systemName: "play.fill"), for: .normal)
        button.tintColor = .white
        button.backgroundColor = .systemRed
        button.layer.cornerRadius = 8
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let addToListButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("My List", for: .normal)
        button.setImage(UIImage(systemName: "plus"), for: .normal)
        button.tintColor = .white
        button.backgroundColor = UIColor.gray.withAlphaComponent(0.3)
        button.layer.cornerRadius = 8
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let closeButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "xmark.circle.fill"), for: .normal)
        button.tintColor = .lightGray
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // MARK: - Initialization
    
    init(with viewModel: TitlePreviewViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .overFullScreen
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
        setupConstraints()
        setupGestures()
        configureWithViewModel()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        animatePresentation()
    }
    
    // MARK: - Setup Methods
    
    private func setupViews() {
        view.backgroundColor = .clear
        
        // Dimmed background
        dimmedBackgroundView.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        dimmedBackgroundView.alpha = 0
        dimmedBackgroundView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(dimmedBackgroundView)
        
        // Content view setup
        contentView.backgroundColor = .systemBackground
        contentView.layer.cornerRadius = 16
        contentView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        contentView.clipsToBounds = true
        contentView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(contentView)
        
        // Grabber view
        grabberView.backgroundColor = .systemGray3
        grabberView.layer.cornerRadius = 2.5
        grabberView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(grabberView)
        
        // Add scroll view to content view
        contentView.addSubview(scrollView)
        
        // Add container view to scroll view
        scrollView.addSubview(containerView)
        
        // Add content components to container view
        containerView.addSubview(posterImageView)
        containerView.addSubview(titleLabel)
        containerView.addSubview(infoLabel)
        containerView.addSubview(genreStackView)
        containerView.addSubview(overviewLabel)
        containerView.addSubview(playButton)
        containerView.addSubview(addToListButton)
        
        // Add close button
        contentView.addSubview(closeButton)
        closeButton.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
        
        // Add actions
        playButton.addTarget(self, action: #selector(playButtonTapped), for: .touchUpInside)
        addToListButton.addTarget(self, action: #selector(addToListButtonTapped), for: .touchUpInside)
    }
    
    private func setupConstraints() {
        // Calculate heights
        initialHeight = view.frame.height * 0.1
        targetHeight = view.frame.height * 0.9
        currentHeight = initialHeight
        
        NSLayoutConstraint.activate([
            // Dimmed background
            dimmedBackgroundView.topAnchor.constraint(equalTo: view.topAnchor),
            dimmedBackgroundView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            dimmedBackgroundView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            dimmedBackgroundView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            // Content view
            contentView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            contentView.heightAnchor.constraint(equalToConstant: targetHeight),
            
            // Grabber view
            grabberView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            grabberView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            grabberView.widthAnchor.constraint(equalToConstant: 40),
            grabberView.heightAnchor.constraint(equalToConstant: 5),
            
            // Close button
            closeButton.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            closeButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            closeButton.widthAnchor.constraint(equalToConstant: 32),
            closeButton.heightAnchor.constraint(equalToConstant: 32),
            
            // Scroll view
            scrollView.topAnchor.constraint(equalTo: grabberView.bottomAnchor, constant: 16),
            scrollView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            
            // Container view
            containerView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            containerView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            containerView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            // Poster image
            posterImageView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 16),
            posterImageView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            posterImageView.widthAnchor.constraint(equalToConstant: 130),
            posterImageView.heightAnchor.constraint(equalToConstant: 195),
            
            // Title label
            titleLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: posterImageView.trailingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -60),
            
            // Info label
            infoLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            infoLabel.leadingAnchor.constraint(equalTo: posterImageView.trailingAnchor, constant: 16),
            infoLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
            
            // Genre stack
            genreStackView.topAnchor.constraint(equalTo: infoLabel.bottomAnchor, constant: 12),
            genreStackView.leadingAnchor.constraint(equalTo: posterImageView.trailingAnchor, constant: 16),
            genreStackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
            
            // Overview
            overviewLabel.topAnchor.constraint(equalTo: posterImageView.bottomAnchor, constant: 24),
            overviewLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            overviewLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
            
            // Play button
            playButton.topAnchor.constraint(equalTo: overviewLabel.bottomAnchor, constant: 24),
            playButton.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            playButton.heightAnchor.constraint(equalToConstant: 44),
            
            // Add to list button
            addToListButton.topAnchor.constraint(equalTo: overviewLabel.bottomAnchor, constant: 24),
            addToListButton.leadingAnchor.constraint(equalTo: playButton.trailingAnchor, constant: 16),
            addToListButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
            addToListButton.heightAnchor.constraint(equalToConstant: 44),
            addToListButton.widthAnchor.constraint(equalTo: playButton.widthAnchor),
            
            // Make sure the container view extends below the buttons
            playButton.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -40)
        ])
        
        // Set content view offscreen initially
        contentView.transform = CGAffineTransform(translationX: 0, y: targetHeight)
    }
    
    private func setupGestures() {
        // Add pan gesture for dragging
        panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(_:)))
        contentView.addGestureRecognizer(panGestureRecognizer)
        
        // Add tap gesture for dimmed background
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleBackgroundTap(_:)))
        dimmedBackgroundView.addGestureRecognizer(tapGesture)
    }
    
    private func configureWithViewModel() {
        // Set title and overview
        titleLabel.text = viewModel.title
        overviewLabel.text = viewModel.titleOverview
        
        // Set info text
        var infoText = ""
        if let releaseDate = viewModel.releaseDate {
            infoText += releaseDate
        }
        
        if let voteAverage = viewModel.voteAverage {
            if !infoText.isEmpty { infoText += " • " }
            infoText += "\(String(format: "%.1f", voteAverage))/10"
        }
        
        if let runtime = viewModel.runtime {
            if !infoText.isEmpty { infoText += " • " }
            infoText += runtime
        }
        
        infoLabel.text = infoText
        
        // Configure genre pills
        if let genres = viewModel.genres, !genres.isEmpty {
            for (index, genre) in genres.prefix(3).enumerated() {
                let pillView = createGenrePill(genre)
                genreStackView.addArrangedSubview(pillView)
                
                // Limit to 3 genres
                if index == 2 && genres.count > 3 {
                    let morePill = createGenrePill("+\(genres.count - 3) more")
                    genreStackView.addArrangedSubview(morePill)
                    break
                }
            }
        }
        
        // Load poster image
        if let posterPath = viewModel.movieDetail?.posterPath ?? viewModel.tvShowDetail?.posterPath,
           let posterURL = URL(string: "\(Configuration.URLs.TMDB_IMAGE_URL)/\(posterPath)") {
            
            posterImageView.sd_setImage(with: posterURL)
        }
        
        // Check if already in watchlist
        if let id = viewModel.movieDetail?.id ?? viewModel.tvShowDetail?.id,
           WatchlistManager.shared.isTitleInWatchlist(id: id) {
            updateAddToListButtonForWatchlist(true)
        }
    }
    
    private func createGenrePill(_ text: String) -> UIView {
        let container = UIView()
        container.backgroundColor = .systemBlue.withAlphaComponent(0.2)
        container.layer.cornerRadius = 12
        
        let label = UILabel()
        label.text = text
        label.textColor = .systemBlue
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        
        container.addSubview(label)
        
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: container.topAnchor, constant: 4),
            label.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -4),
            label.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 12),
            label.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -12)
        ])
        
        return container
    }
    
    // MARK: - Animation
    
    private func animatePresentation() {
        let animator = UIViewPropertyAnimator(duration: 0.4, dampingRatio: 0.8) {
            self.contentView.transform = .identity
            self.dimmedBackgroundView.alpha = 1
        }
        
        animator.addCompletion { _ in
            self.runningAnimators.removeAll()
        }
        
        animator.startAnimation()
        runningAnimators.append(animator)
        animationProgress.append(0)
    }
    
    private func animateDismissal(velocity: CGFloat = 0) {
        let animator = UIViewPropertyAnimator(duration: 0.4, dampingRatio: 0.8) {
            self.contentView.transform = CGAffineTransform(translationX: 0, y: self.targetHeight)
            self.dimmedBackgroundView.alpha = 0
        }
        
        animator.addCompletion { _ in
            self.dismiss(animated: false)
        }
        
        // If there's velocity, adjust the timing to make it feel more responsive
        if velocity > 0 {
            let velocityFactor = min(max(velocity / 1000, 0.5), 2.0)
            animator.continueAnimation(withTimingParameters: nil, durationFactor: 1/velocityFactor)
        } else {
            animator.startAnimation()
        }
    }
    
    // MARK: - Gesture Handling
    
    @objc private func handlePanGesture(_ recognizer: UIPanGestureRecognizer) {
        let translation = recognizer.translation(in: contentView)
        let velocity = recognizer.velocity(in: contentView)
        
        switch recognizer.state {
        case .began:
            // Cancel running animations if any
            runningAnimators.forEach { $0.stopAnimation(true) }
            runningAnimators.removeAll()
            
        case .changed:
            // Only allow dragging down
            if translation.y < 0 { return }
            
            // Apply translation
            contentView.transform = CGAffineTransform(translationX: 0, y: translation.y)
            
            // Fade out background based on progress
            let dragProgress = translation.y / targetHeight
            dimmedBackgroundView.alpha = 1 - dragProgress
            
        case .ended, .cancelled:
            // Determine whether to dismiss or snap back
            if translation.y > 100 || velocity.y > 500 {
                animateDismissal(velocity: velocity.y)
            } else {
                // Snap back
                UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .curveEaseOut) {
                    self.contentView.transform = .identity
                    self.dimmedBackgroundView.alpha = 1
                }
            }
            
        default:
            break
        }
    }
    
    @objc private func handleBackgroundTap(_ recognizer: UITapGestureRecognizer) {
        animateDismissal()
    }
    
    // MARK: - Actions
    
    @objc private func closeButtonTapped() {
        animateDismissal()
    }
    
    @objc private func playButtonTapped() {
        // Check if we have a YouTube video
        guard let videoElement = viewModel.youtubeView else {
            // Show alert if no trailer available
            let alert = UIAlertController(title: "No Trailer Available", message: "No trailer is available for this title", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
            return
        }
        
        // Play the video
        if let videoPlayerVC = VideoPlayerViewController.createWithYouTubeID(videoElement.id.videoId, title: viewModel.title) {
            present(videoPlayerVC, animated: true)
        }
    }
    
    @objc private func addToListButtonTapped() {
        guard let id = viewModel.movieDetail?.id ?? viewModel.tvShowDetail?.id else { return }
        
        if WatchlistManager.shared.isTitleInWatchlist(id: id) {
            // Remove from watchlist
            WatchlistManager.shared.removeFromWatchlist(id: id) { [weak self] result in
                DispatchQueue.main.async {
                    switch result {
                    case .success:
                        self?.updateAddToListButtonForWatchlist(false)
                        NotificationBanner.showInfo(
                            title: "Removed from My List",
                            subtitle: "This title has been removed from your list"
                        )
                    case .failure(let error):
                        NotificationBanner.showError(
                            title: "Error",
                            subtitle: error.localizedDescription
                        )
                    }
                }
            }
        } else {
            // Create a Title object from the view model
            let title = createTitleFromViewModel()
            
            // Add to watchlist
            WatchlistManager.shared.addToWatchlist(title: title) { [weak self] result in
                DispatchQueue.main.async {
                    switch result {
                    case .success:
                        self?.updateAddToListButtonForWatchlist(true)
                        NotificationBanner.showSuccess(
                            title: "Added to My List",
                            subtitle: "This title has been added to your list"
                        )
                    case .failure(let error):
                        NotificationBanner.showError(
                            title: "Error",
                            subtitle: error.localizedDescription
                        )
                    }
                }
            }
        }
    }
    
    private func updateAddToListButtonForWatchlist(_ isInWatchlist: Bool) {
        if isInWatchlist {
            addToListButton.setTitle("Remove", for: .normal)
            addToListButton.setImage(UIImage(systemName: "checkmark"), for: .normal)
        } else {
            addToListButton.setTitle("My List", for: .normal)
            addToListButton.setImage(UIImage(systemName: "plus"), for: .normal)
        }
    }
    
    private func createTitleFromViewModel() -> Title {
        if let movieDetail = viewModel.movieDetail {
            return Title(
                id: movieDetail.id,
                mediaType: "movie",
                originalTitle: movieDetail.title,
                posterPath: movieDetail.posterPath,
                overview: movieDetail.overview,
                voteCount: movieDetail.voteCount,
                releaseDate: movieDetail.releaseDate,
                voteAverage: movieDetail.voteAverage,
                backdropPath: movieDetail.backdropPath
            )
        } else if let tvDetail = viewModel.tvShowDetail {
            return Title(
                id: tvDetail.id,
                mediaType: "tv",
                originalName: tvDetail.name,
                posterPath: tvDetail.posterPath,
                overview: tvDetail.overview,
                voteCount: tvDetail.voteCount,
                releaseDate: nil,
                voteAverage: tvDetail.voteAverage,
                backdropPath: tvDetail.backdropPath
            )
        } else {
            // Fallback with minimal information
            return Title(
                id: Int.random(in: 10000...99999), // A temporary ID
                mediaType: "unknown",
                originalTitle: viewModel.title,
                overview: viewModel.titleOverview,
                releaseDate: viewModel.releaseDate
            )
        }
    }
}
