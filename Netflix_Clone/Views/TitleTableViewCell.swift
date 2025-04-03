// TitleTableViewCell.swift
// Updated with Add to My List functionality

import UIKit
import SDWebImage

protocol TitleTableViewCellDelegate: AnyObject {
    func addToWatchlistButtonTapped(for title: Title)
}

class TitleTableViewCell: UITableViewCell {

    static let identifier: String = "TitleTableViewCell"
    
    // MARK: - Properties
    
    weak var delegate: TitleTableViewCellDelegate?
    private var titleModel: Title?
    
    // MARK: - UI Components
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = DesignSystem.Typography.subtitle
        label.textColor = .label
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let releaseDateLabel: UILabel = {
        let label = UILabel()
        label.font = DesignSystem.Typography.caption
        label.textColor = .secondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = DesignSystem.Typography.bodySmall
        label.textColor = .secondaryLabel
        label.numberOfLines = 3
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let posterImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 8
        imageView.backgroundColor = .systemGray6
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let watchlistButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "plus"), for: .normal)
        button.tintColor = .white
        button.backgroundColor = .systemGray.withAlphaComponent(0.7)
        button.layer.cornerRadius = 15
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.hidesWhenStopped = true
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }()
    
    // MARK: - Initialization
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        posterImageView.image = nil
        titleLabel.text = nil
        releaseDateLabel.text = nil
        descriptionLabel.text = nil
        descriptionLabel.isHidden = true
        titleModel = nil
        
        // Reset watchlist button appearance
        updateWatchlistButtonAppearance(isInWatchlist: false)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // Add subtle shadow to the poster image
        posterImageView.layer.shadowColor = UIColor.black.cgColor
        posterImageView.layer.shadowOffset = CGSize(width: 0, height: 2)
        posterImageView.layer.shadowOpacity = 0.3
        posterImageView.layer.shadowRadius = 4
        posterImageView.layer.masksToBounds = true
    }
    
    // MARK: - UI Setup
    
    private func setupUI() {
        // Add the container view
        contentView.addSubview(containerView)
        
        // Add subviews to container
        containerView.addSubview(posterImageView)
        containerView.addSubview(titleLabel)
        containerView.addSubview(releaseDateLabel)
        containerView.addSubview(descriptionLabel)
        containerView.addSubview(watchlistButton)
        posterImageView.addSubview(loadingIndicator)
        
        // Setup watchlist button action
        watchlistButton.addTarget(self, action: #selector(watchlistButtonTapped), for: .touchUpInside)
        
        // Configure cell appearance
        selectionStyle = .default
        backgroundColor = .systemBackground
        
        // Add subtle separator
        let separator = UIView()
        separator.backgroundColor = .systemGray5
        separator.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(separator)
        
        // Set constraints
        NSLayoutConstraint.activate([
            // Container view
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            
            // Poster image view
            posterImageView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            posterImageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            posterImageView.widthAnchor.constraint(equalToConstant: 100),
            posterImageView.heightAnchor.constraint(equalToConstant: 150),
            
            // Watchlist button
            watchlistButton.topAnchor.constraint(equalTo: posterImageView.topAnchor, constant: 8),
            watchlistButton.leadingAnchor.constraint(equalTo: posterImageView.leadingAnchor, constant: 8),
            watchlistButton.widthAnchor.constraint(equalToConstant: 30),
            watchlistButton.heightAnchor.constraint(equalToConstant: 30),
            
            // Loading indicator
            loadingIndicator.centerXAnchor.constraint(equalTo: posterImageView.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: posterImageView.centerYAnchor),
            
            // Title label
            titleLabel.leadingAnchor.constraint(equalTo: posterImageView.trailingAnchor, constant: 16),
            titleLabel.topAnchor.constraint(equalTo: posterImageView.topAnchor, constant: 8),
            titleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            
            // Release date label
            releaseDateLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            releaseDateLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            releaseDateLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            
            // Description label
            descriptionLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            descriptionLabel.topAnchor.constraint(equalTo: releaseDateLabel.bottomAnchor, constant: 8),
            descriptionLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            
            // Separator
            separator.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            separator.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            separator.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            separator.heightAnchor.constraint(equalToConstant: 0.5)
        ])
    }
    
    // MARK: - Configuration
    
    // Standard configuration method that works with the existing TitleViewModel
    public func configure(with model: TitleViewModel) {
        titleLabel.text = model.titleName
        
        // Set release date if available
        if let releaseDate = model.releaseDate {
            releaseDateLabel.text = releaseDate
            releaseDateLabel.isHidden = false
        } else {
            releaseDateLabel.isHidden = true
        }
        
        // Hide description label since we don't have overview in the model
        descriptionLabel.isHidden = true
        
        // Show loading indicator
        loadingIndicator.startAnimating()
        
        // Load image
        if !model.posterURL.isEmpty {
            let imageURL: String
            if model.posterURL.starts(with: "http") {
                imageURL = model.posterURL
            } else {
                imageURL = "\(Configuration.URLs.TMDB_IMAGE_URL)/\(model.posterURL)"
            }
            
            posterImageView.sd_setImage(with: URL(string: imageURL)) { [weak self] _, error, _, _ in
                self?.loadingIndicator.stopAnimating()
                
                if error != nil {
                    // Show placeholder on error
                    self?.posterImageView.image = UIImage(systemName: "film")
                    self?.posterImageView.contentMode = .scaleAspectFit
                    self?.posterImageView.tintColor = .systemGray
                }
            }
        } else {
            // No poster available
            loadingIndicator.stopAnimating()
            posterImageView.image = UIImage(systemName: "film")
            posterImageView.contentMode = .scaleAspectFit
            posterImageView.tintColor = .systemGray
        }
    }
    
    // Configure with a Title model
    public func configure(with title: Title) {
        // Store the title model for use with the watchlist button
        self.titleModel = title
        
        // Create view model from title
        let viewModel = TitleViewModel(
            titleName: title.displayTitle,
            posterURL: title.posterPath ?? "",
            releaseDate: title.formattedReleaseDate,
            isNewRelease: false,
            isTopRated: (title.voteAverage ?? 0) >= 8.0
        )
        
        // Use the standard configure method
        configure(with: viewModel)
        
        // Then set the overview
        if let overview = title.overview, !overview.isEmpty {
            descriptionLabel.text = overview
            descriptionLabel.isHidden = false
        } else {
            descriptionLabel.isHidden = true
        }
        
        // Update watchlist button state
        let isInWatchlist = WatchlistManager.shared.isTitleInWatchlist(id: title.id)
        updateWatchlistButtonAppearance(isInWatchlist: isInWatchlist)
    }
    
    // New method that accepts both TitleViewModel and overview text
    public func configure(with model: TitleViewModel, overview: String?) {
        // First use the standard configure method
        configure(with: model)
        
        // Then set the overview
        if let overview = overview, !overview.isEmpty {
            descriptionLabel.text = overview
            descriptionLabel.isHidden = false
        } else {
            descriptionLabel.isHidden = true
        }
    }
    
    // MARK: - Watchlist Button
    
    private func updateWatchlistButtonAppearance(isInWatchlist: Bool) {
        if isInWatchlist {
            watchlistButton.setImage(UIImage(systemName: "checkmark"), for: .normal)
            watchlistButton.backgroundColor = DesignSystem.Colors.primary.withAlphaComponent(0.8)
        } else {
            watchlistButton.setImage(UIImage(systemName: "plus"), for: .normal)
            watchlistButton.backgroundColor = .systemGray.withAlphaComponent(0.7)
        }
    }
    
    @objc private func watchlistButtonTapped() {
        guard let title = titleModel else { return }
        
        // Notify delegate
        delegate?.addToWatchlistButtonTapped(for: title)
        
        // Provide haptic feedback
        if #available(iOS 10.0, *) {
            let generator = UIImpactFeedbackGenerator(style: .medium)
            generator.prepare()
            generator.impactOccurred()
        }
        
        // Toggle appearance
        let isCurrentlyInWatchlist = WatchlistManager.shared.isTitleInWatchlist(id: title.id)
        updateWatchlistButtonAppearance(isInWatchlist: !isCurrentlyInWatchlist)
    }
    
    // MARK: - Selection Animation
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        
        UIView.animate(withDuration: 0.1) {
            self.containerView.backgroundColor = highlighted ? .systemGray6 : .clear
            self.transform = highlighted ? CGAffineTransform(scaleX: 0.98, y: 0.98) : .identity
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        UIView.animate(withDuration: 0.1) {
            self.containerView.backgroundColor = selected ? .systemGray6 : .clear
        }
    }
}
