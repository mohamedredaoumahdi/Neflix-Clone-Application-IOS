// TitlePreviewViewController.swift
// Netflix_Clone
//
// Created by mohamed reda oumahdi on 21/04/2024.
// Updated on 27/03/2025.
//

import UIKit
import WebKit

class TitlePreviewViewController: UIViewController {
    
    // MARK: - Properties
    
    private var viewModel: TitlePreviewViewModel?
    private var castMembers: [Cast] = []
    private var recommendations: [Title] = []
    
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
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 22, weight: .bold)
        label.textColor = .label
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
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
        setupUI()
        setupCollectionViews()
    }
    
    // MARK: - Setup Methods
    
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
    
    private func setupUI() {
        // Add scrollView and contentView
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        // Add components to contentView
        contentView.addSubview(webView)
        contentView.addSubview(titleLabel)
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
        
        // WebView constraints
        NSLayoutConstraint.activate([
            webView.topAnchor.constraint(equalTo: contentView.topAnchor),
            webView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            webView.heightAnchor.constraint(equalToConstant: 300)
        ])
        
        // TitleLabel constraints
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: webView.bottomAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20)
        ])
        
        // InfoLabel constraints
        NSLayoutConstraint.activate([
            infoLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 12),
            infoLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            infoLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20)
        ])
        
        // GenreStackView constraints
        NSLayoutConstraint.activate([
            genreStackView.topAnchor.constraint(equalTo: infoLabel.bottomAnchor, constant: 12),
            genreStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            genreStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20)
        ])
        
        // OverviewLabel constraints
        NSLayoutConstraint.activate([
            overviewLabel.topAnchor.constraint(equalTo: genreStackView.bottomAnchor, constant: 16),
            overviewLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            overviewLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20)
        ])
        
        // Cast section constraints
        NSLayoutConstraint.activate([
            castLabel.topAnchor.constraint(equalTo: overviewLabel.bottomAnchor, constant: 24),
            castLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            
            castCollectionView.topAnchor.constraint(equalTo: castLabel.bottomAnchor, constant: 12),
            castCollectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            castCollectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            castCollectionView.heightAnchor.constraint(equalToConstant: 140)
        ])
        
        // Recommendations section constraints
        NSLayoutConstraint.activate([
            recommendationsLabel.topAnchor.constraint(equalTo: castCollectionView.bottomAnchor, constant: 24),
            recommendationsLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            
            recommendationsCollectionView.topAnchor.constraint(equalTo: recommendationsLabel.bottomAnchor, constant: 12),
            recommendationsCollectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            recommendationsCollectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            recommendationsCollectionView.heightAnchor.constraint(equalToConstant: 180),
            recommendationsCollectionView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -30)
        ])
    }
    
    // MARK: - Public Methods
    
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
            // Format the date if needed
            infoText += "Released: \(releaseDate)"
        }
        
        if let voteAverage = model.voteAverage {
            // Add a separator if we already have release date
            if !infoText.isEmpty {
                infoText += " • "
            }
            
            infoText += "Rating: \(String(format: "%.1f", voteAverage))/10"
        }
        
        if let runtime = model.runtime {
            // Add a separator if we already have other info
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
        
        // Set cast if available
        if let movieDetail = model.movieDetail {
            if let cast = movieDetail.credits?.cast, !cast.isEmpty {
                self.castMembers = cast.prefix(10).sorted(by: { $0.order < $1.order })
                castLabel.isHidden = false
                castCollectionView.isHidden = false
                castCollectionView.reloadData()
            }
            
            // Set recommendations if available
            if let similar = movieDetail.similar?.results, !similar.isEmpty {
                self.recommendations = similar.prefix(10).map { $0 }
                recommendationsLabel.isHidden = false
                recommendationsCollectionView.isHidden = false
                recommendationsCollectionView.reloadData()
            }
        } else if let tvDetail = model.tvShowDetail {
            if let cast = tvDetail.credits?.cast, !cast.isEmpty {
                self.castMembers = cast.prefix(10).sorted(by: { $0.order < $1.order })
                castLabel.isHidden = false
                castCollectionView.isHidden = false
                castCollectionView.reloadData()
            }
            
            // Set recommendations if available
            if let similar = tvDetail.similar?.results, !similar.isEmpty {
                self.recommendations = similar.prefix(10).map { $0 }
                recommendationsLabel.isHidden = false
                recommendationsCollectionView.isHidden = false
                recommendationsCollectionView.reloadData()
            }
        }
        
        // Load YouTube video if available
        if let videoElement = model.youtubeView {
            let videoId = videoElement.id.videoId
            
            // Create URL outside the guard statement so it's available in the wider scope
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
            return castMembers.count
        } else if collectionView == recommendationsCollectionView {
            return recommendations.count
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == castCollectionView {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CastCollectionViewCell.identifier, for: indexPath) as? CastCollectionViewCell else {
                return UICollectionViewCell()
            }
            
            let castMember = castMembers[indexPath.item]
            cell.configure(with: castMember)
            return cell
            
        } else if collectionView == recommendationsCollectionView {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TitleCollectionViewCell.identifier, for: indexPath) as? TitleCollectionViewCell else {
                return UICollectionViewCell()
            }
            
            let title = recommendations[indexPath.item]
            if let posterPath = title.posterPath {
                cell.configure(with: posterPath)
            }
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
