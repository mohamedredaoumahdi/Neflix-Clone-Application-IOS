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
    private var titleItem: Title?
    
    // MARK: - UI Components
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
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
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 22, weight: .bold)
        label.textColor = .label
        label.numberOfLines = 0
        return label
    }()
    
    private let overviewLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .regular)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.textColor = .label
        return label
    }()
    
    private let infoLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .secondaryLabel
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
    
    // MARK: - Lifecycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupUI()
    }
    
    // MARK: - UI Setup
    
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
            overviewLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            overviewLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20)
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

// MARK: - WKNavigationDelegate

extension TitlePreviewViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        // Hide the spinner when the web page finishes loading
        if let spinner = webView.subviews.first(where: { $0 is UIActivityIndicatorView }) as? UIActivityIndicatorView {
            spinner.stopAnimating()
            spinner.removeFromSuperview()
        }
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        // Hide the spinner on error
        if let spinner = webView.subviews.first(where: { $0 is UIActivityIndicatorView }) as? UIActivityIndicatorView {
            spinner.stopAnimating()
            spinner.removeFromSuperview()
        }
        
        // Show error message
        let errorView = UIView()
        errorView.backgroundColor = .systemBackground
        errorView.translatesAutoresizingMaskIntoConstraints = false
        
        let errorLabel = UILabel()
        errorLabel.text = "Failed to load video"
        errorLabel.textAlignment = .center
        errorLabel.textColor = .secondaryLabel
        errorLabel.translatesAutoresizingMaskIntoConstraints = false
        
        errorView.addSubview(errorLabel)
        webView.addSubview(errorView)
        
        NSLayoutConstraint.activate([
            errorView.topAnchor.constraint(equalTo: webView.topAnchor),
            errorView.leadingAnchor.constraint(equalTo: webView.leadingAnchor),
            errorView.trailingAnchor.constraint(equalTo: webView.trailingAnchor),
            errorView.bottomAnchor.constraint(equalTo: webView.bottomAnchor),
            
            errorLabel.centerXAnchor.constraint(equalTo: errorView.centerXAnchor),
            errorLabel.centerYAnchor.constraint(equalTo: errorView.centerYAnchor)
        ])
    }
}
