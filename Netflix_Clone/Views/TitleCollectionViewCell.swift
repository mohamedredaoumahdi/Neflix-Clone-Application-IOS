// TitleCollectionViewCell.swift - With dynamic badge positioning
// Netflix_Clone
//

import UIKit
import SDWebImage

class TitleCollectionViewCell: UICollectionViewCell {
    
    // MARK: - Properties
    
    static let identifier = "TitleCollectionViewCell"
    
    // MARK: - UI Components
    
    let posterImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 8
        imageView.layer.masksToBounds = true
        return imageView
    }()
    
    private let gradientOverlay: CAGradientLayer = {
        let gradient = CAGradientLayer()
        gradient.colors = [
            UIColor.clear.cgColor,
            UIColor.black.withAlphaComponent(0.3).cgColor
        ]
        gradient.locations = [0.7, 1.0]
        return gradient
    }()
    
    private let loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.hidesWhenStopped = true
        indicator.color = .white
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }()
    
    private let errorImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(systemName: "exclamationmark.triangle"))
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .systemOrange
        imageView.isHidden = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    // New badge for recent releases
    private let newReleaseView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemRed
        view.layer.cornerRadius = 10
        view.clipsToBounds = true
        view.isHidden = true // Hidden by default
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let newReleaseLabel: UILabel = {
        let label = UILabel()
        label.text = "NEW"
        label.textColor = .white
        label.font = .systemFont(ofSize: 10, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // TOP RATED badge
    private let topRatedView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemYellow
        view.layer.cornerRadius = 10
        view.clipsToBounds = true
        view.isHidden = true // Hidden by default
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let topRatedLabel: UILabel = {
        let label = UILabel()
        label.text = "TOP"
        label.textColor = .black // Dark text for better contrast against yellow
        label.font = .systemFont(ofSize: 10, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // Star icon for top rated badge
    private let starImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(systemName: "star.fill"))
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .black
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    // Constraints that will be modified dynamically
    private var topRatedTopConstraint: NSLayoutConstraint?
    
    // MARK: - Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        posterImageView.frame = contentView.bounds
        gradientOverlay.frame = contentView.bounds
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        posterImageView.image = nil
        loadingIndicator.stopAnimating()
        errorImageView.isHidden = true
        newReleaseView.isHidden = true
        topRatedView.isHidden = true
    }
    
    // MARK: - Setup Methods
    
    private func setupUI() {
        contentView.addSubview(posterImageView)
        posterImageView.layer.addSublayer(gradientOverlay)
        contentView.addSubview(loadingIndicator)
        contentView.addSubview(errorImageView)
        
        // Add new release badge
        newReleaseView.addSubview(newReleaseLabel)
        contentView.addSubview(newReleaseView)
        
        // Add top rated badge with star icon
        topRatedView.addSubview(starImageView)
        topRatedView.addSubview(topRatedLabel)
        contentView.addSubview(topRatedView)
        
        // Add subtle shadow
        contentView.layer.shadowColor = UIColor.black.cgColor
        contentView.layer.shadowOpacity = 0.3
        contentView.layer.shadowOffset = CGSize(width: 0, height: 2)
        contentView.layer.shadowRadius = 4
        
        // Center loading indicator
        NSLayoutConstraint.activate([
            loadingIndicator.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            
            // Center error icon
            errorImageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            errorImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            errorImageView.widthAnchor.constraint(equalToConstant: 40),
            errorImageView.heightAnchor.constraint(equalToConstant: 40),
            
            // New release badge (top right)
            newReleaseView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            newReleaseView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
            newReleaseView.heightAnchor.constraint(equalToConstant: 20),
            
            newReleaseLabel.topAnchor.constraint(equalTo: newReleaseView.topAnchor, constant: 2),
            newReleaseLabel.bottomAnchor.constraint(equalTo: newReleaseView.bottomAnchor, constant: -2),
            newReleaseLabel.leadingAnchor.constraint(equalTo: newReleaseView.leadingAnchor, constant: 6),
            newReleaseLabel.trailingAnchor.constraint(equalTo: newReleaseView.trailingAnchor, constant: -6),
            
            // Top rated badge (trailingAnchor stays constant)
            topRatedView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
            topRatedView.heightAnchor.constraint(equalToConstant: 20),
            
            // Star icon
            starImageView.leadingAnchor.constraint(equalTo: topRatedView.leadingAnchor, constant: 6),
            starImageView.centerYAnchor.constraint(equalTo: topRatedView.centerYAnchor),
            starImageView.widthAnchor.constraint(equalToConstant: 12),
            starImageView.heightAnchor.constraint(equalToConstant: 12),
            
            // Top rated label
            topRatedLabel.leadingAnchor.constraint(equalTo: starImageView.trailingAnchor, constant: 2),
            topRatedLabel.trailingAnchor.constraint(equalTo: topRatedView.trailingAnchor, constant: -6),
            topRatedLabel.centerYAnchor.constraint(equalTo: topRatedView.centerYAnchor)
        ])
        
        // Default position for TOP badge (will be updated in configure)
        topRatedTopConstraint = topRatedView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8)
        topRatedTopConstraint?.isActive = true
    }
    
    // MARK: - Configuration
    
    // Updated view model structure with top rated flag
    public func configure(with viewModel: TitleViewModel) {
        // Configure poster image
        if !viewModel.posterURL.isEmpty {
            configure(with: viewModel.posterURL)
        }
        
        // Determine badge visibility
        let showNewBadge = viewModel.isNewRelease
        let showTopBadge = viewModel.isTopRated
        
        // Show/hide badges
        newReleaseView.isHidden = !showNewBadge
        topRatedView.isHidden = !showTopBadge
        
        // Position TOP badge based on whether NEW badge is showing
        if showNewBadge && showTopBadge {
            // If both are showing, TOP goes below NEW
            topRatedTopConstraint?.isActive = false
            topRatedTopConstraint = topRatedView.topAnchor.constraint(equalTo: newReleaseView.bottomAnchor, constant: 8)
            topRatedTopConstraint?.isActive = true
        } else {
            // If only TOP is showing, it goes in the top position
            topRatedTopConstraint?.isActive = false
            topRatedTopConstraint = topRatedView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8)
            topRatedTopConstraint?.isActive = true
        }
    }
    
    // Legacy method for backward compatibility
    public func configure(with model: String) {
        // Reset the cell first
        posterImageView.image = nil
        errorImageView.isHidden = true
        loadingIndicator.startAnimating()
            
        guard !model.isEmpty else {
            print("Empty poster path")
            showErrorState(message: "No image")
            return
        }
        
        // First check if the path already includes the base URL
        let imageURL: String
        if model.starts(with: "http") {
            imageURL = model
        } else {
            // If it doesn't start with http, assume it's a poster path that needs the base URL
            imageURL = "\(Configuration.URLs.TMDB_IMAGE_URL)/\(model)"
        }
        
        guard let url = URL(string: imageURL) else {
            print("Invalid image URL: \(imageURL)")
            showErrorState(message: "Invalid URL")
            return
        }
        
        // Load image with SDWebImage with proper error handling
        posterImageView.sd_setImage(
            with: url,
            placeholderImage: UIImage(systemName: "film"),
            options: [.retryFailed, .handleCookies],
            context: nil,
            progress: nil,
            completed: { [weak self] (image, error, cacheType, imageURL) in
                // Stop loading indicator when image is loaded or on error
                self?.loadingIndicator.stopAnimating()
                
                if let error = error {
                    print("Image loading error: \(error.localizedDescription)")
                    self?.showErrorState(message: "Failed to load image")
                    return
                }
                
                if image != nil {
                    // Apply fade-in animation for smoother appearance
                    self?.posterImageView.alpha = 0.0
                    UIView.animate(withDuration: 0.3) {
                        self?.posterImageView.alpha = 1.0
                    }
                } else {
                    print("Image is nil after loading")
                    self?.showErrorState(message: "No image data")
                }
            }
        )
    }
    
    private func showErrorState(message: String) {
        loadingIndicator.stopAnimating()
        posterImageView.image = UIImage(systemName: "film")
        posterImageView.contentMode = .scaleAspectFit
        posterImageView.tintColor = .systemGray3
        
        errorImageView.isHidden = false
    }
    
    // Apply a frosted effect to highlight cell selection
    override var isHighlighted: Bool {
        didSet {
            UIView.animate(withDuration: 0.1) {
                self.transform = self.isHighlighted ? CGAffineTransform(scaleX: 0.96, y: 0.96) : .identity
                self.alpha = self.isHighlighted ? 0.9 : 1.0
            }
        }
    }
    
    // Apply a selected state visual
    override var isSelected: Bool {
        didSet {
            UIView.animate(withDuration: 0.2) {
                self.transform = self.isSelected ? CGAffineTransform(scaleX: 0.96, y: 0.96) : .identity
            }
        }
    }
}
