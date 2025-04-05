// TitlePreviewViewController.swift
// Netflix_Clone
//
// Created by mohamed reda oumahdi on 21/04/2024.
// Updated with watchlist functionality
//

import UIKit
import WebKit

class TitlePreviewViewController: UIViewController {
    
    // MARK: - Properties
       
    private var viewModel: TitlePreviewViewModel?
    private var castMembers: [Cast] = []
    private var recommendations: [Title] = []
    private var isInWatchlist = false
       
    // Public method to get the view model
    func getViewModel() -> TitlePreviewViewModel? {
        return viewModel
    }
       
    // MARK: - UI Components
       
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = false
        return scrollView
    }()
       
    private let contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
       
    private let webView: WKWebView = {
        let webView = WKWebView()
        webView.translatesAutoresizingMaskIntoConstraints = false
        return webView
    }()
       
    private let titleContainerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    // Update the titleLabel to be in the container
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 22, weight: .bold)
        label.textColor = .label
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    // Update the watchlistButton to be in the container
    private let watchlistButton: UIButton = {
        var configuration = UIButton.Configuration.filled()
        configuration.baseBackgroundColor = .systemBlue
        configuration.baseForegroundColor = .white
        configuration.cornerStyle = .medium
        configuration.buttonSize = .medium
        
        configuration.title = "Remove"
        configuration.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
            var outgoing = incoming
            outgoing.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
            return outgoing
        }
        
        configuration.image = UIImage(systemName: "checkmark")
        configuration.imagePlacement = .leading
        configuration.imagePadding = 8
        
        let button = UIButton(configuration: configuration)
        button.translatesAutoresizingMaskIntoConstraints = false
        
        return button
    }()
       
    private let overviewLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15, weight: .regular)
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
    
    private let buttonsContainerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
//    private let watchlistButton: UIButton = {
//        let button = UIButton(type: .system)
//        button.setTitle("Add to Watchlist", for: .normal)
//        button.setImage(UIImage(systemName: "plus"), for: .normal)
//        button.tintColor = .white
//        button.backgroundColor = .systemGray
//        button.layer.cornerRadius = 8
//        button.translatesAutoresizingMaskIntoConstraints = false
//        return button
//    }()
       
    private let castLabel: UILabel = {
        let label = UILabel()
        label.text = "Cast"
        label.font = .systemFont(ofSize: 18, weight: .bold)
        label.textColor = .label
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
       
    private let castCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: 100, height: 140)
        layout.minimumInteritemSpacing = 10
        layout.minimumLineSpacing = 10
        layout.sectionInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .systemBackground
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()
       
    private let recommendationsLabel: UILabel = {
        let label = UILabel()
        label.text = "More Like This"
        label.font = .systemFont(ofSize: 18, weight: .bold)
        label.textColor = .label
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
       
    private let recommendationsCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: 120, height: 180)
        layout.minimumInteritemSpacing = 10
        layout.minimumLineSpacing = 10
        layout.sectionInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .systemBackground
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()
       
    // MARK: - Lifecycle Methods
       
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "Details"
        
        setupUI()
        setupCollectionViews()
        setupActions()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // Debug log the frames after layout
        print("Layout complete:")
        print("- Cast Collection View Frame: \(castCollectionView.frame)")
        print("- Cast Collection View Hidden: \(castCollectionView.isHidden)")
        print("- Content View Frame: \(contentView.frame)")
        print("- Scroll View Content Size: \(scrollView.contentSize)")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Force layout update
        view.layoutIfNeeded()
        
        // Make sure cast section is visible if we have data
        if !castMembers.isEmpty {
            castLabel.isHidden = false
            castCollectionView.isHidden = false
            castCollectionView.reloadData()
        }
        
        // Make sure recommendations section is visible if we have data
        if !recommendations.isEmpty {
            recommendationsLabel.isHidden = false
            recommendationsCollectionView.isHidden = false
            recommendationsCollectionView.reloadData()
        }
    }
       
    // MARK: - Setup Methods
       
    private func setupUI() {
        // Add scrollView and contentView
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        // Add the webView to the contentView first
        contentView.addSubview(webView)
        
        // Add titleContainerView to contentView
        contentView.addSubview(titleContainerView)
        
        // Add title and button to the container
        titleContainerView.addSubview(titleLabel)
        titleContainerView.addSubview(watchlistButton)
        
        // Add the rest of the components
        contentView.addSubview(infoLabel)
        contentView.addSubview(genreStackView)
        contentView.addSubview(overviewLabel)
        
        contentView.addSubview(castLabel)
        contentView.addSubview(castCollectionView)
        contentView.addSubview(recommendationsLabel)
        contentView.addSubview(recommendationsCollectionView)
        
        // Configure constraints
        configureConstraints()
    }
    
    private func setupCollectionViews() {
        // Register cell classes
        castCollectionView.register(CastCollectionViewCell.self, forCellWithReuseIdentifier: CastCollectionViewCell.identifier)
        recommendationsCollectionView.register(TitleCollectionViewCell.self, forCellWithReuseIdentifier: TitleCollectionViewCell.identifier)
        
        // Set delegate and data source
        castCollectionView.delegate = self
        castCollectionView.dataSource = self
        recommendationsCollectionView.delegate = self
        recommendationsCollectionView.dataSource = self
        
        // Initially hide sections until we have data
        castLabel.isHidden = true
        castCollectionView.isHidden = true
        recommendationsLabel.isHidden = true
        recommendationsCollectionView.isHidden = true
    }
    
    private func setupActions() {
        // Add button actions
        watchlistButton.addTarget(self, action: #selector(watchlistButtonTapped), for: .touchUpInside)
    }
    
    private func configureConstraints() {
        // ScrollView and ContentView constraints
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])
        
        // WebView constraints - ensure it's constrained to contentView
        NSLayoutConstraint.activate([
            webView.topAnchor.constraint(equalTo: contentView.topAnchor),
            webView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            webView.heightAnchor.constraint(equalToConstant: 300)
        ])
        
        // Remaining constraints stay the same as in the original implementation
        NSLayoutConstraint.activate([
            titleContainerView.topAnchor.constraint(equalTo: webView.bottomAnchor, constant: 20),
            titleContainerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            titleContainerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20)
        ])
        
        // Title and button constraints inside the container
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: titleContainerView.topAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: titleContainerView.leadingAnchor),
            titleLabel.bottomAnchor.constraint(equalTo: titleContainerView.bottomAnchor),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: watchlistButton.leadingAnchor, constant: -12),
            
            watchlistButton.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
            watchlistButton.trailingAnchor.constraint(equalTo: titleContainerView.trailingAnchor),
            watchlistButton.heightAnchor.constraint(equalToConstant: 36),
            watchlistButton.widthAnchor.constraint(lessThanOrEqualToConstant: 150)
        ])
        
        // Remaining constraints continue as in the original implementation
        NSLayoutConstraint.activate([
            infoLabel.topAnchor.constraint(equalTo: titleContainerView.bottomAnchor, constant: 12),
            infoLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            infoLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20)
        ])
        
        // The rest of the constraints remain the same
        NSLayoutConstraint.activate([
            genreStackView.topAnchor.constraint(equalTo: infoLabel.bottomAnchor, constant: 12),
            genreStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            genreStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20)
        ])
        
        NSLayoutConstraint.activate([
            overviewLabel.topAnchor.constraint(equalTo: genreStackView.bottomAnchor, constant: 16),
            overviewLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            overviewLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20)
        ])
        
        // Update the castLabel to connect to the overviewLabel
        NSLayoutConstraint.activate([
            castLabel.topAnchor.constraint(equalTo: overviewLabel.bottomAnchor, constant: 24),
            castLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            castLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20)
        ])
        
        // The rest of the constraints remain the same
        NSLayoutConstraint.activate([
            castCollectionView.topAnchor.constraint(equalTo: castLabel.bottomAnchor, constant: 12),
            castCollectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            castCollectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            castCollectionView.heightAnchor.constraint(equalToConstant: 140)
        ])
        
        NSLayoutConstraint.activate([
            recommendationsLabel.topAnchor.constraint(equalTo: castCollectionView.bottomAnchor, constant: 24),
            recommendationsLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            recommendationsLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            recommendationsCollectionView.topAnchor.constraint(equalTo: recommendationsLabel.bottomAnchor, constant: 12),
            recommendationsCollectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            recommendationsCollectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            recommendationsCollectionView.heightAnchor.constraint(equalToConstant: 180),
            recommendationsCollectionView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -30)
        ])
    }
    
    // MARK: - Action Methods
    
    @objc private func playButtonTapped() {
        // Check if there's a trailer available
        guard let videoElement = viewModel?.youtubeView else {
            // Show alert if no trailer available
            let alert = UIAlertController(
                title: "No Trailer Available",
                message: "No trailer is available for this title",
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
            return
        }
        
        // Create and present video player
        if let videoPlayerVC = VideoPlayerViewController.createWithYouTubeID(videoElement.id.videoId, title: viewModel?.title ?? "") {
            present(videoPlayerVC, animated: true)
        }
    }
    
    @objc private func watchlistButtonTapped() {
        guard let viewModel = viewModel else { return }
        
        // Create a title object from the view model
        let title = createTitleFromViewModel(viewModel)
        
        // Add haptic feedback
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.prepare()
        generator.impactOccurred()
        
        if isInWatchlist {
            // Remove from watchlist
            removeFromWatchlist(title: title)
        } else {
            // Add to watchlist
            addToWatchlist(title: title)
        }
    }
    
    // MARK: - Watchlist Methods
    
    private func addToWatchlist(title: Title) {
        WatchlistManager.shared.addToWatchlist(title: title) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    // Update button state
                    self?.isInWatchlist = true
                    self?.updateWatchlistButtonAppearance()
                    
                    // Show success notification
                    NotificationBanner.showSuccess(
                        title: "Added to My List",
                        subtitle: "\(title.displayTitle) has been added to your watchlist"
                    )
                    
                    // Notify observers that watchlist was updated
                    NotificationCenter.default.post(name: .watchlistUpdated, object: nil)
                    
                case .failure(let error):
                    // Show error notification
                    NotificationBanner.showError(
                        title: "Error",
                        subtitle: error.localizedDescription
                    )
                }
            }
        }
    }
    
    private func removeFromWatchlist(title: Title) {
        WatchlistManager.shared.removeFromWatchlist(id: title.id) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    // Update button state
                    self?.isInWatchlist = false
                    self?.updateWatchlistButtonAppearance()
                    
                    // Show success notification
                    NotificationBanner.showInfo(
                        title: "Removed from My List",
                        subtitle: "\(title.displayTitle) has been removed from your watchlist"
                    )
                    
                    // Notify observers that watchlist was updated
                    NotificationCenter.default.post(name: .watchlistUpdated, object: nil)
                    
                case .failure(let error):
                    // Show error notification
                    NotificationBanner.showError(
                        title: "Error",
                        subtitle: error.localizedDescription
                    )
                }
            }
        }
    }
    
    private func updateWatchlistButtonAppearance() {
        var configuration = watchlistButton.configuration ?? .filled()
        
        if isInWatchlist {
            configuration.title = "Remove"
            configuration.image = UIImage(systemName: "checkmark")
            configuration.baseBackgroundColor = .systemBlue
            configuration.baseForegroundColor = .white
        } else {
            configuration.title = "Add to List"
            configuration.image = UIImage(systemName: "plus")
            configuration.baseBackgroundColor = .secondarySystemBackground
            configuration.baseForegroundColor = .label
        }
        
        configuration.cornerStyle = .medium
        configuration.buttonSize = .medium
        configuration.imagePlacement = .leading
        configuration.imagePadding = 8
        
        configuration.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
            var outgoing = incoming
            outgoing.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
            return outgoing
        }
        
        watchlistButton.configuration = configuration
    }
    
    private func checkWatchlistStatus(for id: Int) {
        isInWatchlist = WatchlistManager.shared.isTitleInWatchlist(id: id)
        updateWatchlistButtonAppearance()
    }
    
    private func createTitleFromViewModel(_ viewModel: TitlePreviewViewModel) -> Title {
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
                    //firstAirDate: tvDetail.firstAirDate,
                    voteAverage: tvDetail.voteAverage,
                    backdropPath: tvDetail.backdropPath
                )
            } else {
                // Fallback with minimal information
                return Title(
                    id: viewModel.movieDetail?.id ?? viewModel.tvShowDetail?.id ?? 0,
                    mediaType: viewModel.movieDetail != nil ? "movie" : "tv",
                    originalName: viewModel.tvShowDetail?.name,
                    originalTitle: viewModel.movieDetail?.title,
                    posterPath: viewModel.movieDetail?.posterPath ?? viewModel.tvShowDetail?.posterPath,
                    overview: viewModel.titleOverview,
                    releaseDate: viewModel.releaseDate
                )
            }
        }
    
    // MARK: - Cast Configuration Method
        
    private func configureCastSection(with model: TitlePreviewViewModel) {
        // Reset cast-related views
        castMembers.removeAll()
        
        // Debug: Log cast source
        print("🎬 Configuring Cast Section")
        print("Movie Detail: \(model.movieDetail != nil)")
        print("TV Show Detail: \(model.tvShowDetail != nil)")
        
        // Determine cast source
        let castSource = model.movieDetail?.credits?.cast ?? model.tvShowDetail?.credits?.cast
        let titleType = model.movieDetail != nil ? "Movie" : "TV Show"
        
        // Process cast
        if let cast = castSource, !cast.isEmpty {
            print("🎭 \(titleType) Cast:")
            print("Total cast members found: \(cast.count)")
            
            // Filter and sort cast
            let filteredCast = cast
                .prefix(10)
                .sorted(by: { $0.order < $1.order })
            
            // Debug: Log cast members
            filteredCast.forEach { member in
                print("- \(member.name) as \(member.character ?? "Unknown Role") [Order: \(member.order)]")
            }
            
            // Update cast members
            self.castMembers = Array(filteredCast)
            
            // Show cast section if we have members
            if !self.castMembers.isEmpty {
                // Make cast section visible
                DispatchQueue.main.async {
                    self.castLabel.isHidden = false
                    self.castCollectionView.isHidden = false
                    self.castCollectionView.reloadData()
                    
                    // Force layout update
                    self.view.setNeedsLayout()
                    self.view.layoutIfNeeded()
                }
            }
        } else {
            print("⚠️ No cast information available for \(titleType)")
            // Hide the cast section if no cast available
            castLabel.isHidden = true
            castCollectionView.isHidden = true
        }
        
        // Debug log
        print("🎨 Cast Configuration Complete")
        print("Cast Members Count: \(castMembers.count)")
        print("Cast Label Hidden: \(castLabel.isHidden)")
        print("Cast Collection Hidden: \(castCollectionView.isHidden)")
    }
        
    // MARK: - Main Configuration Method
        
    public func configure(with model: TitlePreviewViewModel) {
        self.viewModel = model
        
        // Set title of the view controller
        self.navigationItem.title = "Details"
        
        // Set title and overview
        titleLabel.text = model.title
        overviewLabel.text = model.titleOverview
        
        // Add additional info if available
        var infoText = ""
        
        if let releaseDate = model.releaseDate {
            infoText += "Released: \(releaseDate)"
        }
        
        if let voteAverage = model.voteAverage {
            if !infoText.isEmpty {
                infoText += " • "
            }
            
            infoText += "Rating: \(String(format: "%.1f", voteAverage))/10"
        }
        
        if let runtime = model.runtime {
            if !infoText.isEmpty {
                infoText += " • "
            }
            
            infoText += "\(runtime)"
        }
        
        infoLabel.text = infoText
        
        // Setup genre tags if available
        if let genres = model.genres, !genres.isEmpty {
            // Clear any existing genre pills
            genreStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
            
            // Create a genre pill for each genre (up to 3)
            for genre in genres.prefix(3) {
                let genrePill = createGenrePill(genre)
                genreStackView.addArrangedSubview(genrePill)
            }
            
            if genres.count > 3 {
                let morePill = createGenrePill("+\(genres.count - 3) more")
                genreStackView.addArrangedSubview(morePill)
            }
            
            // Show the genre stack
            genreStackView.isHidden = false
        } else {
            // Hide the genre stack if no genres
            genreStackView.isHidden = true
        }
        
        // Check if this title is in the watchlist
        let titleId = model.movieDetail?.id ?? model.tvShowDetail?.id ?? 0
        checkWatchlistStatus(for: titleId)
        
        // Configure cast section
        configureCastSection(with: model)
        
        // Set recommendations if available
        let similarTitles = model.movieDetail?.similar?.results ?? model.tvShowDetail?.similar?.results ?? []
        if !similarTitles.isEmpty {
            self.recommendations = similarTitles.prefix(10).map { $0 }
            recommendationsLabel.isHidden = false
            recommendationsCollectionView.isHidden = false
            recommendationsCollectionView.reloadData()
        } else {
            recommendationsLabel.isHidden = true
            recommendationsCollectionView.isHidden = true
        }
        
        // Load YouTube video if available
        if let videoElement = model.youtubeView {
            let videoId = videoElement.id.videoId
            
            let urlString = "\(Configuration.URLs.YOUTUBE_EMBED_URL)\(videoId)"
            guard let url = URL(string: urlString) else {
                return
            }
            
            // Add loading indicator to webView
            let spinner = UIActivityIndicatorView(style: .large)
            spinner.color = .white
            spinner.translatesAutoresizingMaskIntoConstraints = false
            webView.addSubview(spinner)
            
            NSLayoutConstraint.activate([
                spinner.centerXAnchor.constraint(equalTo: webView.centerXAnchor),
                spinner.centerYAnchor.constraint(equalTo: webView.centerYAnchor)
            ])
            
            spinner.startAnimating()
            
            // Now load the URL
            webView.load(URLRequest(url: url))
            
            // Set webView navigation delegate to hide spinner when loaded
            webView.navigationDelegate = self
        }
    }
        
    // MARK: - Helper Methods
        
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
}

// MARK: - UICollectionViewDelegate, UICollectionViewDataSource

extension TitlePreviewViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == castCollectionView {
            let count = castMembers.count
            print("🔍 Cast Collection View - Number of Items: \(count)")
            return count
        } else if collectionView == recommendationsCollectionView {
            let count = recommendations.count
            print("🔍 Recommendations Collection View - Number of Items: \(count)")
            return count
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == castCollectionView {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CastCollectionViewCell.identifier, for: indexPath) as? CastCollectionViewCell else {
                print("❌ Failed to dequeue CastCollectionViewCell")
                return UICollectionViewCell()
            }
            
            let castMember = castMembers[indexPath.item]
            print("🎭 Configuring Cast Cell: \(castMember.name)")
            cell.configure(with: castMember)
            return cell
            
        } else if collectionView == recommendationsCollectionView {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TitleCollectionViewCell.identifier, for: indexPath) as? TitleCollectionViewCell else {
                return UICollectionViewCell()
            }
            let title = recommendations[indexPath.item]
            let viewModel = TitleViewModel(
                titleName: title.originalTitle ?? title.originalName ?? "",
                posterURL: title.posterPath ?? "",
                releaseDate: title.releaseDate
            )
            
            cell.configure(with: viewModel)
            return cell
        }
        
        return UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        
        if collectionView == recommendationsCollectionView {
            let title = recommendations[indexPath.item]
            
            // Show loading indicator
            LoadingView.shared.showLoading(in: view, withText: "Loading...")
            
            // Get detailed title information
            ContentService.shared.loadDetailedTitle(for: title) { [weak self] result in
                // Hide loading
                DispatchQueue.main.async {
                    LoadingView.shared.hideLoading()
                }
                
                switch result {
                case .success(let viewController):
                    DispatchQueue.main.async {
                        self?.navigationController?.pushViewController(viewController, animated: true)
                    }
                case .failure(let error):
                    DispatchQueue.main.async {
                        ErrorPresenter.showError(error, on: self!)
                    }
                }
            }
        }
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension TitlePreviewViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == castCollectionView {
            return CGSize(width: 100, height: 140)
        } else if collectionView == recommendationsCollectionView {
            return CGSize(width: 120, height: 180)
        }
        return .zero
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        // Provide section insets for proper padding
        return UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
    }
}

// MARK: - WKNavigationDelegate

extension TitlePreviewViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        // Hide loading indicator when web view finishes loading
        if let spinner = webView.subviews.first(where: { $0 is UIActivityIndicatorView }) as? UIActivityIndicatorView {
            UIView.animate(withDuration: 0.3, animations: {
                spinner.alpha = 0
            }, completion: { _ in
                spinner.removeFromSuperview()
            })
        }
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        // Handle navigation failure
        if let spinner = webView.subviews.first(where: { $0 is UIActivityIndicatorView }) as? UIActivityIndicatorView {
            spinner.removeFromSuperview()
        }
        
        // Show error message in web view
        let errorLabel = UILabel()
        errorLabel.text = "Failed to load video"
        errorLabel.textAlignment = .center
        errorLabel.textColor = .white
        errorLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let errorView = UIView(frame: webView.bounds)
        errorView.backgroundColor = .black
        errorView.addSubview(errorLabel)
        webView.addSubview(errorView)
        
        NSLayoutConstraint.activate([
            errorLabel.centerXAnchor.constraint(equalTo: errorView.centerXAnchor),
            errorLabel.centerYAnchor.constraint(equalTo: errorView.centerYAnchor)
        ])
    }
}
