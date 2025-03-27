// WatchlistViewController.swift
// Netflix_Clone
//
// Created by mohamed reda oumahdi on 28/03/2025.
//

import UIKit
import CoreData

class WatchlistViewController: UIViewController {
    
    // MARK: - Properties
    
    private var watchlistItems: [WatchlistItem] = []
    
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(TitleTableViewCell.self, forCellReuseIdentifier: TitleTableViewCell.identifier)
        tableView.backgroundColor = .systemBackground
        tableView.separatorStyle = .none
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    private let emptyStateView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isHidden = true
        return view
    }()
    
    private let emptyStateImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "list.and.film")
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .systemGray
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let emptyStateLabel: UILabel = {
        let label = UILabel()
        label.text = "Your watchlist is empty"
        label.textAlignment = .center
        label.font = DesignSystem.Typography.subtitle
        label.textColor = .systemGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let emptyStateDescriptionLabel: UILabel = {
        let label = UILabel()
        label.text = "Movies and TV shows you add to your watchlist will appear here"
        label.textAlignment = .center
        label.font = DesignSystem.Typography.body
        label.textColor = .systemGray
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let refreshControl = UIRefreshControl()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setupTableView()
        setupNotifications()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchWatchlist()
    }
    
    // MARK: - Setup Methods
    
    private func setupUI() {
        title = "My List"
        view.backgroundColor = .systemBackground
        navigationController?.navigationBar.prefersLargeTitles = true
        
        // Add tableView
        view.addSubview(tableView)
        
        // Setup empty state view
        emptyStateView.addSubview(emptyStateImageView)
        emptyStateView.addSubview(emptyStateLabel)
        emptyStateView.addSubview(emptyStateDescriptionLabel)
        view.addSubview(emptyStateView)
        
        // Setup constraints
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            emptyStateView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyStateView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            emptyStateView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.8),
            
            emptyStateImageView.topAnchor.constraint(equalTo: emptyStateView.topAnchor),
            emptyStateImageView.centerXAnchor.constraint(equalTo: emptyStateView.centerXAnchor),
            emptyStateImageView.widthAnchor.constraint(equalToConstant: 80),
            emptyStateImageView.heightAnchor.constraint(equalToConstant: 80),
            
            emptyStateLabel.topAnchor.constraint(equalTo: emptyStateImageView.bottomAnchor, constant: 16),
            emptyStateLabel.leadingAnchor.constraint(equalTo: emptyStateView.leadingAnchor),
            emptyStateLabel.trailingAnchor.constraint(equalTo: emptyStateView.trailingAnchor),
            
            emptyStateDescriptionLabel.topAnchor.constraint(equalTo: emptyStateLabel.bottomAnchor, constant: 8),
            emptyStateDescriptionLabel.leadingAnchor.constraint(equalTo: emptyStateView.leadingAnchor),
            emptyStateDescriptionLabel.trailingAnchor.constraint(equalTo: emptyStateView.trailingAnchor),
            emptyStateDescriptionLabel.bottomAnchor.constraint(equalTo: emptyStateView.bottomAnchor)
        ])
    }
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        
        // Add pull to refresh
        refreshControl.addTarget(self, action: #selector(refreshWatchlist), for: .valueChanged)
        tableView.refreshControl = refreshControl
    }
    
    private func setupNotifications() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(watchlistUpdated),
            name: .watchlistUpdated,
            object: nil
        )
    }
    
    // MARK: - Data Methods
    
    private func fetchWatchlist() {
        // Show loading indicator
        if !refreshControl.isRefreshing {
            LoadingView.shared.showLoading(in: view, withText: "Loading My List...")
        }
        
        WatchlistManager.shared.fetchWatchlist { [weak self] result in
            DispatchQueue.main.async {
                // Hide loading indicators
                LoadingView.shared.hideLoading()
                self?.refreshControl.endRefreshing()
                
                switch result {
                case .success(let items):
                    self?.watchlistItems = items
                    self?.tableView.reloadData()
                    
                    // Show empty state view if needed
                    self?.updateEmptyState()
                    
                case .failure(let error):
                    ErrorPresenter.showError(error, on: self!)
                }
            }
        }
    }
    
    private func updateEmptyState() {
        if watchlistItems.isEmpty {
            emptyStateView.isHidden = false
            tableView.isHidden = true
        } else {
            emptyStateView.isHidden = true
            tableView.isHidden = false
        }
    }
    
    // MARK: - Action Methods
    
    @objc private func refreshWatchlist() {
        fetchWatchlist()
    }
    
    @objc private func watchlistUpdated() {
        fetchWatchlist()
    }
    
    // MARK: - Helper Methods
    
    private func confirmDelete(for item: WatchlistItem, at indexPath: IndexPath) {
        let alert = UIAlertController(
            title: "Remove from My List",
            message: "Are you sure you want to remove '\(item.title ?? "this title")' from your list?",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        alert.addAction(UIAlertAction(title: "Remove", style: .destructive) { [weak self] _ in
            self?.removeFromWatchlist(item: item, at: indexPath)
        })
        
        present(alert, animated: true)
    }
    
    private func removeFromWatchlist(item: WatchlistItem, at indexPath: IndexPath) {
        WatchlistManager.shared.removeFromWatchlist(id: Int(item.id)) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    // Remove from local array
                    self?.watchlistItems.remove(at: indexPath.row)
                    
                    // Delete row with animation
                    self?.tableView.deleteRows(at: [indexPath], with: .automatic)
                    
                    // Check if we need to show empty state
                    self?.updateEmptyState()
                    
                case .failure(let error):
                    ErrorPresenter.showError(error, on: self!)
                }
            }
        }
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource

extension WatchlistViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return watchlistItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: TitleTableViewCell.identifier, for: indexPath) as? TitleTableViewCell else {
            return UITableViewCell()
        }
        
        let item = watchlistItems[indexPath.row]
        
        // Configure the cell
        let viewModel = TitleViewModel(
            titleName: item.title ?? "Unknown",
            posterURL: item.posterPath ?? ""
        )
        
        cell.configure(with: viewModel)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 150
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let item = watchlistItems[indexPath.row]
        
        // Convert WatchlistItem to Title
        let title = WatchlistManager.shared.convertToTitle(from: item)
        
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
        // Create delete action
        let deleteAction = UIContextualAction(style: .destructive, title: "Remove") { [weak self] (_, _, completionHandler) in
            guard let self = self else { return }
            
            let item = self.watchlistItems[indexPath.row]
            self.confirmDelete(for: item, at: indexPath)
            
            completionHandler(true)
        }
        
        // Configure delete action
        deleteAction.backgroundColor = .systemRed
        deleteAction.image = UIImage(systemName: "trash")
        
        // Return swipe configuration
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
}
