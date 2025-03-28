// ContentCalendarMinimal.swift
// Simplified implementation that doesn't rely on external data

import UIKit

class ContentCalendarMinimalViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    // MARK: - Properties
    
    // Simple data structure for test content
    struct TestTitle {
        let id: Int
        let title: String
        let posterPath: String
        let releaseDate: String
        let type: String // "movie" or "tv"
    }
    
    // Grouped data
    private var monthSections: [String] = []
    private var titlesByMonth: [String: [TestTitle]] = [:]
    
    // UI Components
    private let tableView = UITableView(frame: .zero, style: .grouped)
    private let headerLabel = UILabel()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setup UI
        setupUI()
        
        // Load test data
        loadTestData()
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        title = "Coming Soon - Test"
        
        // Header label
        headerLabel.text = "Upcoming Releases"
        headerLabel.font = .boldSystemFont(ofSize: 24)
        headerLabel.textAlignment = .center
        headerLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(headerLabel)
        
        // Table view
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.backgroundColor = .systemBackground
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
        
        // Constraints
        NSLayoutConstraint.activate([
            headerLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            headerLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            headerLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            tableView.topAnchor.constraint(equalTo: headerLabel.bottomAnchor, constant: 20),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    // MARK: - Test Data
    
    private func loadTestData() {
        // Create test data with dates in the next few months
        let testTitles = [
            TestTitle(id: 1, title: "Test Movie 1", posterPath: "", releaseDate: "2025-04-15", type: "movie"),
            TestTitle(id: 2, title: "Test Movie 2", posterPath: "", releaseDate: "2025-04-28", type: "movie"),
            TestTitle(id: 3, title: "Test TV Show 1", posterPath: "", releaseDate: "2025-05-10", type: "tv"),
            TestTitle(id: 4, title: "Test Movie 3", posterPath: "", releaseDate: "2025-05-22", type: "movie"),
            TestTitle(id: 5, title: "Test TV Show 2", posterPath: "", releaseDate: "2025-06-05", type: "tv"),
            TestTitle(id: 6, title: "Test Movie 4", posterPath: "", releaseDate: "2025-06-17", type: "movie")
        ]
        
        // Group by month
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        let monthFormatter = DateFormatter()
        monthFormatter.dateFormat = "MMMM yyyy"
        
        var groupedTitles: [String: [TestTitle]] = [:]
        
        for title in testTitles {
            if let date = dateFormatter.date(from: title.releaseDate) {
                let monthString = monthFormatter.string(from: date)
                
                if groupedTitles[monthString] == nil {
                    groupedTitles[monthString] = []
                }
                
                groupedTitles[monthString]?.append(title)
            }
        }
        
        // Store and sort months
        monthSections = groupedTitles.keys.sorted { str1, str2 in
            if let date1 = monthFormatter.date(from: str1),
               let date2 = monthFormatter.date(from: str2) {
                return date1 < date2
            }
            return str1 < str2
        }
        
        titlesByMonth = groupedTitles
        
        // Print data for debugging
        print("Loaded \(testTitles.count) test titles")
        print("Grouped into \(monthSections.count) months")
        for month in monthSections {
            print("\(month): \(titlesByMonth[month]?.count ?? 0) titles")
        }
        
        // Reload table
        tableView.reloadData()
    }
    
    // MARK: - UITableViewDataSource
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return monthSections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let month = monthSections[section]
        return titlesByMonth[month]?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        let month = monthSections[indexPath.section]
        if let titles = titlesByMonth[month], indexPath.row < titles.count {
            let title = titles[indexPath.row]
            
            // Configure cell
            cell.textLabel?.text = title.title
            
            // Add type indicator
            if title.type == "movie" {
                cell.imageView?.image = UIImage(systemName: "film")
            } else {
                cell.imageView?.image = UIImage(systemName: "tv")
            }
            
            // Add release date
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            if let date = dateFormatter.date(from: title.releaseDate) {
                dateFormatter.dateFormat = "MMM d, yyyy"
                let formattedDate = dateFormatter.string(from: date)
                cell.detailTextLabel?.text = formattedDate
            }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return monthSections[section]
    }
    
    // MARK: - UITableViewDelegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let month = monthSections[indexPath.section]
        if let titles = titlesByMonth[month], indexPath.row < titles.count {
            let title = titles[indexPath.row]
            print("Selected: \(title.title)")
        }
    }
}
