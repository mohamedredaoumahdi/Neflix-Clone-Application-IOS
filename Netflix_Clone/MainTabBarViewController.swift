// MainTabBarViewController.swift
// Netflix_Clone
//
// Created by mohamed reda oumahdi on 27/02/2024.
// Updated on 27/03/2025.
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
        
        // My List tab - This will be implemented in Phase 5
        let myListVC = UINavigationController(rootViewController: DownloadsViewController())
        myListVC.tabBarItem = UITabBarItem(title: "My List", image: UIImage(systemName: "list.bullet"), tag: 3)
        
        // Set view controllers
        setViewControllers([homeVC, upcomingVC, searchVC, myListVC], animated: false)
    }
    
    private func configureAppearance() {
        // Set tab bar appearance
        tabBar.tintColor = .systemRed
        tabBar.unselectedItemTintColor = .systemGray
        
        // Add slight transparency
        tabBar.backgroundImage = UIImage()
        tabBar.shadowImage = UIImage()
        tabBar.backgroundColor = UIColor.systemBackground.withAlphaComponent(0.95)
        
        // Add a top border
        let topBorder = CALayer()
        topBorder.frame = CGRect(x: 0, y: 0, width: tabBar.frame.width, height: 0.5)
        topBorder.backgroundColor = UIColor.separator.cgColor
        tabBar.layer.addSublayer(topBorder)
        
        // Set selected indicator
        if #available(iOS 15.0, *) {
            let appearance = UITabBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = UIColor.systemBackground
            
            appearance.stackedLayoutAppearance.selected.iconColor = .systemRed
            appearance.stackedLayoutAppearance.selected.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.systemRed]
            
            appearance.stackedLayoutAppearance.normal.iconColor = .systemGray
            appearance.stackedLayoutAppearance.normal.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.systemGray]
            
            tabBar.standardAppearance = appearance
            tabBar.scrollEdgeAppearance = tabBar.standardAppearance
        }
    }
}
