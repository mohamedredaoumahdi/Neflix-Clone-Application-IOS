//
//  HeroHeaderUIView.swift
//  Netflix_Clone
//
//  Created by mohamed reda oumahdi on 01/03/2024.
//  Updated with centered preview button and no title
//

import UIKit

class HeroHeaderUIView: UIView {
    
    // Single preview button, positioned below center
    private let previewButton: UIButton = {
        let button = UIButton()
        button.setTitle("Preview", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = DesignSystem.Colors.primary
        button.layer.cornerRadius = 8
        button.translatesAutoresizingMaskIntoConstraints = false
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .bold)
        
        // Add shadow for better visibility
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOpacity = 0.5
        button.layer.shadowOffset = CGSize(width: 0, height: 2)
        button.layer.shadowRadius = 4
        
        return button
    }()
    
    private let heroHeaderImage: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.image = UIImage(named: "oppenheimerCover") // Default image
        return imageView
    }()
    
    // Add gradient to make button more visible
    private func addGradient() {
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [
            UIColor.clear.cgColor,
            UIColor.black.withAlphaComponent(0.4).cgColor,
            UIColor.black.withAlphaComponent(0.6).cgColor,
            UIColor.systemBackground.cgColor
        ]
        gradientLayer.locations = [0.0, 0.5, 0.8, 1.0]
        gradientLayer.frame = bounds
        layer.addSublayer(gradientLayer)
    }
    
    private func applyConstraints() {
        // Position button slightly below the center
        let previewButtonConstraints = [
            // Center horizontally
            previewButton.centerXAnchor.constraint(equalTo: centerXAnchor),
            
            // Position vertically - a bit below center (center would be multiplier: 1.0)
            previewButton.centerYAnchor.constraint(equalTo: centerYAnchor, constant: 60),
            
            // Size constraints
            previewButton.widthAnchor.constraint(equalToConstant: 160),
            previewButton.heightAnchor.constraint(equalToConstant: 48)
        ]
        
        NSLayoutConstraint.activate(previewButtonConstraints)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        // Add subviews in correct order
        addSubview(heroHeaderImage)
        addGradient()
        addSubview(previewButton)
        
        // Apply constraints and set up button action
        applyConstraints()
        setupAction()
    }
    
    private func setupAction() {
        previewButton.addTarget(self, action: #selector(previewButtonTapped), for: .touchUpInside)
    }
    
    @objc private func previewButtonTapped() {
        // Post notification for the view controller to handle
        NotificationCenter.default.post(name: .heroHeaderPreviewTapped, object: nil)
    }
    
    public func configure(with model: TitleViewModel) {
        guard let url = URL(string: "https://image.tmdb.org/t/p/w500/\(model.posterURL)") else {return}
        
        // Load image with smooth transition
        heroHeaderImage.sd_setImage(with: url, completed: { [weak self] _, _, _, _ in
            UIView.transition(with: self?.heroHeaderImage ?? UIView(),
                             duration: 0.3,
                             options: .transitionCrossDissolve,
                             animations: {},
                             completion: nil)
        })
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // Make sure the image takes up the full space of the view
        heroHeaderImage.frame = bounds
        
        // Remove existing gradient layers and re-add to ensure correct size
        layer.sublayers?.filter { $0 is CAGradientLayer }.forEach { $0.removeFromSuperlayer() }
        addGradient()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// Notification name extension
extension Notification.Name {
    static let heroHeaderPreviewTapped = Notification.Name("heroHeaderPreviewTapped")
}
