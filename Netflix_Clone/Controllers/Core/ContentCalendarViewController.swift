// ContentCalendarViewController.swift
// Netflix_Clone
//
// Created by mohamed reda oumahdi on 28/03/2025.
//

import UIKit
import EventKit

class ContentCalendarViewController: UIViewController {
    
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
        label.font = DesignSystem.Typography.subtitle
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
        fetchUpcomingContent()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Refresh data if needed
        if upcomingTitles.isEmpty {
            fetchUpcomingContent()
        }
    }
    
    // MARK: - Setup Methods
    
    private func setupUI() {
        title = "Coming Soon"
        view.backgroundColor = .systemBackground
        navigationController?.navigationBar.prefersLargeTitles = true
        
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
            
            // Table view
            tableView.topAnchor.constraint(equalTo: segmentedControl.bottomAnchor, constant: 8),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
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
        
        // Setup pull to refresh
        refreshControl.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        tableView.refreshControl = refreshControl
    }
    
    // MARK: - Data Loading
    
    private func fetchUpcomingContent() {
        // Start loading indicators
        if !refreshControl.isRefreshing {
            LoadingView.shared.showLoading(in: view, withText: "Loading upcoming releases...")
        }
        
        // Create dispatch group to wait for both movies and TV shows
        let dispatchGroup = DispatchGroup()
        
        var movies: [Title] = []
        var tvShows: [Title] = []
        var fetchError: Error?
        
        // Fetch upcoming movies
        dispatchGroup.enter()
        APICaller.shared.getUPComingMovies { result in
            switch result {
            case .success(let titles):
                // Mark each title as a movie
                movies = titles.map { title in
                    var mutableTitle = title
                    mutableTitle.mediaType = "movie"
                    return mutableTitle
                }
            case .failure(let error):
                fetchError = error
            }
            dispatchGroup.leave()
        }
        
        // Fetch upcoming TV shows (assuming there's an API method for this)
        dispatchGroup.enter()
        // Use a method to get upcoming TV shows if available, otherwise use trending
        APICaller.shared.getTrendingTVShows { result in
            switch result {
            case .success(let titles):
                // Filter for upcoming TV shows (e.g., those with a future first air date)
                let calendar = Calendar.current
                let currentDate = Date()
                
                tvShows = titles.filter { title in
                    if let firstAirDateString = title.firstAirDate,
                       let date = DateFormatter.yearFormatter.date(from: firstAirDateString) {
                        return date > currentDate
                    }
                    return false
                }.map { title in
                    var mutableTitle = title
                    mutableTitle.mediaType = "tv"
                    return mutableTitle
                }
            case .failure(let error):
                if fetchError == nil {
                    fetchError = error
                }
            }
            dispatchGroup.leave()
        }
        
        // Process results when both calls complete
        dispatchGroup.notify(queue: .main) { [weak self] in
            guard let self = self else { return }
            
            // Hide loading indicators
            LoadingView.shared.hideLoading()
            self.refreshControl.endRefreshing()
            
            if let error = fetchError {
                if let appError = error as? AppError {
                    ErrorPresenter.showError(appError, on: self)
                } else {
                    ErrorPresenter.showError(AppError.apiError(error.localizedDescription), on: self)
                }
                return
            }
            
            // Store all upcoming titles
            self.upcomingTitles = (movies + tvShows).sorted(by: {
                let date1 = DateFormatter.yearFormatter.date(from: $0.releaseDate ?? $0.firstAirDate ?? "") ?? Date.distantFuture
                let date2 = DateFormatter.yearFormatter.date(from: $1.releaseDate ?? $1.firstAirDate ?? "") ?? Date.distantFuture
                return date1 < date2
            })
            
            // Apply current filter
            self.applyFilter()
        }
    }
    
    private func applyFilter() {
        // Apply filter based on selected segment
        switch segmentedControl.selectedSegmentIndex {
        case 1: // Movies
            filteredTitles = upcomingTitles.filter { $0.mediaType == "movie" }
        case 2: // TV Shows
            filteredTitles = upcomingTitles.filter { $0.mediaType == "tv" }
        default: // All
            filteredTitles = upcomingTitles
        }
        
        // Group by month
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
        
        // Update UI
        updateUI()
    }
    
    private func updateUI() {
        // Show empty state if needed
        emptyStateView.isHidden = !filteredTitles.isEmpty
        tableView.isHidden = filteredTitles.isEmpty
        
        // Update empty state message based on filter
        switch segmentedControl.selectedSegmentIndex {
        case 1:
            emptyStateLabel.text = "No upcoming movies found"
        case 2:
            emptyStateLabel.text = "No upcoming TV shows found"
        default:
            emptyStateLabel.text = "No upcoming releases found"
        }
        
        // Reload table data
        tableView.reloadData()
    }
    
    // MARK: - Action Methods
    
    @objc private func segmentChanged() {
        applyFilter()
    }
    
    @objc func refreshData() {
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
        return sortedMonths.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let month = sortedMonths[section]
        return groupedTitles[month]?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: TitleTableViewCell.identifier, for: indexPath) as? TitleTableViewCell else {
            return UITableViewCell()
        }
        
        let month = sortedMonths[indexPath.section]
        guard let titles = groupedTitles[month], indexPath.row < titles.count else {
            return cell
        }
        
        let title = titles[indexPath.row]
        cell.configure(with: TitleViewModel(titleName: title.displayTitle, posterURL: title.posterPath ?? ""))
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sortedMonths[section]
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 150
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let month = sortedMonths[indexPath.section]
        guard let titles = groupedTitles[month], indexPath.row < titles.count else {
            return
        }
        
        let title = titles[indexPath.row]
        
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
                    if let self = self {
                        self.navigationController?.pushViewController(viewController, animated: true)
                    }
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    if let self = self {
                        ErrorPresenter.showError(error, on: self)
                    }
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let month = sortedMonths[indexPath.section]
        guard let titles = groupedTitles[month], indexPath.row < titles.count else {
            return nil
        }
        
        let title = titles[indexPath.row]
        
        // Create "Set Reminder" action
        let reminderAction = UIContextualAction(style: .normal, title: "Remind") { [weak self] (_, _, completionHandler) in
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
            // Check if already in watchlist
            if WatchlistManager.shared.isTitleInWatchlist(id: title.id) {
                // Show already in watchlist message using our NotificationBanner
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
                            // Show success message using our NotificationBanner
                            NotificationBanner.showSuccess(
                                title: "Added to Watchlist",
                                subtitle: "\(title.displayTitle) has been added to your watchlist."
                            )
                        case .failure(let error):
                            if let self = self {
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
        header.textLabel?.font = DesignSystem.Typography.subtitle
        header.textLabel?.textColor = DesignSystem.Colors.primary
    }
}
