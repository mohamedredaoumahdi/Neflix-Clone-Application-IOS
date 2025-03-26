// TitleCollectionViewCell.swift
// Netflix_Clone
//
// Created by mohamed reda oumahdi on 04/03/2024.
// Updated on 27/03/2025.
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
    }
    
    // MARK: - Setup Methods
    
    private func setupUI() {
        contentView.addSubview(posterImageView)
        posterImageView.layer.addSublayer(gradientOverlay)
        contentView.addSubview(loadingIndicator)
        
        // Add subtle shadow
        contentView.layer.shadowColor = UIColor.black.cgColor
        contentView.layer.shadowOpacity = 0.3
        contentView.layer.shadowOffset = CGSize(width: 0, height: 2)
        contentView.layer.shadowRadius = 4
        
        // Center loading indicator
        NSLayoutConstraint.activate([
            loadingIndicator.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }
    
    // MARK: - Configuration
    
    public func configure(with model: String) {
        print("Configuring cell with poster path: \(model)")
        loadingIndicator.startAnimating()
        
        // Make sure model is not empty

        guard !model.isEmpty else {

            print("Empty poster path")

            posterImageView.image = UIImage(systemName: "film")

            return

        }
        // Construct image URL
        let imageURL = "\(Configuration.URLs.TMDB_IMAGE_URL)/\(model)"
        print("Full image URL: \(imageURL)")
        guard let url = URL(string: imageURL) else {
            print("Invalid image URL: \(imageURL)")
            posterImageView.image = UIImage(systemName: "film")
            loadingIndicator.stopAnimating()
            return
        }
        
        // Load image with SDWebImage
        posterImageView.sd_setImage(with: url, placeholderImage: nil, options: [], completed: { [weak self] (image, error, _, _) in
            // Stop loading indicator when image is loaded or on error
            self?.loadingIndicator.stopAnimating()
            
            if let error = error {
                print("Image loading error: \(error.localizedDescription)")
                self?.posterImageView.image = UIImage(systemName: "film")
                return
            }
            
            if image != nil {
                print("Image loaded successfully")
            } else {
                print("Image is nil after loading")
            }
            
            // Add subtle animation when image appears
            self?.posterImageView.alpha = 0.0
            UIView.animate(withDuration: 0.3) {
                self?.posterImageView.alpha = 1.0
            }
        })
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
