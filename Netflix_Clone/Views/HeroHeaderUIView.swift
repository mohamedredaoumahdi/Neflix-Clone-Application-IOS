//
//  HeroHeaderUIView.swift
//  Netflix_Clone
//
//  Created by mohamed reda oumahdi on 01/03/2024.
//  Enhanced with professional design elements
//

import UIKit

class HeroHeaderUIView: UIView {
    
    // MARK: - UI Components
    
    private let heroHeaderImage: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()
    
    private let previewButton: UIButton = {
        let button = UIButton()
        button.setTitle("Preview", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = DesignSystem.Colors.primary
        button.layer.cornerRadius = 8
        button.translatesAutoresizingMaskIntoConstraints = false
        button.titleLabel?.font = .systemFont(ofSize: 17, weight: .bold)
        
        // Enhanced shadow for better visibility
        
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOpacity = 0.8
        button.layer.shadowOffset = CGSize(width: 0, height: 3)
        button.layer.shadowRadius = 6
        
        return button
    }()
    
    // MARK: - Initialization and Setup
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupViews()
        setupGradient()
        setupConstraints()
        setupActions()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        // Add views in the correct order
        addSubview(heroHeaderImage)
        addSubview(previewButton)
    }
    
    private func setupGradient() {
        // Create a more sophisticated gradient
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [
            UIColor.clear.cgColor,
            UIColor.black.withAlphaComponent(0.2).cgColor,
            UIColor.black.withAlphaComponent(0.4).cgColor,
            UIColor.black.withAlphaComponent(0.6).cgColor,
            UIColor.black.withAlphaComponent(0.8).cgColor,
            UIColor.systemBackground.cgColor
        ]
        gradientLayer.locations = [0.0, 0.3, 0.5, 0.7, 0.85, 1.0]
        gradientLayer.frame = bounds
        layer.addSublayer(gradientLayer)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Preview button (centered below middle)
            previewButton.centerXAnchor.constraint(equalTo: centerXAnchor),
            previewButton.centerYAnchor.constraint(equalTo: centerYAnchor, constant: 60),
            previewButton.widthAnchor.constraint(equalToConstant: 180), // Slightly wider
            previewButton.heightAnchor.constraint(equalToConstant: 50)  // Slightly taller
        ])
    }
    
    private func setupActions() {
        previewButton.addTarget(self, action: #selector(previewButtonTapped), for: .touchUpInside)
        
        // Add touch down and touch up animations
        previewButton.addTarget(self, action: #selector(buttonTouchDown), for: .touchDown)
        previewButton.addTarget(self, action: #selector(buttonTouchUp), for: [.touchUpInside, .touchUpOutside, .touchCancel])
    }
    
    // MARK: - Animation Methods
    
    @objc private func buttonTouchDown() {
        UIView.animate(withDuration: 0.1) {
            self.previewButton.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
            self.previewButton.alpha = 0.9
        }
    }
    
    @objc private func buttonTouchUp() {
        UIView.animate(withDuration: 0.2, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: [], animations: {
            self.previewButton.transform = .identity
            self.previewButton.alpha = 1.0
        })
    }
    
    @objc private func previewButtonTapped() {
        // Add a subtle haptic feedback if available
        if #available(iOS 10.0, *) {
            let generator = UIImpactFeedbackGenerator(style: .medium)
            generator.prepare()
            generator.impactOccurred()
        }
        
        // Post notification for the view controller to handle
        NotificationCenter.default.post(name: .heroHeaderPreviewTapped, object: nil)
    }
    
    // MARK: - Configuration Methods
    
    public func configure(with model: TitleViewModel) {
        guard let url = URL(string: "https://image.tmdb.org/t/p/w500/\(model.posterURL)") else { return }
        
        // Load image with enhanced transition
        heroHeaderImage.alpha = 0.8
        heroHeaderImage.sd_setImage(with: url) { [weak self] _, _, _, _ in
            guard let self = self else { return }
            
            UIView.animate(withDuration: 0.5) {
                self.heroHeaderImage.alpha = 1.0
            }
        }
    }
    
    // MARK: - Layout Methods
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // Setup the image to fill the entire view
        heroHeaderImage.frame = bounds
        
        // Remove old gradient layers and add a new one
        layer.sublayers?.filter { $0 is CAGradientLayer }.forEach { $0.removeFromSuperlayer() }
        setupGradient()
    }
    
    // Apply a subtle parallax effect based on scroll position
    @objc func applyParallaxEffect(withOffset offset: CGFloat) {
        let parallaxFactor: CGFloat = 0.35
        let movement = min(0, offset) * parallaxFactor
        heroHeaderImage.transform = CGAffineTransform(translationX: 0, y: movement)
    }
}

// Notification name extension
extension Notification.Name {
    static let heroHeaderPreviewTapped = Notification.Name("heroHeaderPreviewTapped")
}
