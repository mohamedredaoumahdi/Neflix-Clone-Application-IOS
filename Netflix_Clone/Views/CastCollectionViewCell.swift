// CastCollectionViewCell.swift
// Netflix_Clone
//
// Created by mohamed reda oumahdi on 27/03/2025.
//

import UIKit
import SDWebImage

class CastCollectionViewCell: UICollectionViewCell {
    // MARK: - Properties
    
    static let identifier = "CastCollectionViewCell"
    
    // MARK: - UI Components
    
    private let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.backgroundColor = .systemGray6
        imageView.layer.cornerRadius = 40
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .semibold)
        label.textColor = .label
        label.textAlignment = .center
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let characterLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 10, weight: .regular)
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.hidesWhenStopped = true
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
    
    override func prepareForReuse() {
        super.prepareForReuse()
        profileImageView.image = nil
        nameLabel.text = nil
        characterLabel.text = nil
        loadingIndicator.stopAnimating()
    }
    
    // MARK: - Setup Methods
    
    private func setupUI() {
        // Add subviews
        contentView.addSubview(profileImageView)
        contentView.addSubview(nameLabel)
        contentView.addSubview(characterLabel)
        contentView.addSubview(loadingIndicator)
        
        // Configure appearance
        contentView.backgroundColor = .systemBackground
        
        // Make profile image view circular
        profileImageView.layer.cornerRadius = 40
        profileImageView.clipsToBounds = true
        profileImageView.layer.borderWidth = 1
        profileImageView.layer.borderColor = UIColor.systemGray5.cgColor
        
        // Set constraints
        NSLayoutConstraint.activate([
            // Profile image view
            profileImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            profileImageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            profileImageView.widthAnchor.constraint(equalToConstant: 80),
            profileImageView.heightAnchor.constraint(equalToConstant: 80),
            
            // Loading indicator
            loadingIndicator.centerXAnchor.constraint(equalTo: profileImageView.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: profileImageView.centerYAnchor),
            
            // Name label
            nameLabel.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: 8),
            nameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 4),
            nameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -4),
            
            // Character label
            characterLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 2),
            characterLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 4),
            characterLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -4),
            characterLabel.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -4)
        ])
    }
    
    // MARK: - Configuration
    
    func configure(with cast: Cast) {
        // Set name and character
        nameLabel.text = cast.name
        characterLabel.text = cast.character ?? "Unknown Role"
        
        // Show loading indicator
        loadingIndicator.startAnimating()
        
        // Print debug info
        print("🎭 Configuring cell for: \(cast.name)")
        print("  Has profile path: \(cast.profilePath != nil)")
        
        // Load profile image if available
        if let profilePath = cast.profilePath, !profilePath.isEmpty {
            let imageUrl = Configuration.URLs.TMDB_IMAGE_URL + "/\(profilePath)"
            print("  Loading image from: \(imageUrl)")
            
            profileImageView.sd_setImage(with: URL(string: imageUrl), placeholderImage: UIImage(systemName: "person.fill"), completed: { [weak self] image, error, _, _ in
                self?.loadingIndicator.stopAnimating()
                
                if let error = error {
                    print("  ❌ Image loading error: \(error.localizedDescription)")
                    // Show placeholder on error
                    self?.profileImageView.image = UIImage(systemName: "person.fill")
                    self?.profileImageView.tintColor = .systemGray
                    self?.profileImageView.contentMode = .scaleAspectFit
                } else if image != nil {
                    print("  ✅ Image loaded successfully")
                    self?.profileImageView.contentMode = .scaleAspectFill
                }
            })
        } else {
            // No profile image available
            print("  ℹ️ No profile image available, using placeholder")
            loadingIndicator.stopAnimating()
            profileImageView.image = UIImage(systemName: "person.fill")
            profileImageView.tintColor = .systemGray
            profileImageView.contentMode = .scaleAspectFit
        }
    }
}
