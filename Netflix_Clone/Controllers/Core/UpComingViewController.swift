// UpComingViewController.swift
// Netflix_Clone
//
// Created by mohamed reda oumahdi on 27/02/2024.
// Updated on 28/03/2025.
//

import UIKit

class UpComingViewController: UIViewController {
    
    // MARK: - Properties
    
    private var titles: [Title] = []
    private var currentPage = 1
    private var isLoadingMore = false
    private var totalPages = 1
    private var contentType = "all" // "all", "movies", "tvshows"
    
    private let segmentedControl: UISegmentedControl = {
        let segmentControl = UISegmentedControl(items: ["All", "Movies", "TV Shows"])
        segmentControl.selectedSegmentIndex = 0
        segmentControl.translatesAutoresizingMaskIntoConstraints = false
        return segmentControl
    }()
    
    private let upcomingTable: UITableView = {
        let table = UITableView()
        table.register(TitleTableViewCell.self, forCellReuseIdentifier: TitleTableViewCell.identifier)
        table.backgroundColor = .systemBackground
        table.separatorStyle = .none
        table.translatesAutoresizingMaskIntoConstraints = false
        table.showsVerticalScrollIndicator = true
        return table
    }()
    
    private let refreshControl = UIRefreshControl()
    
    // Calendar views removed
    
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
    
    // MARK: - Lifecycle Methods

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupTableView()
        setupEmptyState()
        fetchUpcomingContent()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    
    // MARK: - Setup Methods
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        title = "Coming Soon"
        navigationController?.navigationBar.prefersLargeTitles = true
        
        // Add segmented control
        view.addSubview(segmentedControl)
        segmentedControl.addTarget(self, action: #selector(segmentChanged), for: .valueChanged)
        
        // Add table view
        view.addSubview(upcomingTable)
        
        
        // Add empty state view
        view.addSubview(emptyStateView)
        
        // Set up constraints
        NSLayoutConstraint.activate([
            // Segmented control
            segmentedControl.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            segmentedControl.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            segmentedControl.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            // Table view
            upcomingTable.topAnchor.constraint(equalTo: segmentedControl.bottomAnchor, constant: 8),
            upcomingTable.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            upcomingTable.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            upcomingTable.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            
            // Empty state view
            emptyStateView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyStateView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            emptyStateView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.8)
        ])
        
        // Apply design system
        applyDesignSystem()
    }
    
    private func setupTableView() {
        upcomingTable.delegate = self
        upcomingTable.dataSource = self
        
        // Add pull to refresh
        refreshControl.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        upcomingTable.refreshControl = refreshControl
    }
    
    private func setupEmptyState() {
        // Add subviews to empty state view
        emptyStateView.addSubview(emptyStateImageView)
        emptyStateView.addSubview(emptyStateLabel)
        
        // Set up constraints for empty state elements
        NSLayoutConstraint.activate([
            emptyStateImageView.topAnchor.constraint(equalTo: emptyStateView.topAnchor),
            emptyStateImageView.centerXAnchor.constraint(equalTo: emptyStateView.centerXAnchor),
            emptyStateImageView.widthAnchor.constraint(equalToConstant: 80),
            emptyStateImageView.heightAnchor.constraint(equalToConstant: 80),
            
            emptyStateLabel.topAnchor.constraint(equalTo: emptyStateImageView.bottomAnchor, constant: 16),
            emptyStateLabel.leadingAnchor.constraint(equalTo: emptyStateView.leadingAnchor),
            emptyStateLabel.trailingAnchor.constraint(equalTo: emptyStateView.trailingAnchor),
            emptyStateLabel.bottomAnchor.constraint(equalTo: emptyStateView.bottomAnchor)
        ])
    }
    
    private func applyDesignSystem() {
        // Apply design system styles
        segmentedControl.selectedSegmentTintColor = DesignSystem.Colors.primary
        segmentedControl.setTitleTextAttributes([
            .foregroundColor: UIColor.white,
            .font: DesignSystem.Typography.caption
        ], for: .selected)
        
        segmentedControl.setTitleTextAttributes([
            .foregroundColor: DesignSystem.Colors.textPrimary,
            .font: DesignSystem.Typography.caption
        ], for: .normal)
    }
    
    // Helper method removed
    
    // MARK: - Data Methods
    
    private func fetchUpcomingContent(page: Int = 1) {
        // Show loading indicator for first page
        if page == 1 && !refreshControl.isRefreshing {
            LoadingView.shared.showLoading(in: view, withText: "Loading coming soon...")
        }
        
        // Set loading state
        isLoadingMore = true
        
        // Determine which content to fetch based on selected segment
        switch contentType {
        case "movies":
            fetchUpcomingMovies(page: page)
        case "tvshows":
            fetchUpcomingTVShows(page: page)
        default:
            fetchAllUpcomingContent(page: page)
        }
    }
    
    private func fetchUpcomingMovies(page: Int) {
        APICaller.shared.getUPComingMovies(page: page) { [weak self] result in
            guard let self = self else { return }
            
            // Update loading state
            self.isLoadingMore = false
            
            DispatchQueue.main.async {
                // Hide loading indicators
                LoadingView.shared.hideLoading()
                self.refreshControl.endRefreshing()
                
                switch result {
                case .success(let response):
                    // Get today's date
                    let today = Date()
                    let dateFormatter = DateFormatter.yearFormatter
                    
                    // Filter results to only include future releases
                    let upcomingMovies = response.results.filter { movie in
                        guard let dateString = movie.releaseDate else {
                            return false
                        }
                        
                        if let releaseDate = dateFormatter.date(from: dateString) {
                            let calendar = Calendar.current
                            return calendar.startOfDay(for: releaseDate) >= calendar.startOfDay(for: today)
                        }
                        return false
                    }
                    
                    // Sort by nearest release date
                    let sortedMovies = upcomingMovies.sorted { (movie1, movie2) -> Bool in
                        let date1String = movie1.releaseDate ?? ""
                        let date2String = movie2.releaseDate ?? ""
                        
                        if let date1 = dateFormatter.date(from: date1String),
                           let date2 = dateFormatter.date(from: date2String) {
                            return date1 < date2 // Closest date first
                        }
                        return false
                    }
                
                    // For first page, replace data
                    if page == 1 {
                        self.titles = sortedMovies
                    } else {
                        // For subsequent pages, append data
                        self.titles.append(contentsOf: sortedMovies)
                    }
                    
                    // Store pagination info
                    self.currentPage = page
                    self.totalPages = response.totalPages ?? 1
                    
                    // Update UI
                    self.updateUI()
                
                case .failure(let error):
                    ErrorPresenter.showError(error, on: self)
                }
            }
        }
    }
    
    private func fetchUpcomingTVShows(page: Int) {
        APICaller.shared.getUpcomingTVShows { [weak self] result in
            guard let self = self else { return }
            
            // Update loading state
            self.isLoadingMore = false
            
            DispatchQueue.main.async {
                // Hide loading indicators
                LoadingView.shared.hideLoading()
                self.refreshControl.endRefreshing()
                
                switch result {
                case .success(let tvShows):
                    // Get today's date
                    let today = Date()
                    let dateFormatter = DateFormatter.yearFormatter
                    
                    // Filter results to only include future releases
                    let upcomingShows = tvShows.filter { show in
                        guard let dateString = show.firstAirDate ?? show.releaseDate else {
                            return false
                        }
                        
                        if let airDate = dateFormatter.date(from: dateString) {
                            let calendar = Calendar.current
                            return calendar.startOfDay(for: airDate) >= calendar.startOfDay(for: today)
                        }
                        return false
                    }
                    
                    // Sort by nearest release date
                    let sortedShows = upcomingShows.sorted { (show1, show2) -> Bool in
                        let date1String = show1.firstAirDate ?? show1.releaseDate ?? ""
                        let date2String = show2.firstAirDate ?? show2.releaseDate ?? ""
                        
                        if let date1 = dateFormatter.date(from: date1String),
                           let date2 = dateFormatter.date(from: date2String) {
                            return date1 < date2 // Closest date first
                        }
                        return false
                    }
                    
                    // Replace data
                    self.titles = sortedShows
                    
                    // Update UI
                    self.updateUI()
                
                case .failure(let error):
                    ErrorPresenter.showError(error, on: self)
                }
            }
        }
    }
    
    private func fetchAllUpcomingContent(page: Int) {
        APICaller.shared.getUpcomingContent { [weak self] result in
            guard let self = self else { return }
            
            // Update loading state
            self.isLoadingMore = false
            
            DispatchQueue.main.async {
                // Hide loading indicators
                LoadingView.shared.hideLoading()
                self.refreshControl.endRefreshing()
                
                switch result {
                case .success(let titles):
                    // Replace data (combined endpoint doesn't support pagination)
                    // Filter to only include future releases
                    let today = Date()
                    let dateFormatter = DateFormatter.yearFormatter
                    
                    let upcomingTitles = titles.filter { title in
                        let dateString = title.releaseDate ?? title.firstAirDate ?? ""
                        if let date = dateFormatter.date(from: dateString) {
                            // Include titles releasing today or in the future
                            let calendar = Calendar.current
                            return calendar.startOfDay(for: date) >= calendar.startOfDay(for: today)
                        }
                        return false // If we can't parse the date, exclude it
                    }
                    
                    // Sort by release date (nearest first)
                    self.titles = upcomingTitles.sorted { title1, title2 in
                        let date1String = title1.releaseDate ?? title1.firstAirDate ?? ""
                        let date2String = title2.releaseDate ?? title2.firstAirDate ?? ""
                        
                        let date1 = dateFormatter.date(from: date1String) ?? Date.distantFuture
                        let date2 = dateFormatter.date(from: date2String) ?? Date.distantFuture
                        
                        return date1 < date2
                    }
                    
                    // Update UI
                    self.updateUI()
                
                case .failure(let error):
                    ErrorPresenter.showError(error, on: self)
                }
            }
        }
    }
    
    private func updateUI() {
        // Show empty state view if no data
        emptyStateView.isHidden = !titles.isEmpty
        upcomingTable.isHidden = titles.isEmpty
        
        // Update empty state message based on filter
        if titles.isEmpty {
            switch contentType {
            case "movies":
                emptyStateLabel.text = "No upcoming movies found"
            case "tvshows":
                emptyStateLabel.text = "No upcoming TV shows found"
            default:
                emptyStateLabel.text = "No upcoming releases found"
            }
        }
        
        // Reload table data with animation
        UIView.transition(with: upcomingTable, duration: 0.3, options: .transitionCrossDissolve, animations: {
            self.upcomingTable.reloadData()
        })
    }
    
    private func loadMoreData() {
        // Check if we can load more pages (only for movies since TV shows don't support pagination)
        if !isLoadingMore && currentPage < totalPages && contentType == "movies" {
            fetchUpcomingContent(page: currentPage + 1)
        }
    }
    
    // MARK: - Action Methods
    
    @objc private func segmentChanged() {
        // Update content type based on selected segment
        switch segmentedControl.selectedSegmentIndex {
        case 1:
            contentType = "movies"
            upcomingTable.isHidden = false
            emptyStateView.isHidden = true
            fetchUpcomingContent()
        case 2:
            contentType = "tvshows"
            upcomingTable.isHidden = false
            emptyStateView.isHidden = true
            fetchUpcomingContent()
        default:
            contentType = "all"
            upcomingTable.isHidden = false
            emptyStateView.isHidden = true
            fetchUpcomingContent()
        }
    }
    
    @objc private func refreshData() {
        // Reset and refresh content
        currentPage = 1
        fetchUpcomingContent()
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource

extension UpComingViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return titles.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: TitleTableViewCell.identifier, for: indexPath) as? TitleTableViewCell else {
            return UITableViewCell()
        }
        
        let title = titles[indexPath.row]
        
        // Configure cell with view model
        cell.configure(with: TitleViewModel(
            titleName: title.displayTitle,
            posterURL: title.posterPath ?? "",
            releaseDate: title.formattedReleaseDate
        ))
        
        // Apply animation
        cell.transform = CGAffineTransform(translationX: 20, y: 0)
        cell.alpha = 0
        
        UIView.animate(withDuration: 0.3, delay: Double(indexPath.row) * 0.05, options: [], animations: {
            cell.transform = .identity
            cell.alpha = 1
        })
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 150
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
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
    
    // MARK: - Pagination
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let position = scrollView.contentOffset.y
        
        // Check if we're near the bottom of the table
        if position > (upcomingTable.contentSize.height - 100 - scrollView.frame.size.height) {
            loadMoreData()
        }
    }
    
    // MARK: - Swipe Actions
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let title = titles[indexPath.row]
        
        // Create "Add to Watchlist" action
        let watchlistAction = UIContextualAction(style: .normal, title: "Watchlist") { [weak self] (_, _, completionHandler) in
            if WatchlistManager.shared.isTitleInWatchlist(id: title.id) {
                // Show already in watchlist message
                NotificationBanner.showInfo(
                    title: "Already in Watchlist",
                    subtitle: "\(title.displayTitle) is already in your watchlist"
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
                                subtitle: "\(title.displayTitle) has been added to your watchlist"
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
        watchlistAction.backgroundColor = DesignSystem.Colors.accent
        watchlistAction.image = UIImage(systemName: "heart.fill")
        
        // Create and return action configuration with only watchlist action
        return UISwipeActionsConfiguration(actions: [watchlistAction])
    }
}
