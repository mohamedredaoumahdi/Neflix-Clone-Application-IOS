// Enhanced TitleCollectionViewCell with professional design touches
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
    
    private let overlayView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.1)
        view.layer.cornerRadius = 8
        view.alpha = 0 // Hidden by default - will show on highlight
        return view
    }()
    
    private let gradientOverlay: CAGradientLayer = {
        let gradient = CAGradientLayer()
        gradient.colors = [
            UIColor.clear.cgColor,
            UIColor.black.withAlphaComponent(0.4).cgColor
        ]
        gradient.locations = [0.7, 1.0]
        return gradient
    }()
    
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
        label.textColor = .black // Dark text for contrast
        label.font = .systemFont(ofSize: 10, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.hidesWhenStopped = true
        indicator.color = .white
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }()
    
    // Shimmer effect overlay for loading state
    private let shimmerView: UIView = {
        let view = UIView()
        view.isHidden = true
        view.backgroundColor = .clear
        view.clipsToBounds = true
        view.layer.cornerRadius = 8
        return view
    }()
    
    // MARK: - Lifecycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // Setup poster image and overlay
        posterImageView.frame = contentView.bounds
        overlayView.frame = contentView.bounds
        shimmerView.frame = contentView.bounds
        
        // Configure gradient layer
        gradientOverlay.frame = contentView.bounds
        
        // Position the badges
        updateBadgePositions()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        posterImageView.image = nil
        loadingIndicator.stopAnimating()
        newReleaseView.isHidden = true
        topRatedView.isHidden = true
        overlayView.alpha = 0
        shimmerView.isHidden = true
        shimmerView.layer.removeAllAnimations()
    }
    
    // MARK: - UI Setup
    
    private func setupUI() {
        // Add shadow to content view
        contentView.layer.shadowColor = UIColor.black.cgColor
        contentView.layer.shadowOpacity = 0.3
        contentView.layer.shadowOffset = CGSize(width: 0, height: 2)
        contentView.layer.shadowRadius = 4
        
        // Add views in the right order
        contentView.addSubview(posterImageView)
        posterImageView.layer.addSublayer(gradientOverlay)
        contentView.addSubview(overlayView)
        
        // Add badges
        newReleaseView.addSubview(newReleaseLabel)
        contentView.addSubview(newReleaseView)
        
        topRatedView.addSubview(topRatedLabel)
        contentView.addSubview(topRatedView)
        
        // Add loading indicator
        contentView.addSubview(loadingIndicator)
        
        // Add shimmer view for loading state
        contentView.addSubview(shimmerView)
        
        // Set up badge constraints
        NSLayoutConstraint.activate([
            // New release badge
            newReleaseView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            newReleaseView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
            newReleaseView.heightAnchor.constraint(equalToConstant: 20),
            
            newReleaseLabel.topAnchor.constraint(equalTo: newReleaseView.topAnchor, constant: 2),
            newReleaseLabel.bottomAnchor.constraint(equalTo: newReleaseView.bottomAnchor, constant: -2),
            newReleaseLabel.leadingAnchor.constraint(equalTo: newReleaseView.leadingAnchor, constant: 6),
            newReleaseLabel.trailingAnchor.constraint(equalTo: newReleaseView.trailingAnchor, constant: -6),
            
            // Top rated badge - positioning will be updated in updateBadgePositions()
            topRatedView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
            topRatedView.heightAnchor.constraint(equalToConstant: 20),
            
            topRatedLabel.topAnchor.constraint(equalTo: topRatedView.topAnchor, constant: 2),
            topRatedLabel.bottomAnchor.constraint(equalTo: topRatedView.bottomAnchor, constant: -2),
            topRatedLabel.leadingAnchor.constraint(equalTo: topRatedView.leadingAnchor, constant: 6),
            topRatedLabel.trailingAnchor.constraint(equalTo: topRatedView.trailingAnchor, constant: -6),
            
            // Loading indicator
            loadingIndicator.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }
    
    private func updateBadgePositions() {
        // Re-position TOP badge based on whether NEW badge is showing
        if let constraint = topRatedView.constraints.first(where: { $0.firstAttribute == .top }) {
            constraint.isActive = false
        }
        
        let topConstraint: NSLayoutConstraint
        if !newReleaseView.isHidden {
            // If NEW badge is visible, place TOP below it
            topConstraint = topRatedView.topAnchor.constraint(equalTo: newReleaseView.bottomAnchor, constant: 8)
        } else {
            // If NEW badge is hidden, place TOP at the top
            topConstraint = topRatedView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8)
        }
        
        topConstraint.isActive = true
    }
    
    // MARK: - Configuration
    
    public func configure(with viewModel: TitleViewModel) {
        // Configure poster image
        if !viewModel.posterURL.isEmpty {
            loadImage(from: viewModel.posterURL)
        }
        
        // Configure badges
        configureNewReleaseBadge(isVisible: viewModel.isNewRelease)
        configureTopRatedBadge(isVisible: viewModel.isTopRated)
    }
    
    private func configureNewReleaseBadge(isVisible: Bool) {
        newReleaseView.isHidden = !isVisible
        setNeedsLayout()
    }
    
    private func configureTopRatedBadge(isVisible: Bool) {
        topRatedView.isHidden = !isVisible
        setNeedsLayout()
    }
    
    private func loadImage(from urlString: String) {
        // Start loading indicator
        loadingIndicator.startAnimating()
        
        // First check if the path already includes the base URL
        let imageURL: String
        if urlString.starts(with: "http") {
            imageURL = urlString
        } else {
            // If it doesn't start with http, assume it's a poster path that needs the base URL
            imageURL = "\(Configuration.URLs.TMDB_IMAGE_URL)/\(urlString)"
        }
        
        guard let url = URL(string: imageURL) else {
            loadingIndicator.stopAnimating()
            return
        }
        
        // Load image with transition animation
        posterImageView.sd_setImage(with: url, placeholderImage: nil, options: [.avoidAutoSetImage, .retryFailed]) { [weak self] (image, error, _, _) in
            guard let self = self else { return }
            
            // Stop loading indicator
            self.loadingIndicator.stopAnimating()
            
            if let error = error {
                print("Image loading error: \(error.localizedDescription)")
                return
            }
            
            if let image = image {
                // Fade in the image
                UIView.transition(with: self.posterImageView, duration: 0.3, options: .transitionCrossDissolve, animations: {
                    self.posterImageView.image = image
                })
            }
        }
    }
    
    // MARK: - Loading State
    
    func showShimmerLoading() {
        shimmerView.isHidden = false
        addShimmerEffect(to: shimmerView)
    }
    
    private func addShimmerEffect(to view: UIView) {
        // Create gradient layer for shimmer effect
        let gradientLayer = CAGradientLayer()
        gradientLayer.name = "shimmerLayer"
        gradientLayer.frame = view.bounds
        gradientLayer.cornerRadius = view.layer.cornerRadius
        
        // Configure gradient
        gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1.0, y: 0.5)
        gradientLayer.colors = [
            UIColor.systemGray5.cgColor,
            UIColor.systemGray3.cgColor,
            UIColor.systemGray5.cgColor
        ]
        gradientLayer.locations = [-0.5, 0.0, 0.5]
        view.layer.addSublayer(gradientLayer)
        
        // Create animation
        let animation = CABasicAnimation(keyPath: "locations")
        animation.fromValue = [-0.5, 0.0, 0.5]
        animation.toValue = [1.0, 1.5, 2.0]
        animation.repeatCount = .infinity
        animation.duration = 1.2
        animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        
        gradientLayer.add(animation, forKey: "shimmerAnimation")
    }
    
    // MARK: - Interaction Effects
    
    // Highlight effect when cell is touched
    override var isHighlighted: Bool {
        didSet {
            UIView.animate(withDuration: 0.15) {
                self.transform = self.isHighlighted ? CGAffineTransform(scaleX: 0.97, y: 0.97) : .identity
                self.overlayView.alpha = self.isHighlighted ? 1.0 : 0.0
            }
        }
    }
    
    // Selected state effect
    override var isSelected: Bool {
        didSet {
            UIView.animate(withDuration: 0.2) {
                self.transform = self.isSelected ? CGAffineTransform(scaleX: 0.96, y: 0.96) : .identity
            }
        }
    }
}
