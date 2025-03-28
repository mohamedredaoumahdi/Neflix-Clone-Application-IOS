// MainTabBarViewController.swift
// Netflix_Clone
//
// Created by mohamed reda oumahdi on 27/02/2024.
// Updated to fix subscript errors
//

import UIKit

class MainTabBarViewController: UITabBarController {

    // MARK: - Lifecycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViewControllers()
        configureAppearance()
    }
    
    // MARK: - Setup Methods
    
    private func setupViewControllers() {
        // Home tab
        let homeVC = UINavigationController(rootViewController: HomeViewController())
        homeVC.tabBarItem = UITabBarItem(title: "Home", image: UIImage(systemName: "house"), tag: 0)
        
        // Upcoming tab
        let upcomingVC = UINavigationController(rootViewController: UpComingViewController())
        upcomingVC.tabBarItem = UITabBarItem(title: "Coming Soon", image: UIImage(systemName: "play.circle"), tag: 1)
        
        // Search tab
        let searchVC = UINavigationController(rootViewController: SearchViewController())
        searchVC.tabBarItem = UITabBarItem(title: "Search", image: UIImage(systemName: "magnifyingglass"), tag: 2)
        
        // My List tab
        let myListVC = UINavigationController(rootViewController: WatchlistViewController())
        myListVC.tabBarItem = UITabBarItem(title: "My List", image: UIImage(systemName: "heart"), tag: 3)
        
        // Set view controllers
        setViewControllers([homeVC, upcomingVC, searchVC, myListVC], animated: false)
    }
    
    private func configureAppearance() {
        // Set tab bar appearance
        if #available(iOS 15.0, *) {
            let appearance = UITabBarAppearance()
            appearance.configureWithDefaultBackground()
            
            // Background color
            appearance.backgroundColor = DesignSystem.Colors.backgroundElevated
            
            // Selected item appearance
            appearance.stackedLayoutAppearance.selected.iconColor = DesignSystem.Colors.primary
            appearance.stackedLayoutAppearance.selected.titleTextAttributes = [
                NSAttributedString.Key.foregroundColor: DesignSystem.Colors.primary,
                NSAttributedString.Key.font: DesignSystem.Typography.tabBar
            ]
            
            // Normal item appearance
            appearance.stackedLayoutAppearance.normal.iconColor = DesignSystem.Colors.textSecondary
            appearance.stackedLayoutAppearance.normal.titleTextAttributes = [
                NSAttributedString.Key.foregroundColor: DesignSystem.Colors.textSecondary,
                NSAttributedString.Key.font: DesignSystem.Typography.tabBar
            ]
            
            tabBar.standardAppearance = appearance
            tabBar.scrollEdgeAppearance = appearance
        } else {
            // Fallback for iOS 14 and earlier
            tabBar.tintColor = DesignSystem.Colors.primary
            tabBar.unselectedItemTintColor = DesignSystem.Colors.textSecondary
            tabBar.backgroundColor = DesignSystem.Colors.backgroundElevated
        }
        
        // Add shadow to tab bar
        tabBar.layer.shadowColor = UIColor.black.cgColor
        tabBar.layer.shadowOffset = CGSize(width: 0, height: -1)
        tabBar.layer.shadowOpacity = 0.2
        tabBar.layer.shadowRadius = 4
        
        // Configure navigation bar appearance for all child view controllers
        configureGlobalNavigationBarAppearance()
    }
    
    private func configureGlobalNavigationBarAppearance() {
        // Create appearance object for navigation bar
        let navigationBarAppearance = UINavigationBarAppearance()
        navigationBarAppearance.configureWithOpaqueBackground()
        
        // Set background color
        navigationBarAppearance.backgroundColor = DesignSystem.Colors.backgroundElevated
        
        // Configure title text attributes
        navigationBarAppearance.titleTextAttributes = [
            NSAttributedString.Key.foregroundColor: DesignSystem.Colors.textPrimary,
            NSAttributedString.Key.font: DesignSystem.Typography.subtitle
        ]
        
        // Configure large title text attributes
        navigationBarAppearance.largeTitleTextAttributes = [
            NSAttributedString.Key.foregroundColor: DesignSystem.Colors.textPrimary,
            NSAttributedString.Key.font: DesignSystem.Typography.largeTitle
        ]
        
        // Apply the appearance to all navigation controllers
        UINavigationBar.appearance().standardAppearance = navigationBarAppearance
        UINavigationBar.appearance().compactAppearance = navigationBarAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = navigationBarAppearance
        
        // Configure other navigation bar properties
        UINavigationBar.appearance().tintColor = DesignSystem.Colors.primary
        
        // Apply custom transition animation for navigation controller
        let customTransition = CATransition()
        customTransition.duration = 0.3
        customTransition.type = .fade
        customTransition.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        UINavigationBar.appearance().layer.add(customTransition, forKey: nil)
    }
    
    // MARK: - Tab Switching Animation
    
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        // Get the index of the selected tab
        guard let index = tabBar.items?.firstIndex(of: item) else { return }
        
        // Make sure the index is valid
        guard index + 1 < tabBar.subviews.count else { return }
        
        // Find the tab view
        let tabView = tabBar.subviews[index + 1]
        
        // Find the icon view inside the tab view
        let iconView = tabView.subviews.first { $0 is UIImageView }
        
        // Create a spring animation for the icon
        UIView.animate(withDuration: 0.2, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 1, options: [], animations: {
            iconView?.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
        }, completion: { _ in
            UIView.animate(withDuration: 0.2, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 1, options: [], animations: {
                iconView?.transform = .identity
            })
        })
        
        // Provide haptic feedback
        AnimationHelper.selectionFeedback()
    }
}

