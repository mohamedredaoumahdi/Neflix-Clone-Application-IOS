// HomeViewController.swift
// Netflix_Clone
//
// Created by mohamed reda oumahdi on 27/02/2024.
// Updated on 27/03/2025.
//

import UIKit

enum Sections: Int {
    case TrendingMovies = 0
    case TrendingTVShows = 1
    case Popular = 2
    case UpcomingMovies = 3
    case TopRated = 4
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
        view.addSubview(homeFeedTable)
        
        homeFeedTable.delegate = self
        homeFeedTable.dataSource = self
        homeFeedTable.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        
        configureNavBar()
        
        headerView = HeroHeaderUIView(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: 500))
        homeFeedTable.tableHeaderView = headerView
        
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
        print("View appeared - forcing table reload")
        homeFeedTable.reloadData()
    }
    
    // MARK: - Setup Methods
    
    private func configureNavBar() {
        var image = UIImage(named: "netflix_logo")
        image = image?.withRenderingMode(.alwaysOriginal)
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: image, style: .done, target: self, action: nil)
        
        navigationItem.rightBarButtonItems = [
            UIBarButtonItem(image: UIImage(systemName: "person"), style: .done, target: self, action: nil),
            UIBarButtonItem(image: UIImage(systemName: "play.rectangle"), style: .done, target: self, action: nil),
        ]
        
        navigationController?.navigationBar.tintColor = .label
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
    }
    
    // MARK: - Data Loading Methods
    
    @objc private func refreshData() {
        // Refresh all sections
        configureHeroHeaderView()
        
        // Reload table with animation
        UIView.transition(with: homeFeedTable, duration: 0.35, options: .transitionCrossDissolve, animations: {
            self.homeFeedTable.reloadData()
        }, completion: nil)
    }
    
    private func configureHeroHeaderView() {
        APICaller.shared.getTrendingMovies { [weak self] result in
            // Always handle UI updates on the main thread
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
                        
                        // Create detailed view model for header
                        let viewModel = TitleViewModel(
                            titleName: selectedTitle.originalTitle ?? selectedTitle.originalName ?? "",
                            posterURL: selectedTitle.posterPath ?? ""
                        )
                        
                        // Already on main thread
                        self.headerView?.configure(with: viewModel)
                    }
                    
                case .failure(let error):
                    // Hide loading and show error
                    LoadingView.shared.hideLoading()
                    self.refreshControl.endRefreshing()
                    
                    if let appError = error as? AppError {
                        ErrorPresenter.showError(appError, on: self)
                    } else {
                        ErrorPresenter.showError(AppError.apiError(error.localizedDescription), on: self)
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
                self?.handleAPIResponse(result, for: cell)
            }
            
        case Sections.TrendingTVShows.rawValue:
            APICaller.shared.getTrendingTVShows { [weak self] result in
                self?.handleAPIResponse(result, for: cell)
            }
            
        case Sections.Popular.rawValue:
            APICaller.shared.getPopularMovies { [weak self] result in
                self?.handleAPIResponse(result, for: cell)
            }
            
        case Sections.UpcomingMovies.rawValue:
            APICaller.shared.getUPComingMovies { [weak self] result in
                self?.handleAPIResponse(result, for: cell)
            }
            
        case Sections.TopRated.rawValue:
            APICaller.shared.getTopRatedMovies { [weak self] result in
                self?.handleAPIResponse(result, for: cell)
            }
            
        default:
            return UITableViewCell()
        }
        
        return cell
    }
    
    // Helper method to handle API responses
    private func handleAPIResponse(_ result: Result<[Title], Error>, for cell: CollectionTableViewCell) {
        DispatchQueue.main.async {
            switch result {
            case .success(let titles):
                cell.hideSkeletonLoading()
                cell.configure(with: titles)
                
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
        let defaultOffset = view.safeAreaInsets.top
        let offset = scrollView.contentOffset.y + defaultOffset
        
        // Animate navbar hiding when scrolling down
        navigationController?.navigationBar.transform = .init(translationX: 0, y: min(0, -offset))
    }
}

// MARK: - ColletionViewTableViewCellDelegate

// Update to match the new delegate methods in CollectionTableViewCell
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
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            let vc = TitlePreviewViewController()
            vc.configure(with: viewModel)
            self.navigationController?.pushViewController(vc, animated: true)
        }
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
