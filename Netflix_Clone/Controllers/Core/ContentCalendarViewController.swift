// ContentCalendarViewController.swift
// Netflix_Clone
//
// Created by mohamed reda oumahdi on 28/03/2025.
//

import UIKit

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
                movies = titles
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
            // Hide loading indicators
            LoadingView.shared.hideLoading()
            self?.refreshControl.endRefreshing()
            
            if let error = fetchError {
                ErrorPresenter.showError(error, on: self!)
                return
            }
            
            // Store all upcoming titles
            self?.upcomingTitles = (movies + tvShows).sorted(by: {
                let date1 = DateFormatter.yearFormatter.date(from: $0.releaseDate ?? $0.firstAirDate ?? "") ?? Date.distantFuture
                let date2 = DateFormatter.yearFormatter.date(from: $1.releaseDate ?? $1.firstAirDate ?? "") ?? Date.distantFuture
                return date1 < date2
            })
            
            // Apply current filter
            self?.applyFilter()
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
                let monthFormatter = DateFormatter()
                monthFormatter.dateFormat = "MMMM yyyy"
                return monthFormatter.string(from: date)
            }
            return "Unknown Date"
        }
        
        // Sort months chronologically
        sortedMonths = groupedTitles.keys.sorted { month1, month2 in
            let monthFormatter = DateFormatter()
            monthFormatter.dateFormat = "MMMM yyyy"
            
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
    
    @objc private func refreshData() {
        fetchUpcomingContent()
    }
    
    // MARK: - Helper Methods
    
    private func setReminder(for title: Title) {
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
        
        // Create calendar event
        let eventStore = EKEventStore()
        
        eventStore.requestAccess(to: .event) { [weak self] granted, error in
            guard granted, error == nil else {
                DispatchQueue.main.async {
                    ErrorPresenter.showError(AppError.apiError("Calendar access denied. Please enable in Settings."), on: self!)
                }
                return
            }
            
            let event = EKEvent(eventStore: eventStore)
            event.title = "Release: \(title.displayTitle)"
            event.notes = title.overview
            event.startDate = releaseDate
            event.endDate = releaseDate.addingTimeInterval(3600) // 1 hour duration
            event.calendar = eventStore.defaultCalendarForNewEvents
            
            do {
                try eventStore.save(event, span: .thisEvent)
                
                DispatchQueue.main.async {
                    let alert = UIAlertController(
                        title: "Reminder Set",
                        message: "A reminder has been added to your calendar for the release of '\(title.displayTitle)'",
                        preferredStyle: .alert
                    )
                    alert.addAction(UIAlertAction(title: "OK", style: .default))
                    self?.present(alert, animated: true)
                }
            } catch {
                DispatchQueue.main.async {
                    ErrorPresenter.showError(AppError.apiError("Failed to create reminder"), on: self!)
                }
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
                    self?.navigationController?.pushViewController(viewController, animated: true)
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    ErrorPresenter.showError(error, on: self!)
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
            self?.setReminder(for: title)
            completionHandler(true)
        }
        
        // Configure appearance
        reminderAction.backgroundColor = .systemBlue
        reminderAction.image = UIImage(systemName: "bell.fill")
        
        // Create "Add to Watchlist" action
        let watchlistAction = UIContextualAction(style: .normal, title: "Watchlist") { [weak self] (_, _, completionHandler) in
            // Check if already in watchlist
            if WatchlistManager.shared.isTitleInWatchlist(id: title.id) {
                let alert = UIAlertController(
                    title: "Already in Watchlist",
                    message: "This title is already in your watchlist",
                    preferredStyle: .alert
                )
                alert.addAction(UIAlertAction(title: "OK", style: .default))
                self?.present(alert, animated: true)
            } else {
                // Add to watchlist
                WatchlistManager.shared.addToWatchlist(title: title) { result in
                    DispatchQueue.main.async {
                        switch result {
                        case .success:
                            // Show success message
                            let banner = NotificationBanner(
                                title: "Added to Watchlist",
                                subtitle: "\(title.displayTitle) has been added to your watchlist.",
                                style: .success
                            )
                            banner.show()
                        case .failure(let error):
                            ErrorPresenter.showError(error, on: self!)
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

// MARK: - EKEvent Support

import EventKit

// MARK: - Simple Banner Notification

class NotificationBanner {
    enum BannerStyle {
        case success, error, warning, info
        
        var color: UIColor {
            switch self {
            case .success: return .systemGreen
            case .error: return .systemRed
            case .warning: return .systemYellow
            case .info: return .systemBlue
            }
        }
        
        var icon: UIImage? {
            switch self {
            case .success: return UIImage(systemName: "checkmark.circle.fill")
            case .error: return UIImage(systemName: "exclamationmark.circle.fill")
            case .warning: return UIImage(systemName: "exclamationmark.triangle.fill")
            case .info: return UIImage(systemName: "info.circle.fill")
            }
        }
    }
    
    private let title: String
    private let subtitle: String?
    private let style: BannerStyle
    private let duration: TimeInterval
    
    private var bannerView: UIView?
    
    init(title: String, subtitle: String? = nil, style: BannerStyle = .info, duration: TimeInterval = 3.0) {
        self.title = title
        self.subtitle = subtitle
        self.style = style
        self.duration = duration
    }
    
    func show() {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first else {
            return
        }
        
        // Create banner view
        let banner = UIView()
        banner.backgroundColor = style.color
        banner.layer.cornerRadius = 8
        banner.clipsToBounds = true
        banner.translatesAutoresizingMaskIntoConstraints = false
        banner.layer.shadowColor = UIColor.black.cgColor
        banner.layer.shadowOffset = CGSize(width: 0, height: 4)
        banner.layer.shadowOpacity = 0.3
        banner.layer.shadowRadius = 4
        
        // Create title label
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = DesignSystem.Typography.subtitle
        titleLabel.textColor = .white
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // Create subtitle label if needed
        let subtitleLabel = UILabel()
        subtitleLabel.text = subtitle
        subtitleLabel.font = DesignSystem.Typography.caption
        subtitleLabel.textColor = .white
        subtitleLabel.numberOfLines = 2
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // Create icon image view
        let iconImageView = UIImageView()
        iconImageView.image = style.icon
        iconImageView.tintColor = .white
        iconImageView.contentMode = .scaleAspectFit
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        
        // Add to banner
        banner.addSubview(iconImageView)
        banner.addSubview(titleLabel)
        if subtitle != nil {
            banner.addSubview(subtitleLabel)
        }
        
        // Add to window
        window.addSubview(banner)
        
        // Set constraints
        NSLayoutConstraint.activate([
            banner.topAnchor.constraint(equalTo: window.safeAreaLayoutGuide.topAnchor, constant: 8),
            banner.leadingAnchor.constraint(equalTo: window.leadingAnchor, constant: 16),
            banner.trailingAnchor.constraint(equalTo: window.trailingAnchor, constant: -16),
            
            iconImageView.leadingAnchor.constraint(equalTo: banner.leadingAnchor, constant: 16),
            iconImageView.centerYAnchor.constraint(equalTo: banner.centerYAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 24),
            iconImageView.heightAnchor.constraint(equalToConstant: 24),
            
            titleLabel.leadingAnchor.constraint(equalTo: iconImageView.trailingAnchor, constant: 12),
            titleLabel.trailingAnchor.constraint(equalTo: banner.trailingAnchor, constant: -16)
        ])
        
        if subtitle != nil {
            NSLayoutConstraint.activate([
                titleLabel.topAnchor.constraint(equalTo: banner.topAnchor, constant: 12),
                subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
                subtitleLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
                subtitleLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
                subtitleLabel.bottomAnchor.constraint(equalTo: banner.bottomAnchor, constant: -12)
            ])
        } else {
            NSLayoutConstraint.activate([
                titleLabel.topAnchor.constraint(equalTo: banner.topAnchor, constant: 12),
                titleLabel.bottomAnchor.constraint(equalTo: banner.bottomAnchor, constant: -12)
            ])
        }
        
        self.bannerView = banner
        
        // Animate in
        banner.transform = CGAffineTransform(translationX: 0, y: -200)
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.5, options: [], animations: {
            banner.transform = .identity
        }, completion: { _ in
            // Animate out after duration
            DispatchQueue.main.asyncAfter(deadline: .now() + self.duration) {
                UIView.animate(withDuration: 0.3, animations: {
                    banner.transform = CGAffineTransform(translationX: 0, y: -200)
                    banner.alpha = 0
                }, completion: { _ in
                    banner.removeFromSuperview()
                    self.bannerView = nil
                })
            }
        })
    }
}

