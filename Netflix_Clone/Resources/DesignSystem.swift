// DesignSystem.swift
// Netflix_Clone
//
// Created by mohamed reda oumahdi on 28/03/2025.
//

import UIKit

/// A centralized design system to ensure consistent styling across the app
struct DesignSystem {
    
    // MARK: - Color Palette
    
    struct Colors {
        // Primary colors
        static let primary = UIColor.systemRed
        static let primaryDark = UIColor(red: 185/255, green: 9/255, blue: 11/255, alpha: 1.0) // Darker red
        static let primaryLight = UIColor(red: 255/255, green: 69/255, blue: 58/255, alpha: 1.0) // Lighter red
        
        // Background colors
        static let background = UIColor.black
        static let backgroundElevated = UIColor(red: 25/255, green: 25/255, blue: 25/255, alpha: 1.0)
        static let backgroundCard = UIColor(red: 38/255, green: 38/255, blue: 38/255, alpha: 1.0)
        
        // Text colors
        static let textPrimary = UIColor.white
        static let textSecondary = UIColor.lightGray
        static let textMuted = UIColor.darkGray
        
        // UI element colors
        static let accent = UIColor.systemBlue
        static let success = UIColor.systemGreen
        static let warning = UIColor.systemYellow
        static let error = UIColor.systemRed
        
        // Overlay colors
        static let darkOverlay = UIColor(white: 0, alpha: 0.7)
        static let lightOverlay = UIColor(white: 1, alpha: 0.1)
        
        // Genre tag colors
        static let genreBackground = UIColor.systemBlue.withAlphaComponent(0.3)
        static let genreText = UIColor.systemBlue
    }
    
    // MARK: - Typography
    
    struct Typography {
        // Title styles
        static let largeTitle = UIFont.systemFont(ofSize: 28, weight: .bold)
        static let title = UIFont.systemFont(ofSize: 22, weight: .bold)
        static let subtitle = UIFont.systemFont(ofSize: 18, weight: .semibold)
        
        // Body text styles
        static let bodyLarge = UIFont.systemFont(ofSize: 17, weight: .regular)
        static let body = UIFont.systemFont(ofSize: 15, weight: .regular)
        static let bodySmall = UIFont.systemFont(ofSize: 13, weight: .regular)
        
        // Special text styles
        static let caption = UIFont.systemFont(ofSize: 12, weight: .medium)
        static let captionSmall = UIFont.systemFont(ofSize: 10, weight: .regular)
        static let button = UIFont.systemFont(ofSize: 16, weight: .semibold)
        static let tabBar = UIFont.systemFont(ofSize: 10, weight: .medium)
    }
    
    // MARK: - Spacing & Layout
    
    struct Spacing {
        static let tiny = 4.0
        static let small = 8.0
        static let medium = 16.0
        static let large = 24.0
        static let xlarge = 32.0
        static let xxlarge = 48.0
        
        // Content insets
        static let contentInset = UIEdgeInsets(top: medium, left: medium, bottom: medium, right: medium)
        static let cardInset = UIEdgeInsets(top: small, left: small, bottom: small, right: small)
        
        // Specialized spacing
        static let collectionSpacing = 10.0
        static let sectionSpacing = 24.0
    }
    
    // MARK: - UI Elements
    
    struct Elements {
        // Corner radius values
        static let smallRadius = 4.0
        static let mediumRadius = 8.0
        static let largeRadius = 12.0
        static let extraLargeRadius = 20.0
        
        // Shadow styles
        static func applyShadow(to view: UIView, intensity: ShadowIntensity = .medium) {
            view.layer.shadowColor = UIColor.black.cgColor
            
            switch intensity {
            case .light:
                view.layer.shadowOpacity = 0.1
                view.layer.shadowOffset = CGSize(width: 0, height: 1)
                view.layer.shadowRadius = 2
            case .medium:
                view.layer.shadowOpacity = 0.2
                view.layer.shadowOffset = CGSize(width: 0, height: 2)
                view.layer.shadowRadius = 4
            case .strong:
                view.layer.shadowOpacity = 0.3
                view.layer.shadowOffset = CGSize(width: 0, height: 3)
                view.layer.shadowRadius = 6
            }
        }
        
        enum ShadowIntensity {
            case light, medium, strong
        }
        
        // Button styles
        static func styleAsMainButton(_ button: UIButton) {
            button.backgroundColor = Colors.primary
            button.setTitleColor(Colors.textPrimary, for: .normal)
            button.titleLabel?.font = Typography.button
            button.layer.cornerRadius = mediumRadius
            applyShadow(to: button, intensity: .medium)
        }
        
        static func styleAsSecondaryButton(_ button: UIButton) {
            button.backgroundColor = Colors.backgroundCard
            button.setTitleColor(Colors.textPrimary, for: .normal)
            button.titleLabel?.font = Typography.button
            button.layer.cornerRadius = mediumRadius
            button.layer.borderWidth = 1
            button.layer.borderColor = Colors.textSecondary.cgColor
        }
        
        // Card styling
        static func styleAsCard(_ view: UIView) {
            view.backgroundColor = Colors.backgroundCard
            view.layer.cornerRadius = mediumRadius
            applyShadow(to: view, intensity: .medium)
        }
    }
    
    // MARK: - Animation
    
    struct Animation {
        static let standardDuration = 0.3
        static let quickDuration = 0.15
        static let longDuration = 0.5
        
        // Standard timing functions
        static let easeIn = CAMediaTimingFunction(name: .easeIn)
        static let easeOut = CAMediaTimingFunction(name: .easeOut)
        static let easeInOut = CAMediaTimingFunction(name: .easeInEaseOut)
        
        // Spring animation values
        static let springDamping: CGFloat = 0.7
        static let initialVelocity: CGFloat = 0.5
    }
}
