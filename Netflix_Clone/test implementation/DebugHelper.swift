// DebugHelper.swift
// Helper for diagnosing and fixing the calendar view

import UIKit

class DebugHelper {
    
    // MARK: - Test View Controllers
    
    static func getMinimalCalendarTestVC() -> UIViewController {
        return ContentCalendarMinimalViewController()
    }
    
    // MARK: - Integration
    
    static func overrideUpcomingTabWithTest(tabBarController: UITabBarController) {
        // Safety check
        guard tabBarController.viewControllers?.count ?? 0 >= 2 else {
            print("ERROR: Not enough tabs in tab bar controller")
            return
        }
        
        // Create test controller inside a navigation controller
        let testVC = getMinimalCalendarTestVC()
        let navController = UINavigationController(rootViewController: testVC)
        navController.tabBarItem = UITabBarItem(title: "Test Calendar", image: UIImage(systemName: "calendar"), tag: 999)
        
        // Add to tab bar
        var viewControllers = tabBarController.viewControllers ?? []
        
        // Add as a new tab
        viewControllers.append(navController)
        tabBarController.viewControllers = viewControllers
        
        // Log success
        print("Successfully added test tab. Check the rightmost tab.")
    }
    
    // MARK: - Diagnostics
    
    static func diagnoseCalendarViewController(_ viewController: UIViewController) {
        print("=== DIAGNOSTIC REPORT ===")
        
        // Log view controller hierarchy
        print("View Controller: \(type(of: viewController))")
        
        if let navigationController = viewController as? UINavigationController {
            print("Navigation Controller with \(navigationController.viewControllers.count) child controllers:")
            for (index, vc) in navigationController.viewControllers.enumerated() {
                print("  [\(index)] \(type(of: vc))")
            }
            
            // Check if there's a calendar view controller
            if let calendarVC = navigationController.viewControllers.first(where: { String(describing: type(of: $0)).contains("Calendar") }) {
                print("Found Calendar View Controller: \(type(of: calendarVC))")
                diagnoseTableViewInController(calendarVC)
            }
        } else {
            diagnoseTableViewInController(viewController)
        }
        
        print("========================")
    }
    
    static func diagnoseTableViewInController(_ viewController: UIViewController) {
        // Look for table views in the view hierarchy
        let tableViews = viewController.view.findSubviews(of: UITableView.self)
        
        print("Found \(tableViews.count) table views in \(type(of: viewController))")
        
        for (index, tableView) in tableViews.enumerated() {
            print("Table View [\(index)]:")
            print("  Frame: \(tableView.frame)")
            print("  Is Hidden: \(tableView.isHidden)")
            print("  Number of Sections: \(tableView.numberOfSections)")
            
            var totalRows = 0
            for section in 0..<tableView.numberOfSections {
                let rows = tableView.numberOfRows(inSection: section)
                totalRows += rows
                print("  Section \(section): \(rows) rows")
            }
            print("  Total Rows: \(totalRows)")
            
            // Check delegate and data source
            if let dataSource = tableView.dataSource {
                print("  Data Source: \(type(of: dataSource))")
            } else {
                print("  ⚠️ No Data Source set")
            }
            
            if let delegate = tableView.delegate {
                print("  Delegate: \(type(of: delegate))")
            } else {
                print("  ⚠️ No Delegate set")
            }
        }
    }
}

// MARK: - View Hierarchy Extensions

extension UIView {
    func findSubviews<T: UIView>(of type: T.Type) -> [T] {
        var result = subviews.compactMap { $0 as? T }
        for subview in subviews {
            result.append(contentsOf: subview.findSubviews(of: type))
        }
        return result
    }
}
