// HomeViewController.swift
// Netflix_Clone
//
// Enhanced with professional design elements and animations
//

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
    
    // Properties for handling empty sections
    private var visibleSections: [Int] = []
    private var emptySections: Set<Int> = []
    
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
    
    private let scrollToTopButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "arrow.up.circle.fill"), for: .normal)
        button.tintColor = DesignSystem.Colors.primary
        button.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        button.layer.cornerRadius = 25
        button.alpha = 0 // Hidden initially
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // MARK: - Lifecycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Initialize visible sections (all sections visible at first)
        visibleSections = Array(0..<sectionTitles.count)
        
        view.backgroundColor = .systemBackground
        
        // Setup key UI components
        setupNavigationBar()
        setupTableView()
        setupScrollToTopButton()
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
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Restore navigation bar when leaving the view
        UIView.animate(withDuration: 0.2) {
            self.navigationController?.navigationBar.alpha = 1.0
        }
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
    
    private func setupScrollToTopButton() {
        view.addSubview(scrollToTopButton)
        
        NSLayoutConstraint.activate([
            scrollToTopButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            scrollToTopButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            scrollToTopButton.widthAnchor.constraint(equalToConstant: 50),
            scrollToTopButton.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        scrollToTopButton.addTarget(self, action: #selector(scrollToTop), for: .touchUpInside)
    }
    
    private func setupHeroHeader() {
        // Calculate status bar height (for extending header to the top)
        let statusBarHeight = view.window?.windowScene?.statusBarManager?.statusBarFrame.height ?? 0
        
        // Create hero header with proper frame including status bar height
        let headerHeight = 550 // Slightly taller for better impact
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
    
    // MARK: - UI Action Methods
    
    @objc private func scrollToTop() {
        // Add haptic feedback
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.prepare()
        generator.impactOccurred()
        
        // Scroll to top with animation
        homeFeedTable.setContentOffset(.zero, animated: true)
    }
    
    @objc private func refreshData() {
        // Reset empty sections to try loading all sections again
        emptySections.removeAll()
        visibleSections = Array(0..<sectionTitles.count)
        
        // Refresh header content
        configureHeroHeaderView()
        
        // Reload table with smooth animation
        UIView.transition(with: homeFeedTable, duration: 0.35, options: .transitionCrossDissolve, animations: {
            self.homeFeedTable.reloadData()
        }, completion: nil)
    }
    
    // Helper method to update visible sections
    private func updateVisibleSections() {
        // Create a new array with only non-empty sections
        visibleSections = (0..<sectionTitles.count).filter { !emptySections.contains($0) }
        
        // Reload the table with animation
        UIView.transition(with: homeFeedTable, duration: 0.3, options: .transitionCrossDissolve, animations: {
            self.homeFeedTable.reloadData()
        })
    }
    
    // MARK: - Data Loading Methods
    
    private func configureHeroHeaderView() {
        APICaller.shared.getTrendingMovies { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                
                switch result {
                case .success(let titles):
                    // Hide loading indicator
                    LoadingView.shared.hideLoading()
                    self.refreshControl.endRefreshing()
                    
                    // Filter for high-quality poster images
                    let filteredTitles = titles.filter { $0.posterPath != nil && !($0.posterPath?.isEmpty ?? true) }
                    
                    // Set random trending movie for header
                    if let selectedTitle = filteredTitles.randomElement() ?? titles.randomElement() {
                        self.randomTrendingMovie = selectedTitle
                        
                        // Determine if it's a top-rated title
                        let isTopRated = selectedTitle.voteAverage ?? 0 >= 7.5
                        
                        // Create view model for header
                        let viewModel = TitleViewModel(
                            titleName: selectedTitle.originalTitle ?? selectedTitle.originalName ?? "",
                            posterURL: selectedTitle.posterPath ?? "",
                            releaseDate: selectedTitle.formattedReleaseDate,
                            isNewRelease: false,
                            isTopRated: isTopRated
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
        
        // Add haptic feedback
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.prepare()
        generator.impactOccurred()
        
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
        // Only return visible sections count
        return visibleSections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: CollectionTableViewCell.identifier, for: indexPath) as? CollectionTableViewCell else {
            return UITableViewCell()
        }
        
        // Apply subtle fade-in animation to each row
        cell.alpha = 0
        cell.transform = CGAffineTransform(translationX: 20, y: 0)
        
        UIView.animate(withDuration: 0.4, delay: 0.05 * Double(indexPath.section), options: .curveEaseOut, animations: {
            cell.alpha = 1
            cell.transform = .identity
        })
        
        // Set delegate for handling cell tap events
        cell.delegate = self
        
        // Show loading indicator in the cell
        cell.showSkeletonLoading()
        
        // Get the actual section index from our visible sections array
        let actualSection = visibleSections[indexPath.section]
        
        // Fetch data based on actual section
        switch actualSection {
        case Sections.TrendingMovies.rawValue:
            APICaller.shared.getTrendingMovies { [weak self] result in
                self?.handleAPIResponse(result, for: cell, section: actualSection)
            }
            
        case Sections.TrendingTVShows.rawValue:
            APICaller.shared.getTrendingTVShows { [weak self] result in
                self?.handleAPIResponse(result, for: cell, section: actualSection)
            }
            
        case Sections.Popular.rawValue:
            APICaller.shared.getPopularMovies { [weak self] result in
                self?.handleAPIResponse(result, for: cell, section: actualSection)
            }
            
        case Sections.UpcomingMovies.rawValue:
            APICaller.shared.getUpcomingMoviesSorted { [weak self] result in
                self?.handleAPIResponse(result, for: cell, section: actualSection)
            }
            
        case Sections.RecentReleases.rawValue:
            APICaller.shared.getRecentReleases { [weak self] result in
                self?.handleAPIResponse(result, for: cell, section: actualSection)
            }
            
        case Sections.TopRated.rawValue:
            APICaller.shared.getTopRatedMovies { [weak self] result in
                self?.handleAPIResponse(result, for: cell, section: actualSection)
            }
            
        default:
            return UITableViewCell()
        }
        
        return cell
    }
    
    private func handleAPIResponse(_ result: Result<[Title], Error>, for cell: CollectionTableViewCell, section: Int) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            switch result {
            case .success(let titles):
                // Check if titles array is empty
                if titles.isEmpty {
                    // If empty, hide this section
                    self.emptySections.insert(section)
                    self.updateVisibleSections()
                    return
                }
                
                // If we have content, make sure section is visible
                if self.emptySections.contains(section) {
                    self.emptySections.remove(section)
                    self.updateVisibleSections()
                }
                
                // Check which section we're processing
                let isRecentReleasesSection = section == Sections.RecentReleases.rawValue
                let isTopRatedSection = section == Sections.TopRated.rawValue
                
                // Configure with appropriate flags
                cell.configure(
                    with: titles,
                    isRecentReleasesSection: isRecentReleasesSection,
                    isTopRatedSection: isTopRatedSection
                )
                
                // Add subtle animation when content loads
                cell.contentLoaded()
                
            case .failure(let error):
                // Hide section on error
                self.emptySections.insert(section)
                self.updateVisibleSections()
                
                print("Error in section \(section): \(error.localizedDescription)")
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
        header.textLabel?.font = .systemFont(ofSize: 18, weight: .bold)
        header.textLabel?.textColor = .label
        header.textLabel?.text = header.textLabel?.text?.capitalizeFirstLetter()
        
        // Add a subtle red accent to the first letter
        if let text = header.textLabel?.text, !text.isEmpty {
            let attributedText = NSMutableAttributedString(string: text)
            attributedText.addAttribute(.foregroundColor, value: DesignSystem.Colors.primary, range: NSRange(location: 0, length: 1))
            header.textLabel?.attributedText = attributedText
        }
        
        // Update frame for better positioning
        if let textLabel = header.textLabel {
            textLabel.frame = CGRect(x: 20,
                                    y: header.bounds.origin.y,
                                    width: header.bounds.width - 40,
                                    height: header.bounds.height)
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        // Use the visibleSections array to map to the correct section title
        let actualSection = visibleSections[section]
        return sectionTitles[actualSection]
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offset = scrollView.contentOffset.y
        
        // Apply parallax effect to hero header if the method exists
        if let headerView = headerView as? HeroHeaderUIView {
            if headerView.responds(to: #selector(HeroHeaderUIView.applyParallaxEffect(withOffset:))) {
                headerView.perform(#selector(HeroHeaderUIView.applyParallaxEffect(withOffset:)), with: offset)
            }
        }
        
        // Show/hide navigation bar based on scroll position
        if offset > 100 {
            // User has scrolled down - show navigation bar with animation
            UIView.animate(withDuration: 0.3) {
                self.navigationController?.navigationBar.alpha = 1
            }
            
            // Show scroll to top button
            if scrollToTopButton.alpha == 0 {
                UIView.animate(withDuration: 0.3) {
                    self.scrollToTopButton.alpha = 1
                }
            }
        } else {
            // User is at the top - hide navigation bar
            UIView.animate(withDuration: 0.3) {
                self.navigationController?.navigationBar.alpha = 0
            }
            
            // Hide scroll to top button
            if scrollToTopButton.alpha == 1 {
                UIView.animate(withDuration: 0.3) {
                    self.scrollToTopButton.alpha = 0
                }
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
        // Add haptic feedback
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.prepare()
        generator.impactOccurred()
        
        // Present bottom sheet directly with the view model
        let bottomSheet = ContentDetailBottomSheet(with: viewModel)
        present(bottomSheet, animated: false)
    }
    
    // Updated method for handling title selection
    func collectionViewDidTapCellWithTitle(_ cell: CollectionTableViewCell, title: Title) {
        // Add haptic feedback
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.prepare()
        generator.impactOccurred()
        
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
