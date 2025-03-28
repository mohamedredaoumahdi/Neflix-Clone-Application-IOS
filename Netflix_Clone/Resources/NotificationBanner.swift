// NotificationBanner.swift
// Netflix_Clone
//
// Created by mohamed reda oumahdi on 28/03/2025.
//

import UIKit

/// A simple banner notification that shows at the top of the screen
class NotificationBanner {
    // MARK: - Banner Style Enum
    
    enum BannerStyle {
        case success, error, warning, info
        
        var color: UIColor {
            switch self {
            case .success: return .systemGreen
            case .error: return .systemRed
            case .warning: return .systemYellow
            case .info: return .systemBlue
            }
        }
        
        var icon: UIImage? {
            switch self {
            case .success: return UIImage(systemName: "checkmark.circle.fill")
            case .error: return UIImage(systemName: "exclamationmark.circle.fill")
            case .warning: return UIImage(systemName: "exclamationmark.triangle.fill")
            case .info: return UIImage(systemName: "info.circle.fill")
            }
        }
    }
    
    // MARK: - Properties
    
    private let title: String
    private let subtitle: String?
    private let style: BannerStyle
    private let duration: TimeInterval
    
    private var bannerView: UIView?
    
    // MARK: - Initialization
    
    init(title: String, subtitle: String? = nil, style: BannerStyle = .info, duration: TimeInterval = 3.0) {
        self.title = title
        self.subtitle = subtitle
        self.style = style
        self.duration = duration
    }
    
    // MARK: - Show Banner
    
    func show() {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first else {
            return
        }
        
        // Create banner view
        let banner = UIView()
        banner.backgroundColor = style.color
        banner.layer.cornerRadius = 8
        banner.clipsToBounds = true
        banner.translatesAutoresizingMaskIntoConstraints = false
        banner.layer.shadowColor = UIColor.black.cgColor
        banner.layer.shadowOffset = CGSize(width: 0, height: 4)
        banner.layer.shadowOpacity = 0.3
        banner.layer.shadowRadius = 4
        
        // Create title label
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = .systemFont(ofSize: 18, weight: .semibold)
        titleLabel.textColor = .white
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // Create subtitle label if needed
        let subtitleLabel = UILabel()
        subtitleLabel.text = subtitle
        subtitleLabel.font = .systemFont(ofSize: 14, weight: .regular)
        subtitleLabel.textColor = .white
        subtitleLabel.numberOfLines = 2
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // Create icon image view
        let iconImageView = UIImageView()
        iconImageView.image = style.icon
        iconImageView.tintColor = .white
        iconImageView.contentMode = .scaleAspectFit
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        
        // Add to banner
        banner.addSubview(iconImageView)
        banner.addSubview(titleLabel)
        if subtitle != nil {
            banner.addSubview(subtitleLabel)
        }
        
        // Add to window
        window.addSubview(banner)
        
        // Set constraints
        NSLayoutConstraint.activate([
            banner.topAnchor.constraint(equalTo: window.safeAreaLayoutGuide.topAnchor, constant: 8),
            banner.leadingAnchor.constraint(equalTo: window.leadingAnchor, constant: 16),
            banner.trailingAnchor.constraint(equalTo: window.trailingAnchor, constant: -16),
            
            iconImageView.leadingAnchor.constraint(equalTo: banner.leadingAnchor, constant: 16),
            iconImageView.centerYAnchor.constraint(equalTo: banner.centerYAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 24),
            iconImageView.heightAnchor.constraint(equalToConstant: 24),
            
            titleLabel.leadingAnchor.constraint(equalTo: iconImageView.trailingAnchor, constant: 12),
            titleLabel.trailingAnchor.constraint(equalTo: banner.trailingAnchor, constant: -16)
        ])
        
        if subtitle != nil {
            NSLayoutConstraint.activate([
                titleLabel.topAnchor.constraint(equalTo: banner.topAnchor, constant: 12),
                subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
                subtitleLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
                subtitleLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
                subtitleLabel.bottomAnchor.constraint(equalTo: banner.bottomAnchor, constant: -12)
            ])
        } else {
            NSLayoutConstraint.activate([
                titleLabel.topAnchor.constraint(equalTo: banner.topAnchor, constant: 12),
                titleLabel.bottomAnchor.constraint(equalTo: banner.bottomAnchor, constant: -12)
            ])
        }
        
        self.bannerView = banner
        
        // Animate in
        banner.transform = CGAffineTransform(translationX: 0, y: -200)
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.5, options: [], animations: {
            banner.transform = .identity
        }, completion: { _ in
            // Animate out after duration
            DispatchQueue.main.asyncAfter(deadline: .now() + self.duration) {
                UIView.animate(withDuration: 0.3, animations: {
                    banner.transform = CGAffineTransform(translationX: 0, y: -200)
                    banner.alpha = 0
                }, completion: { _ in
                    banner.removeFromSuperview()
                    self.bannerView = nil
                })
            }
        })
    }
    
    // MARK: - Convenience Methods
    
    static func showSuccess(title: String, subtitle: String? = nil) {
        let banner = NotificationBanner(title: title, subtitle: subtitle, style: .success)
        banner.show()
    }
    
    static func showError(title: String, subtitle: String? = nil) {
        let banner = NotificationBanner(title: title, subtitle: subtitle, style: .error)
        banner.show()
    }
    
    static func showWarning(title: String, subtitle: String? = nil) {
        let banner = NotificationBanner(title: title, subtitle: subtitle, style: .warning)
        banner.show()
    }
    
    static func showInfo(title: String, subtitle: String? = nil) {
        let banner = NotificationBanner(title: title, subtitle: subtitle, style: .info)
        banner.show()
    }
}
