//
//  UpComingViewController.swift
//  Netflix_Clone
//
//  Created by mohamed reda oumahdi on 27/02/2024.
//  Updated on 28/03/2025.
//

import UIKit

class UpComingViewController: UIViewController {
    
    // MARK: - Properties
    
    private var titles: [Title] = []
    private var currentPage = 1
    private var isLoadingMore = false
    private var totalPages = 1
    
    private let segmentedControl: UISegmentedControl = {
        let segmentControl = UISegmentedControl(items: ["List View", "Calendar"])
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
    
    private lazy var calendarContainerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isHidden = true
        return view
    }()
    
    private lazy var calendarViewController: ContentCalendarViewController = {
        let viewController = ContentCalendarViewController()
        self.add(viewController, to: calendarContainerView)
        return viewController
    }()
    
    // MARK: - Lifecycle Methods

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupTableView()
        fetchUpcomingMovies()
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
        
        // Add calendar container view
        view.addSubview(calendarContainerView)
        
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
            
            // Calendar container view
            calendarContainerView.topAnchor.constraint(equalTo: segmentedControl.bottomAnchor, constant: 8),
            calendarContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            calendarContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            calendarContainerView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
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
    
    // Helper to add child view controller
    private func add(_ child: UIViewController, to containerView: UIView) {
        addChild(child)
        containerView.addSubview(child.view)
        child.view.frame = containerView.bounds
        child.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        child.didMove(toParent: self)
    }
    
    // MARK: - Data Methods
    
    private func fetchUpcomingMovies(page: Int = 1) {
        // Show loading indicator for first page
        if page == 1 && !refreshControl.isRefreshing {
            LoadingView.shared.showLoading(in: view, withText: "Loading coming soon...")
        }
        
        // Set loading state
        isLoadingMore = true
        
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
                    // For first page, replace data
                    if page == 1 {
                        self.titles = response.results
                    } else {
                        // For subsequent pages, append data
                        self.titles.append(contentsOf: response.results)
                    }
                    
                    // Store pagination info
                    self.currentPage = page
                    self.totalPages = response.totalPages ?? 1
                    
                    // Reload table data
                    UIView.transition(with: self.upcomingTable, duration: 0.3, options: .transitionCrossDissolve, animations: {
                        self.upcomingTable.reloadData()
                    }, completion: nil)
                
                case .failure(let error):
                    ErrorPresenter.showError(error, on: self)
                }
            }
        }
    }
    
    private func loadMoreData() {
        // Check if we can load more pages
        if !isLoadingMore && currentPage < totalPages {
            fetchUpcomingMovies(page: currentPage + 1)
        }
    }
    
    // MARK: - Action Methods
    
    @objc private func segmentChanged() {
        if segmentedControl.selectedSegmentIndex == 0 {
            // Show list view
            calendarContainerView.isHidden = true
            upcomingTable.isHidden = false
        } else {
            // Show calendar view
            calendarContainerView.isHidden = false
            upcomingTable.isHidden = true
        }
    }
    
    @objc private func refreshData() {
        if segmentedControl.selectedSegmentIndex == 0 {
            // Refresh list view
            fetchUpcomingMovies()
        } else {
            // Refresh calendar view
            calendarViewController.refreshData()
        }
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
                    self?.navigationController?.pushViewController(viewController, animated: true)
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    ErrorPresenter.showError(error, on: self!)
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
                let banner = NotificationBanner(
                    title: "Already in Watchlist",
                    subtitle: "\(title.displayTitle) is already in your watchlist",
                    style: .info
                )
                banner.show()
            } else {
                // Add to watchlist
                WatchlistManager.shared.addToWatchlist(title: title) { result in
                    DispatchQueue.main.async {
                        switch result {
                        case .success:
                            // Show success message
                            let banner = NotificationBanner(
                                title: "Added to Watchlist",
                                subtitle: "\(title.displayTitle) has been added to your watchlist",
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
        watchlistAction.backgroundColor = DesignSystem.Colors.accent
        watchlistAction.image = UIImage(systemName: "heart.fill")
        
        // Create "Set Reminder" action
        let reminderAction = UIContextualAction(style: .normal, title: "Remind") { [weak self] (_, _, completionHandler) in
            self?.calendarViewController.setReminder(for: title)
            completionHandler(true)
        }
        
        // Configure appearance
        reminderAction.backgroundColor = DesignSystem.Colors.success
        reminderAction.image = UIImage(systemName: "bell.fill")
        
        // Create and return action configuration
        return UISwipeActionsConfiguration(actions: [watchlistAction, reminderAction])
    }
}

// MARK: - Extended APICaller Method

extension APICaller {
    // Get upcoming movies with pagination
    func getUPComingMovies(page: Int = 1, completion: @escaping (Result<TrendingTitleResponse, Error>) -> Void) {
        guard let url = URL(string: "\(Configuration.URLs.TMDB_BASE_URL)/movie/upcoming?language=en-US&page=\(page)") else {
            completion(.failure(APIError.invalidURL))
            return
        }
        
        let request = createRequest(with: url)
        executeRequest(request: request, completion: completion)
    }
}
