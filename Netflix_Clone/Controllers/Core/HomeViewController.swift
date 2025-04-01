// HomeViewController.swift
// Netflix_Clone
//
// Created by mohamed reda oumahdi on 27/02/2024.
// Updated for full-screen hero header

import UIKit

enum Sections: Int {
    case TrendingMovies = 0
    case TrendingTVShows = 1
    case Popular = 2
    case UpcomingMovies = 3
    case RecentReleases = 4
    case TopRated = 5
}

class HomeViewController: UIViewController {
    
    // MARK: - Properties
    
    private var randomTrendingMovie: Title?
    private var headerView: HeroHeaderUIView?
    
    private let sectionTitles: [String] = [
        "Trending Movies",
        "Trending TV Shows",
        "Popular",
        "Upcoming Movies",
        "Recently Released",
        "Top Rated"
    ]
    
    // MARK: - UI Components
    
    private let homeFeedTable: UITableView = {
        let table = UITableView(frame: .zero, style: .grouped)
        table.register(CollectionTableViewCell.self, forCellReuseIdentifier: CollectionTableViewCell.identifier)
        table.showsVerticalScrollIndicator = false
        table.separatorStyle = .none
        table.backgroundColor = .systemBackground
        return table
    }()
    
    private let refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.tintColor = .label
        return refreshControl
    }()
    
    // MARK: - Lifecycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        
        // Configure UI
        setupNavigationBar()
        setupTableView()
        setupHeroHeader()
        
        // Show loading indicator
        LoadingView.shared.showLoading(in: view, withText: "Loading content...")
        
        // Fetch initial data
        configureHeroHeaderView()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        homeFeedTable.frame = view.bounds
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Ensure navigation bar is hidden at top level
        navigationController?.navigationBar.alpha = 0
        
        print("View appeared - forcing table reload")
        homeFeedTable.reloadData()
    }
    
    deinit {
        // Remove observer when view controller is deallocated
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Setup Methods
    
    private func setupNavigationBar() {
        // Make navigation bar transparent
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.isTranslucent = true
        
        // Hide navigation bar by default
        navigationController?.navigationBar.alpha = 0
    }
    
    private func setupTableView() {
        // Add table view to view hierarchy
        view.addSubview(homeFeedTable)
        
        // Configure table
        homeFeedTable.delegate = self
        homeFeedTable.dataSource = self
        
        // Set up pull to refresh
        homeFeedTable.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        
        // Critical: Disable content inset adjustment to remove the gap
        homeFeedTable.contentInsetAdjustmentBehavior = .never
        
        // Remove any table view insets
        homeFeedTable.contentInset = .zero
        homeFeedTable.scrollIndicatorInsets = .zero
        
        // Disable section header top padding (iOS 15+)
        if #available(iOS 15.0, *) {
            homeFeedTable.sectionHeaderTopPadding = 0
        }
    }
    
    private func setupHeroHeader() {
        // Calculate status bar height (for extending header to the top)
        let statusBarHeight = view.window?.windowScene?.statusBarManager?.statusBarFrame.height ?? 0
        
        // Create hero header with proper frame including status bar height
        let headerHeight = 500 // Base height for the hero header
        headerView = HeroHeaderUIView(frame: CGRect(
            x: 0,
            y: 0,
            width: view.bounds.width,
            height: CGFloat(headerHeight) + statusBarHeight
        ))
        
        // Set as table header
        homeFeedTable.tableHeaderView = headerView
        
        // Set up observer for preview button taps
        setupHeaderPreviewHandler()
    }
    
    private func setupHeaderPreviewHandler() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleHeroHeaderPreviewTap),
            name: .heroHeaderPreviewTapped,
            object: nil
        )
    }
    
    // MARK: - Data Loading Methods
    
    @objc private func refreshData() {
        // Refresh header content
        configureHeroHeaderView()
        
        // Reload table with smooth animation
        UIView.transition(with: homeFeedTable, duration: 0.35, options: .transitionCrossDissolve, animations: {
            self.homeFeedTable.reloadData()
        }, completion: nil)
    }
    
    private func configureHeroHeaderView() {
        APICaller.shared.getTrendingMovies { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                
                switch result {
                case .success(let titles):
                    // Hide loading indicator
                    LoadingView.shared.hideLoading()
                    self.refreshControl.endRefreshing()
                    
                    // Set random trending movie for header
                    if let selectedTitle = titles.randomElement() {
                        self.randomTrendingMovie = selectedTitle
                        
                        // Create view model for header
                        let viewModel = TitleViewModel(
                            titleName: selectedTitle.originalTitle ?? selectedTitle.originalName ?? "",
                            posterURL: selectedTitle.posterPath ?? ""
                        )
                        
                        // Configure header with data
                        self.headerView?.configure(with: viewModel)
                    }
                    
                case .failure(let error):
                    // Hide loading indicators
                    LoadingView.shared.hideLoading()
                    self.refreshControl.endRefreshing()
                    
                    // Show appropriate error
                    if let appError = error as? AppError {
                        ErrorPresenter.showError(appError, on: self)
                    } else {
                        ErrorPresenter.showError(AppError.apiError(error.localizedDescription), on: self)
                    }
                }
            }
        }
    }
    
    @objc private func handleHeroHeaderPreviewTap() {
        guard let title = randomTrendingMovie else {
            return
        }
        
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
                    if let self = self {
                        ErrorPresenter.showError(error, on: self)
                    }
                }
            }
        }
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource

extension HomeViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sectionTitles.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: CollectionTableViewCell.identifier, for: indexPath) as? CollectionTableViewCell else {
            return UITableViewCell()
        }
        
        // Set delegate for handling cell tap events
        cell.delegate = self
        
        // Show loading indicator in the cell
        cell.showSkeletonLoading()
        
        // Fetch data based on section
        switch indexPath.section {
        case Sections.TrendingMovies.rawValue:
            APICaller.shared.getTrendingMovies { [weak self] result in
                self?.handleAPIResponse(result, for: cell, section: indexPath.section)
            }
            
        case Sections.TrendingTVShows.rawValue:
            APICaller.shared.getTrendingTVShows { [weak self] result in
                self?.handleAPIResponse(result, for: cell, section: indexPath.section)
            }
            
        case Sections.Popular.rawValue:
            APICaller.shared.getPopularMovies { [weak self] result in
                self?.handleAPIResponse(result, for: cell, section: indexPath.section)
            }
            
        case Sections.UpcomingMovies.rawValue:
            APICaller.shared.getUpcomingMoviesSorted { [weak self] result in
                self?.handleAPIResponse(result, for: cell, section: indexPath.section)
            }
            
        case Sections.RecentReleases.rawValue:
            APICaller.shared.getRecentReleases { [weak self] result in
                self?.handleAPIResponse(result, for: cell, section: indexPath.section)
            }
            
        case Sections.TopRated.rawValue:
            APICaller.shared.getTopRatedMovies { [weak self] result in
                self?.handleAPIResponse(result, for: cell, section: indexPath.section)
            }
            
        default:
            return UITableViewCell()
        }
        
        return cell
    }
    
    private func handleAPIResponse(_ result: Result<[Title], Error>, for cell: CollectionTableViewCell, section: Int) {
        DispatchQueue.main.async {
            switch result {
            case .success(let titles):
                // Check which section we're processing
                let isRecentReleasesSection = section == Sections.RecentReleases.rawValue
                let isTopRatedSection = section == Sections.TopRated.rawValue
                
                // Configure with appropriate flags
                cell.configure(
                    with: titles,
                    isRecentReleasesSection: isRecentReleasesSection,
                    isTopRatedSection: isTopRatedSection
                )
                
            case .failure(let error):
                cell.hideSkeletonLoading()
                // Convert to user-friendly error message
                let errorMessage: String
                if let apiError = error as? APIError {
                    switch apiError {
                    case .failedToGetData:
                        errorMessage = "Couldn't load content. Please try again."
                    case .invalidURL:
                        errorMessage = "Invalid URL. Please report this issue."
                    case .noDataReturned:
                        errorMessage = "No data received from server."
                    case .decodingError:
                        errorMessage = "Error processing the data."
                    }
                } else {
                    errorMessage = "Something went wrong. Try refreshing."
                }
                cell.showError(message: errorMessage)
                print("Error: \(error.localizedDescription)")
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 200
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        guard let header = view as? UITableViewHeaderFooterView else { return }
        
        // Style the header
        header.textLabel?.font = .systemFont(ofSize: 18, weight: .semibold)
        header.textLabel?.textColor = .label
        header.textLabel?.text = header.textLabel?.text?.capitalizeFirstLetter()
        
        // Update frame for better positioning
        if let textLabel = header.textLabel {
            textLabel.frame = CGRect(x: 20,
                                    y: header.bounds.origin.y,
                                    width: header.bounds.width - 40,
                                    height: header.bounds.height)
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sectionTitles[section]
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offset = scrollView.contentOffset.y
        
        // Show/hide navigation bar based on scroll position
        if offset > 100 {
            // User has scrolled down - show navigation bar with animation
            UIView.animate(withDuration: 0.3) {
                self.navigationController?.navigationBar.alpha = 1
            }
        } else {
            // User is at the top - hide navigation bar
            UIView.animate(withDuration: 0.3) {
                self.navigationController?.navigationBar.alpha = 0
            }
        }
    }
}

// MARK: - CollectionViewTableViewCellDelegate

extension HomeViewController: ColletionViewTableViewCellDelegate {
    // Legacy method for backward compatibility
    func colletionViewTableViewCellDidTapCell(_ cell: CollectionTableViewCell, viewModel: TitlePreviewViewModel) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            let vc = TitlePreviewViewController()
            vc.configure(with: viewModel)
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    // New method using the updated naming
    func collectionViewDidTapCellWithViewModel(_ cell: CollectionTableViewCell, viewModel: TitlePreviewViewModel) {
        // Present bottom sheet directly with the view model
        let bottomSheet = ContentDetailBottomSheet(with: viewModel)
        present(bottomSheet, animated: false)
    }
    
    // Updated method for handling title selection
    func collectionViewDidTapCellWithTitle(_ cell: CollectionTableViewCell, title: Title) {
        // Show loading indicator
        LoadingView.shared.showLoading(in: view, withText: "Loading details...")
        
        // Load detailed title info using ContentService
        ContentService.shared.loadDetailedTitle(for: title) { [weak self] result in
            // Hide loading indicator
            DispatchQueue.main.async {
                LoadingView.shared.hideLoading()
            }
            
            switch result {
            case .success(let viewController):
                DispatchQueue.main.async {
                    guard let self = self else { return }
                    self.navigationController?.pushViewController(viewController, animated: true)
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    guard let self = self else { return }
                    ErrorPresenter.showError(error, on: self)
                }
            }
        }
    }
    
    // Legacy method for backward compatibility
    func colletionViewTableViewCellDidTapCell(_ cell: CollectionTableViewCell, title: Title) {
        collectionViewDidTapCellWithTitle(cell, title: title)
    }
}
