// AnimationHelper.swift
// Netflix_Clone
//
// Created by mohamed reda oumahdi on 28/03/2025.
//

import UIKit

/// Helper class for common animations used throughout the app
class AnimationHelper {
    
    // MARK: - Loading Animations
    
    /// Adds a shimmer effect to the provided view for skeleton loading
    static func addShimmerEffect(to view: UIView) {
        // Remove any existing shimmer
        view.layer.sublayers?.filter { $0.name == "shimmerLayer" }.forEach { $0.removeFromSuperlayer() }
        
        // Create gradient layer
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
        animation.timingFunction = DesignSystem.Animation.easeInOut
        
        gradientLayer.add(animation, forKey: "shimmerAnimation")
    }
    
    /// Removes the shimmer effect from the view
    static func removeShimmerEffect(from view: UIView) {
        view.layer.sublayers?.filter { $0.name == "shimmerLayer" }.forEach { $0.removeFromSuperlayer() }
    }
    
    // MARK: - Transition Animations
    
    /// Performs a fade in animation for the given view
    static func fadeIn(_ view: UIView, duration: TimeInterval = DesignSystem.Animation.standardDuration, completion: ((Bool) -> Void)? = nil) {
        view.alpha = 0
        view.isHidden = false
        
        UIView.animate(withDuration: duration, animations: {
            view.alpha = 1
        }, completion: completion)
    }
    
    /// Performs a fade out animation for the given view
    static func fadeOut(_ view: UIView, duration: TimeInterval = DesignSystem.Animation.standardDuration, completion: ((Bool) -> Void)? = nil) {
        UIView.animate(withDuration: duration, animations: {
            view.alpha = 0
        }, completion: { finished in
            view.isHidden = true
            completion?(finished)
        })
    }
    
    /// Performs a subtle zoom and fade animation for a cell being selected
    static func pulseAnimation(for view: UIView) {
        UIView.animate(withDuration: DesignSystem.Animation.quickDuration, animations: {
            view.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        }, completion: { _ in
            UIView.animate(withDuration: DesignSystem.Animation.quickDuration) {
                view.transform = .identity
            }
        })
    }
    
    // MARK: - Parallax Effects
    
    /// Adds parallax effect to a header view based on scroll view offset
    static func applyParallaxEffect(to headerView: UIView, scrollView: UIScrollView, intensity: CGFloat = 0.5) {
        let offsetY = scrollView.contentOffset.y
        
        if offsetY < 0 {
            // Scrolling down (pulling down)
            let scaleFactor = 1 + abs(offsetY) / 1000 * intensity
            headerView.transform = CGAffineTransform(scaleX: scaleFactor, y: scaleFactor)
            
            // Adjust the position to keep the top edge aligned
            headerView.frame.origin.y = 0
        } else {
            // Scrolling up (standard scrolling behavior)
            headerView.transform = .identity
            headerView.frame.origin.y = -offsetY * intensity
        }
    }
    
    // MARK: - Interactive Feedback
    
    /// Provides haptic feedback for selection
    static func selectionFeedback() {
        let generator = UISelectionFeedbackGenerator()
        generator.prepare()
        generator.selectionChanged()
    }
    
    /// Provides haptic feedback for impact (light)
    static func lightImpactFeedback() {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.prepare()
        generator.impactOccurred()
    }
    
    /// Provides haptic feedback for impact (medium)
    static func mediumImpactFeedback() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.prepare()
        generator.impactOccurred()
    }
}
