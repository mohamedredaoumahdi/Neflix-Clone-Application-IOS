// ContentCalendarViewController.swift - Enhanced Debug Version
// Netflix_Clone
//
// Created by mohamed reda oumahdi on 28/03/2025.
// Updated with display fixes and debugging

import UIKit
import EventKit

class ContentCalendarViewController: UIViewController {
    
    // MARK: - Debug Controls
    
    private let debugView = UIView()
    private let debugStatusLabel = UILabel()
    private let debugLogTextView = UITextView()
    private let testDataButton = UIButton(type: .system)
    private var isDebugMode = true
    
    // MARK: - Properties
    
    // Data
    private var upcomingTitles: [Title] = []
    private var filteredTitles: [Title] = []
    private var groupedTitles: [String: [Title]] = [:] // Group by month
    private var sortedMonths: [String] = []
    
    // UI Components
    private let tableView: UITableView = {
        let table = UITableView(frame: .zero, style: .grouped)
        table.register(TitleTableViewCell.self, forCellReuseIdentifier: TitleTableViewCell.identifier)
        table.backgroundColor = .systemBackground
        table.separatorStyle = .none
        table.translatesAutoresizingMaskIntoConstraints = false
        return table
    }()
    
    private let segmentedControl: UISegmentedControl = {
        let items = ["All", "Movies", "TV Shows"]
        let control = UISegmentedControl(items: items)
        control.selectedSegmentIndex = 0
        control.translatesAutoresizingMaskIntoConstraints = false
        return control
    }()
    
    private let emptyStateView: UIView = {
        let view = UIView()
        view.isHidden = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let emptyStateImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "calendar.badge.clock")
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .systemGray
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let emptyStateLabel: UILabel = {
        let label = UILabel()
        label.text = "No upcoming releases found"
        label.font = .systemFont(ofSize: 18, weight: .semibold)
        label.textColor = .systemGray
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let refreshControl = UIRefreshControl()
    
    // MARK: - Lifecycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setupTableView()
        setupDebugUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Force a data refresh
        fetchUpcomingContent()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Log the lifecycle and view geometry
        
        // Debug UI elements visibility
        if isDebugMode {
            debugStatusLabel.text = "DEBUG ACTIVE"
            debugView.isHidden = true
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    
    // MARK: - Setup Methods
    
    private func setupUI() {
        title = "Coming Soon"
        view.backgroundColor = .systemBackground
        
        // Add segmented control
        view.addSubview(segmentedControl)
        segmentedControl.addTarget(self, action: #selector(segmentChanged), for: .valueChanged)
        
        // Add table view
        view.addSubview(tableView)
        
        // Set up empty state view
        emptyStateView.addSubview(emptyStateImageView)
        emptyStateView.addSubview(emptyStateLabel)
        view.addSubview(emptyStateView)
        
        // Set up constraints
        NSLayoutConstraint.activate([
            // Segmented control
            segmentedControl.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            segmentedControl.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            segmentedControl.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            // Table view - make sure it's visible and properly sized
            tableView.topAnchor.constraint(equalTo: segmentedControl.bottomAnchor, constant: 8),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            // Empty state view
            emptyStateView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyStateView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            emptyStateView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.8),
            
            // Empty state image view
            emptyStateImageView.topAnchor.constraint(equalTo: emptyStateView.topAnchor),
            emptyStateImageView.centerXAnchor.constraint(equalTo: emptyStateView.centerXAnchor),
            emptyStateImageView.widthAnchor.constraint(equalToConstant: 80),
            emptyStateImageView.heightAnchor.constraint(equalToConstant: 80),
            
            // Empty state label
            emptyStateLabel.topAnchor.constraint(equalTo: emptyStateImageView.bottomAnchor, constant: 16),
            emptyStateLabel.leadingAnchor.constraint(equalTo: emptyStateView.leadingAnchor),
            emptyStateLabel.trailingAnchor.constraint(equalTo: emptyStateView.trailingAnchor),
            emptyStateLabel.bottomAnchor.constraint(equalTo: emptyStateView.bottomAnchor)
        ])
    }
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        
        // Make sure the table is visible and not hidden
        tableView.isHidden = false
        
        // Setup pull to refresh
        refreshControl.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        tableView.refreshControl = refreshControl
    }
    
    private func setupDebugUI() {
        guard isDebugMode else { return }
        
        // Debug container view
        debugView.backgroundColor = UIColor.black.withAlphaComponent(0.85)
        debugView.layer.cornerRadius = 10
        debugView.layer.borderColor = UIColor.red.cgColor
        debugView.layer.borderWidth = 2
        debugView.translatesAutoresizingMaskIntoConstraints = false
        debugView.isHidden = true
        
        // Debug status label
        debugStatusLabel.text = "DEBUG MODE"
        debugStatusLabel.textColor = .red
        debugStatusLabel.font = .boldSystemFont(ofSize: 14)
        debugStatusLabel.textAlignment = .center
        debugStatusLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // Debug log text view
        debugLogTextView.text = "Debug logs will appear here...\n"
        debugLogTextView.textColor = .white
        debugLogTextView.font = .monospacedSystemFont(ofSize: 12, weight: .regular)
        debugLogTextView.backgroundColor = .clear
        debugLogTextView.isEditable = false
        debugLogTextView.isSelectable = true
        debugLogTextView.translatesAutoresizingMaskIntoConstraints = false
        
        // Test data button
        testDataButton.setTitle("Load Test Data", for: .normal)
        testDataButton.backgroundColor = .systemBlue
        testDataButton.layer.cornerRadius = 5
        testDataButton.setTitleColor(.white, for: .normal)
        testDataButton.translatesAutoresizingMaskIntoConstraints = false
        testDataButton.addTarget(self, action: #selector(loadTestDataTapped), for: .touchUpInside)
        
        // Add views to hierarchy
        debugView.addSubview(debugStatusLabel)
        debugView.addSubview(debugLogTextView)
        debugView.addSubview(testDataButton)
        view.addSubview(debugView)
        
        // Set constraints
        NSLayoutConstraint.activate([
            debugView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            debugView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            debugView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            debugView.heightAnchor.constraint(equalToConstant: 200),
            
            debugStatusLabel.topAnchor.constraint(equalTo: debugView.topAnchor, constant: 8),
            debugStatusLabel.leadingAnchor.constraint(equalTo: debugView.leadingAnchor, constant: 8),
            debugStatusLabel.trailingAnchor.constraint(equalTo: debugView.trailingAnchor, constant: -8),
            
            debugLogTextView.topAnchor.constraint(equalTo: debugStatusLabel.bottomAnchor, constant: 8),
            debugLogTextView.leadingAnchor.constraint(equalTo: debugView.leadingAnchor, constant: 8),
            debugLogTextView.trailingAnchor.constraint(equalTo: debugView.trailingAnchor, constant: -8),
            debugLogTextView.bottomAnchor.constraint(equalTo: testDataButton.topAnchor, constant: -8),
            
            testDataButton.leadingAnchor.constraint(equalTo: debugView.leadingAnchor, constant: 8),
            testDataButton.trailingAnchor.constraint(equalTo: debugView.trailingAnchor, constant: -8),
            testDataButton.bottomAnchor.constraint(equalTo: debugView.bottomAnchor, constant: -8),
            testDataButton.heightAnchor.constraint(equalToConstant: 40)
        ])
    }
    
    // MARK: - Debug Helpers
    
    private func debugLog(_ message: String) {
        guard isDebugMode else { return }
        
        // Print to console
        print("DEBUG: \(message)")
        
        // Add to UI log if available
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            // Append with timestamp
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "HH:mm:ss"
            let timestamp = dateFormatter.string(from: Date())
            
            let newLogEntry = "[\(timestamp)] \(message)\n"
            self.debugLogTextView.text += newLogEntry
            
            // Scroll to bottom
            let bottom = NSRange(location: self.debugLogTextView.text.count, length: 0)
            self.debugLogTextView.scrollRangeToVisible(bottom)
        }
    }
    
    @objc private func loadTestDataTapped() {
        
        // Reset existing data
        upcomingTitles = []
        
        // Load test data
        upcomingTitles = createTestData()
        
        // Apply filter and update UI
        applyFilter()
    }
    
    // MARK: - Data Loading
    
    @objc func fetchUpcomingContent() {
        // Show loading state
        refreshControl.beginRefreshing()
        tableView.contentOffset = CGPoint(x: 0, y: -refreshControl.frame.size.height)
        
        
        // Use the APICallers specialized method for calendar view
        APICaller.shared.getUpcomingContent { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let titles):
                // Log success
                
                // Store titles
                self.upcomingTitles = titles
                
                // Check if we got any titles
                if titles.isEmpty {
                    
                    // For debugging, load some test data if API returns empty
                    if self.isDebugMode {
                        self.upcomingTitles = self.createTestData()
                    }
                }
                
                // Apply filter and update UI
                DispatchQueue.main.async {
                    self.applyFilter()
                }
                
            case .failure(let error):
                // Log error
                self.debugLog("❌ Error: \(error.localizedDescription)")
                
                // For debugging, load some test data if API fails
                if self.isDebugMode {
                    self.debugLog("🧪 Adding test data since API failed")
                    self.upcomingTitles = self.createTestData()
                    
                    // Apply filter and update UI
                    DispatchQueue.main.async {
                        self.applyFilter()
                    }
                } else {
                    // Show error to user
                    DispatchQueue.main.async {
                        self.refreshControl.endRefreshing()
                        ErrorPresenter.showError(error, on: self)
                    }
                }
            }
        }
    }
    
    private func applyFilter() {
        // Apply filter based on selected segment
        switch segmentedControl.selectedSegmentIndex {
        case 1: // Movies
            filteredTitles = upcomingTitles.filter { $0.mediaType == "movie" }
            debugLog("🎬 Filtered to \(filteredTitles.count) movies")
        case 2: // TV Shows
            filteredTitles = upcomingTitles.filter { $0.mediaType == "tv" }
            debugLog("📺 Filtered to \(filteredTitles.count) TV shows")
        default: // All
            filteredTitles = upcomingTitles
            debugLog("📋 Showing all \(filteredTitles.count) titles")
        }
        
        // Group by month
        debugLog("🗂 Grouping titles by month...")
        groupedTitles = Dictionary(grouping: filteredTitles) { title in
            let dateString = title.releaseDate ?? title.firstAirDate ?? ""
            if let date = DateFormatter.yearFormatter.date(from: dateString) {
                let monthFormatter = DateFormatter.monthYearFormatter
                return monthFormatter.string(from: date)
            }
            return "Unknown Date"
        }
        
        // Sort months chronologically
        sortedMonths = groupedTitles.keys.sorted { month1, month2 in
            let monthFormatter = DateFormatter.monthYearFormatter
            
            let date1 = monthFormatter.date(from: month1) ?? Date.distantFuture
            let date2 = monthFormatter.date(from: month2) ?? Date.distantFuture
            
            return date1 < date2
        }
        
        // Log the organized data
        debugLog("📅 Organized into \(sortedMonths.count) months")
        
        // Update UI
        updateUI()
    }
    
    private func updateUI() {
        // Stop loading indicator
        refreshControl.endRefreshing()
        
        // Debug log the groupings
        for month in sortedMonths {
            if let titles = groupedTitles[month] {
                debugLog("  - \(month): \(titles.count) titles")
                for (index, title) in titles.enumerated() {
                    let titleName = title.originalTitle ?? title.originalName ?? "Unknown"
                    debugLog("    \(index+1). \(titleName)")
                }
            }
        }
        
        // Show empty state if needed
        emptyStateView.isHidden = !filteredTitles.isEmpty
        tableView.isHidden = filteredTitles.isEmpty
        
        if filteredTitles.isEmpty {
            debugLog("⚠️ No titles to display - showing empty state")
        } else {
            debugLog("📱 Displaying \(filteredTitles.count) titles in \(sortedMonths.count) months")
        }
        
        // Update empty state message based on filter
        switch segmentedControl.selectedSegmentIndex {
        case 1:
            emptyStateLabel.text = "No upcoming movies found"
        case 2:
            emptyStateLabel.text = "No upcoming TV shows found"
        default:
            emptyStateLabel.text = "No upcoming releases found"
        }
        
        // Force layout update
        view.setNeedsLayout()
        view.layoutIfNeeded()
        
        // Reload table data
        tableView.reloadData()
        debugLog("♻️ Table view reloaded")
        
        // Log table view state after reload
        debugLog("📊 Table sections: \(tableView.numberOfSections)")
        for section in 0..<tableView.numberOfSections {
            debugLog("  - Section \(section): \(tableView.numberOfRows(inSection: section)) rows")
        }
    }
    
    // MARK: - Test Data
    
    private func createTestData() -> [Title] {
        // Create some test titles with future release dates
        let today = Date()
        let calendar = Calendar.current
        
        // Function to create a date string for n months in the future
        func dateString(monthsFromNow: Int, day: Int = 15) -> String {
            let futureDate = calendar.date(byAdding: .month, value: monthsFromNow, to: today)!
            var components = calendar.dateComponents([.year, .month], from: futureDate)
            components.day = day
            let finalDate = calendar.date(from: components)!
            return DateFormatter.yearFormatter.string(from: finalDate)
        }
        
        // Generate test titles
        let testTitles = [
            // Movies
            Title(id: 1001, mediaType: "movie", originalTitle: "Test Upcoming Movie 1", posterPath: "/uS1AIL7I1Ycgs8PTfqkFJNxjOMH.jpg", overview: "This is a test movie coming soon.", voteCount: 0, releaseDate: dateString(monthsFromNow: 1, day: 10), voteAverage: 0.0),
            
            Title(id: 1002, mediaType: "movie", originalTitle: "Test Upcoming Movie 2", posterPath: "/rMvPXy8PUjj1o8o1pzgQbdNCsvj.jpg", overview: "Another test movie coming soon.", voteCount: 0, releaseDate: dateString(monthsFromNow: 1, day: 22), voteAverage: 0.0),
            
            Title(id: 1003, mediaType: "movie", originalTitle: "Test Upcoming Movie 3", posterPath: "/vZloFAK7NmvMGKE7VkF5UHaz0I.jpg", overview: "A movie coming out in a few months.", voteCount: 0, releaseDate: dateString(monthsFromNow: 3), voteAverage: 0.0),
            
            // TV Shows - these need firstAirDate but we'll map it after creation
            Title(id: 2001, mediaType: "tv", originalName: "Test Upcoming TV Show 1", posterPath: "/7WUHnWGx5OO145IRxPDUkQSh4C7.jpg", overview: "This is a test TV show coming soon.", voteCount: 0, releaseDate: dateString(monthsFromNow: 2, day: 5), voteAverage: 0.0),
            
            Title(id: 2002, mediaType: "tv", originalName: "Test Upcoming TV Show 2", posterPath: "/jWXrQstj7p3Wl5MfYWY6h5NRmrw.jpg", overview: "Another test TV show coming soon.", voteCount: 0, releaseDate: dateString(monthsFromNow: 3, day: 12), voteAverage: 0.0)
        ]
        
        // For TV shows, copy releaseDate to firstAirDate
        let enhancedTitles = testTitles.map { title -> Title in
            var mutableTitle = title
            if mutableTitle.mediaType == "tv" {
                // Swift doesn't allow direct setting of properties, so we reimplement firstAirDate by adding it to a dictionary
                // This is a workaround for the fact that firstAirDate isn't part of the initializer
                mutableTitle.firstAirDate = mutableTitle.releaseDate
            }
            return mutableTitle
        }
        
        debugLog("🧪 Created \(enhancedTitles.count) test titles")
        return enhancedTitles
    }
    
    // MARK: - Action Methods
    
    @objc private func segmentChanged() {
        debugLog("🔘 Segment changed to: \(segmentedControl.selectedSegmentIndex)")
        applyFilter()
    }
    
    @objc func refreshData() {
        debugLog("🔄 Manual refresh triggered")
        fetchUpcomingContent()
    }
    
    // MARK: - Helper Methods
    
    func setReminder(for title: Title) {
        // Get release date
        guard let dateString = title.releaseDate ?? title.firstAirDate,
              let releaseDate = DateFormatter.yearFormatter.date(from: dateString) else {
            ErrorPresenter.showError(AppError.unknownError, on: self)
            return
        }
        
        // Check if date is in the future
        if releaseDate < Date() {
            ErrorPresenter.showError(AppError.apiError("This title has already been released"), on: self)
            return
        }
        
        // Create calendar event with proper permission handling
        let eventStore = EKEventStore()
        
        // Check and request calendar access
        checkCalendarAuthorizationStatus(eventStore: eventStore) { [weak self] granted in
            guard let self = self else { return }
            
            if granted {
                self.createCalendarEvent(for: title, on: releaseDate, using: eventStore)
            } else {
                DispatchQueue.main.async {
                    self.showCalendarAccessDeniedAlert()
                }
            }
        }
    }
    
    private func checkCalendarAuthorizationStatus(eventStore: EKEventStore, completion: @escaping (Bool) -> Void) {
        let authStatus = EKEventStore.authorizationStatus(for: .event)
        
        switch authStatus {
        case .authorized:
            completion(true)
        case .denied, .restricted:
            completion(false)
        case .notDetermined:
            // Request access
            if #available(iOS 17.0, *) {
                eventStore.requestFullAccessToEvents { granted, error in
                    DispatchQueue.main.async {
                        completion(granted)
                    }
                }
            } else {
                eventStore.requestAccess(to: .event) { granted, error in
                    DispatchQueue.main.async {
                        completion(granted)
                    }
                }
            }
        @unknown default:
            completion(false)
        }
    }
    
    private func showCalendarAccessDeniedAlert() {
        let alert = UIAlertController(
            title: "Calendar Access Required",
            message: "Please enable calendar access in Settings to set reminders for upcoming titles.",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Open Settings", style: .default) { _ in
            if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(settingsURL)
            }
        })
        
        present(alert, animated: true)
    }
    
    private func createCalendarEvent(for title: Title, on releaseDate: Date, using eventStore: EKEventStore) {
        do {
            // Create the event
            let event = EKEvent(eventStore: eventStore)
            event.title = "Release: \(title.displayTitle)"
            event.notes = title.overview
            event.startDate = releaseDate
            event.endDate = releaseDate.addingTimeInterval(3600) // 1 hour duration
            event.calendar = eventStore.defaultCalendarForNewEvents
            
            // Save the event
            try eventStore.save(event, span: .thisEvent)
            
            // Show success message using our custom NotificationBanner
            DispatchQueue.main.async {
                NotificationBanner.showSuccess(
                    title: "Reminder Set",
                    subtitle: "A reminder has been added to your calendar for the release of '\(title.displayTitle)'"
                )
            }
        } catch {
            // Show error message
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                ErrorPresenter.showError(AppError.apiError("Failed to create reminder: \(error.localizedDescription)"), on: self)
            }
        }
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource

extension ContentCalendarViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        let count = sortedMonths.count
        debugLog("📊 numberOfSections called, returning \(count)")
        return count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard section < sortedMonths.count else {
            debugLog("❌ Section \(section) out of bounds (max: \(sortedMonths.count - 1))")
            return 0
        }
        
        let month = sortedMonths[section]
        let count = groupedTitles[month]?.count ?? 0
        debugLog("📊 numberOfRowsInSection \(section) (\(month)) called, returning \(count)")
        return count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        debugLog("📊 cellForRowAt \(indexPath.section):\(indexPath.row) called")
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: TitleTableViewCell.identifier, for: indexPath) as? TitleTableViewCell else {
            debugLog("❌ Failed to dequeue TitleTableViewCell")
            return UITableViewCell()
        }
        
        guard indexPath.section < sortedMonths.count else {
            debugLog("❌ Section \(indexPath.section) out of bounds")
            return cell
        }
        
        let month = sortedMonths[indexPath.section]
        
        guard let titles = groupedTitles[month], indexPath.row < titles.count else {
            debugLog("❌ Row \(indexPath.row) out of bounds for section \(indexPath.section)")
            return cell
        }
        
        let title = titles[indexPath.row]
        debugLog("📝 Configuring cell with \(title.displayTitle)")
        
        cell.configure(with: TitleViewModel(
            titleName: title.displayTitle,
            posterURL: title.posterPath ?? "",
            releaseDate: title.formattedReleaseDate
        ))
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        guard section < sortedMonths.count else { return nil }
        return sortedMonths[section]
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 150
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        guard indexPath.section < sortedMonths.count else { return }
        
        let month = sortedMonths[indexPath.section]
        guard let titles = groupedTitles[month], indexPath.row < titles.count else {
            return
        }
        
        let title = titles[indexPath.row]
        debugLog("👆 Selected title: \(title.displayTitle)")
        
        // Show loading indicator
        LoadingView.shared.showLoading(in: view, withText: "Loading details...")
        
        // Load detailed information
        ContentService.shared.loadDetailedTitle(for: title) { [weak self] result in
            // Hide loading indicator
            DispatchQueue.main.async {
                LoadingView.shared.hideLoading()
            }
            
            switch result {
            case .success(let viewController):
                DispatchQueue.main.async {
                    self?.debugLog("✅ Successfully loaded details view controller")
                    self?.navigationController?.pushViewController(viewController, animated: true)
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    self?.debugLog("❌ Failed to load details: \(error.localizedDescription)")
                    if let self = self {
                        ErrorPresenter.showError(error, on: self)
                    }
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        guard indexPath.section < sortedMonths.count else { return nil }
        
        let month = sortedMonths[indexPath.section]
        guard let titles = groupedTitles[month], indexPath.row < titles.count else {
            return nil
        }
        
        let title = titles[indexPath.row]
        
        // Create "Set Reminder" action
        let reminderAction = UIContextualAction(style: .normal, title: "Remind") { [weak self] (_, _, completionHandler) in
            self?.debugLog("🔔 Set reminder action tapped for \(title.displayTitle)")
            if let self = self {
                self.setReminder(for: title)
            }
            completionHandler(true)
        }
        
        // Configure appearance
        reminderAction.backgroundColor = .systemBlue
        reminderAction.image = UIImage(systemName: "bell.fill")
        
        // Create "Add to Watchlist" action
        let watchlistAction = UIContextualAction(style: .normal, title: "Watchlist") { [weak self] (_, _, completionHandler) in
            self?.debugLog("❤️ Add to watchlist action tapped for \(title.displayTitle)")
            
            // Check if already in watchlist
            if WatchlistManager.shared.isTitleInWatchlist(id: title.id) {
                // Show already in watchlist message
                NotificationBanner.showInfo(
                    title: "Already in Watchlist",
                    subtitle: "This title is already in your watchlist"
                )
            } else {
                // Add to watchlist
                WatchlistManager.shared.addToWatchlist(title: title) { result in
                    DispatchQueue.main.async {
                        switch result {
                        case .success:
                            // Show success message
                            NotificationBanner.showSuccess(
                                title: "Added to Watchlist",
                                subtitle: "\(title.displayTitle) has been added to your watchlist."
                            )
                        case .failure(let error):
                            if let self = self {
                                self.debugLog("❌ Failed to add to watchlist: \(error.localizedDescription)")
                                ErrorPresenter.showError(error, on: self)
                            }
                        }
                    }
                }
            }
            completionHandler(true)
        }
        
        // Configure appearance
        watchlistAction.backgroundColor = .systemGreen
        watchlistAction.image = UIImage(systemName: "heart.fill")
        
        // Create and return action configuration
        return UISwipeActionsConfiguration(actions: [reminderAction, watchlistAction])
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        guard let header = view as? UITableViewHeaderFooterView else { return }
        
        // Style header
        header.textLabel?.font = .systemFont(ofSize: 18, weight: .semibold)
        header.textLabel?.textColor = .systemRed
    }
}
