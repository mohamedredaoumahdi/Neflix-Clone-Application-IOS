// UpComingViewController+Diagnostics.swift
// Temporary extension to add diagnostic capabilities

import UIKit

extension UpComingViewController {
    
    // Additional method to use our minimal calendar implementation
    func useMinimalCalendarImplementation() {
        // Remove old calendar view container if it exists
        calendarContainerView.subviews.forEach { $0.removeFromSuperview() }
        
        // Replace with our minimal implementation
        let minimalCalendar = ContentCalendarMinimalViewController()
        add(minimalCalendar, to: calendarContainerView)
        
        // Store reference
        self.calendarViewController = minimalCalendar as? ContentCalendarViewController
        
        // Make sure it's visible if calendar tab is selected
        if segmentedControl.selectedSegmentIndex == 1 {
            calendarContainerView.isHidden = false
            upcomingTable.isHidden = true
        }
        
        print("Replaced calendar implementation with minimal version")
    }
    
    // This will be called from the debug menu
    @objc func loadTestData() {
        let testVC = ContentCalendarMinimalViewController()
        
        // Present as a modal for testing
        let navController = UINavigationController(rootViewController: testVC)
        present(navController, animated: true)
    }
    
    // Helper method to print diagnostic information about our views
    @objc func printCalendarDiagnostics() {
        print("===== UPCOMING VIEW CONTROLLER DIAGNOSTICS =====")
        print("segmentedControl.selectedSegmentIndex: \(segmentedControl.selectedSegmentIndex)")
        print("calendarContainerView.isHidden: \(calendarContainerView.isHidden)")
        print("upcomingTable.isHidden: \(upcomingTable.isHidden)")
        
        print("\nCalendar container view:")
        print("Frame: \(calendarContainerView.frame)")
        print("Bounds: \(calendarContainerView.bounds)")
        print("Subviews count: \(calendarContainerView.subviews.count)")
        
        // Print info about each subview
        for (index, subview) in calendarContainerView.subviews.enumerated() {
            print("Subview \(index):")
            print("  Type: \(type(of: subview))")
            print("  Frame: \(subview.frame)")
            print("  isHidden: \(subview.isHidden)")
        }
        
        // Check if we have a calendar view controller
        if let calendarVC = calendarViewController {
            print("\nCalendar View Controller:")
            print("Type: \(type(of: calendarVC))")
            print("View is loaded: \(calendarVC.isViewLoaded)")
            print("View frame: \(calendarVC.view.frame)")
            
            // Look for table views in the calendar view controller
            let tableViews = calendarVC.view.findSubviews(of: UITableView.self)
            print("Found \(tableViews.count) table views in calendar controller")
            
            for (index, tableView) in tableViews.enumerated() {
                print("Table View \(index):")
                print("  Frame: \(tableView.frame)")
                print("  isHidden: \(tableView.isHidden)")
                print("  Number of sections: \(tableView.numberOfSections)")
                
                var totalRows = 0
                for section in 0..<tableView.numberOfSections {
                    let rows = tableView.numberOfRows(inSection: section)
                    totalRows += rows
                    print("  Section \(section): \(rows) rows")
                }
                print("  Total rows: \(totalRows)")
            }
        } else {
            print("\nNo calendar view controller found!")
        }
        
        print("=================================================")
    }
}
