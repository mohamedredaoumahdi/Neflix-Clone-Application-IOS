// MainTabBarViewController+Debug.swift
// Temporary extension to help debug the calendar issue

import UIKit

extension MainTabBarViewController {
    
    // Call this from viewDidLoad to enable diagnostics
    func enableCalendarDiagnostics() {
        // Add a test calendar tab
        DebugHelper.overrideUpcomingTabWithTest(tabBarController: self)
        
        // Add a notification observer for tab bar selection
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(tabBarSelectionChanged),
            name: UITabBar.didSelectItemNotification,
            object: nil
        )
        
        // Add debug alert button to all viewControllers
        addDebugButtonToViewControllers()
        
        print("Calendar diagnostics enabled")
    }
    
    private func addDebugButtonToViewControllers() {
        guard let viewControllers = viewControllers else { return }
        
        for vc in viewControllers {
            if let navController = vc as? UINavigationController {
                for childVC in navController.viewControllers {
                    if String(describing: type(of: childVC)).contains("Coming") ||
                       String(describing: type(of: childVC)).contains("Calendar") {
                        addDebugButtonToNavigationBar(for: childVC)
                    }
                }
            }
        }
    }
    
    private func addDebugButtonToNavigationBar(for viewController: UIViewController) {
        let debugButton = UIBarButtonItem(
            title: "Debug",
            style: .plain,
            target: self,
            action: #selector(debugButtonTapped)
        )
        
        viewController.navigationItem.rightBarButtonItem = debugButton
    }
    
    @objc private func debugButtonTapped(_ sender: UIBarButtonItem) {
        // Show debug menu
        showDebugMenu()
    }
    
    @objc private func tabBarSelectionChanged(_ notification: Notification) {
        print("Tab selection changed")
        
        // Find the selected view controller
        if let selectedVC = selectedViewController {
            DebugHelper.diagnoseCalendarViewController(selectedVC)
        }
    }
    
    private func showDebugMenu() {
        let alertController = UIAlertController(title: "Debug Menu", message: nil, preferredStyle: .actionSheet)
        
        // Add actions for debugging
        alertController.addAction(UIAlertAction(title: "Run Diagnostics", style: .default) { [weak self] _ in
            guard let self = self else { return }
            
            if let selectedVC = self.selectedViewController {
                DebugHelper.diagnoseCalendarViewController(selectedVC)
            }
        })
        
        alertController.addAction(UIAlertAction(title: "Load Test Data", style: .default) { [weak self] _ in
            guard let self = self else { return }
            
            if let selectedVC = self.selectedViewController as? UINavigationController,
               let upcomingVC = selectedVC.topViewController as? UpComingViewController {
                // Try to find and call a method that would load test data
                if upcomingVC.responds(to: Selector(("loadTestData"))) {
                    upcomingVC.perform(Selector(("loadTestData")))
                } else {
                    print("loadTestData method not found on UpComingViewController")
                }
            }
        })
        
        alertController.addAction(UIAlertAction(title: "Switch to Test Tab", style: .default) { [weak self] _ in
            guard let self = self else { return }
            
            // Select the last tab which should be our test tab
            if let viewControllers = self.viewControllers,
               viewControllers.count > 0 {
                self.selectedIndex = viewControllers.count - 1
            }
        })
        
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        // Present from the current top view controller
        if let topVC = UIApplication.shared.windows.first?.rootViewController?.topMostViewController() {
            topVC.present(alertController, animated: true)
        }
    }
}

// Helper to find the top-most view controller
extension UIViewController {
    func topMostViewController() -> UIViewController {
        if let presented = presentedViewController {
            return presented.topMostViewController()
        }
        
        if let tabBarController = self as? UITabBarController,
           let selectedViewController = tabBarController.selectedViewController {
            return selectedViewController.topMostViewController()
        }
        
        if let navigationController = self as? UINavigationController,
           let visibleViewController = navigationController.visibleViewController {
            return visibleViewController.topMostViewController()
        }
        
        return self
    }
}
