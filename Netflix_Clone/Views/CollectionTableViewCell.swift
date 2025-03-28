// CollectionTableViewCell.swift
// Netflix_Clone
//
// Created by mohamed reda oumahdi on 27/02/2024.
// Updated on 27/03/2025.
//

import UIKit

// Fixed delegate protocol with clearer method names
protocol ColletionViewTableViewCellDelegate: AnyObject {
    // Renamed for clarity and to avoid ambiguity
    func collectionViewDidTapCellWithViewModel(_ cell: CollectionTableViewCell, viewModel: TitlePreviewViewModel)
    func collectionViewDidTapCellWithTitle(_ cell: CollectionTableViewCell, title: Title)
}

// For backward compatibility, provide default implementations
extension ColletionViewTableViewCellDelegate {
    // Default implementation for legacy support
    func colletionViewTableViewCellDidTapCell(_ cell: CollectionTableViewCell, viewModel: TitlePreviewViewModel) {
        collectionViewDidTapCellWithViewModel(cell, viewModel: viewModel)
    }
    
    // Default implementation for legacy support
    func colletionViewTableViewCellDidTapCell(_ cell: CollectionTableViewCell, title: Title) {
        collectionViewDidTapCellWithTitle(cell, title: title)
    }
    
    // Default implementations if not implemented by conforming types
    func collectionViewDidTapCellWithViewModel(_ cell: CollectionTableViewCell, viewModel: TitlePreviewViewModel) {}
    func collectionViewDidTapCellWithTitle(_ cell: CollectionTableViewCell, title: Title) {}
}

class CollectionTableViewCell: UITableViewCell {
    
    // MARK: - Properties
    
    static let identifier = "CollectionTableViewCell"
    
    weak var delegate: ColletionViewTableViewCellDelegate?
    
    private var titles: [Title] = []
    private var viewModels: [TitleViewModel] = []
    
    // MARK: - UI Components
    
    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 140, height: 200)
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 10
        layout.minimumLineSpacing = 10
        layout.sectionInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(TitleCollectionViewCell.self, forCellWithReuseIdentifier: TitleCollectionViewCell.identifier)
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.backgroundColor = .systemBackground
        return collectionView
    }()
    
    private let errorView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBackground
        view.isHidden = true
        return view
    }()
    
    private let errorLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.textColor = .secondaryLabel
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let retryButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Retry", for: .normal)
        button.tintColor = .systemBlue
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // Skeleton views for loading state
    private var skeletonCells: [UIView] = []
    
    // MARK: - Initialization
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setupUI()
        setupSkeletonViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        collectionView.frame = contentView.bounds
        errorView.frame = contentView.bounds
        
        // Update skeleton views positions
        updateSkeletonLayout()
    }
    
    // MARK: - Setup Methods
    
    private func setupUI() {
        contentView.backgroundColor = .systemBackground
        
        // Collection View
        contentView.addSubview(collectionView)
        collectionView.delegate = self
        collectionView.dataSource = self
        
        // Error View
        contentView.addSubview(errorView)
        errorView.addSubview(errorLabel)
        errorView.addSubview(retryButton)
        
        NSLayoutConstraint.activate([
            errorLabel.centerXAnchor.constraint(equalTo: errorView.centerXAnchor),
            errorLabel.centerYAnchor.constraint(equalTo: errorView.centerYAnchor, constant: -20),
            errorLabel.leadingAnchor.constraint(equalTo: errorView.leadingAnchor, constant: 20),
            errorLabel.trailingAnchor.constraint(equalTo: errorView.trailingAnchor, constant: -20),
            
            retryButton.centerXAnchor.constraint(equalTo: errorView.centerXAnchor),
            retryButton.topAnchor.constraint(equalTo: errorLabel.bottomAnchor, constant: 10),
        ])
        
        retryButton.addTarget(self, action: #selector(retryButtonTapped), for: .touchUpInside)
    }
    
    private func setupSkeletonViews() {
        // Create 5 skeleton cells for loading state
        for _ in 0..<5 {
            let skeletonView = UIView()
            skeletonView.backgroundColor = UIColor.systemGray5
            skeletonView.layer.cornerRadius = 8
            contentView.addSubview(skeletonView)
            skeletonView.isHidden = true
            skeletonCells.append(skeletonView)
        }
    }
    
    private func updateSkeletonLayout() {
        let cellWidth: CGFloat = 140
        let cellHeight: CGFloat = 200
        let spacing: CGFloat = 10
        let leftInset: CGFloat = 10
        
        for (index, view) in skeletonCells.enumerated() {
            let xPosition = leftInset + CGFloat(index) * (cellWidth + spacing)
            view.frame = CGRect(x: xPosition, y: contentView.bounds.height/2 - cellHeight/2, width: cellWidth, height: cellHeight)
            view.layer.cornerRadius = 8
        }
    }
    
    // MARK: - Public Methods
    
    // Updated configure method to handle recent releases section
    public func configure(with titles: [Title], isRecentReleasesSection: Bool = false, isTopRatedSection: Bool = false) {
            self.titles = titles
            
            // Create view models based on section type and content
            self.viewModels = titles.map { title in
                // Check if it's a new release
                let isNew = isRecentReleasesSection && isNewRelease(title: title)
                
                // Check if it's top rated
                let isTopRated = isTopRatedSection || (title.voteAverage ?? 0.0 >= 8.0)
                
                return TitleViewModel(
                    titleName: title.displayTitle,
                    posterURL: title.posterPath ?? "",
                    releaseDate: title.formattedReleaseDate,
                    isNewRelease: isNew,
                    isTopRated: isTopRated
                )
            }
            
            hideSkeletonLoading()
            collectionView.reloadData()
        }
        
        // Helper method to determine if a title is a new release
        private func isNewRelease(title: Title) -> Bool {
            // Calculate threshold date for "NEW" badge (7 days)
            let calendar = Calendar.current
            let oneWeekAgo = calendar.date(byAdding: .day, value: -7, to: Date())!
            
            // Get the release date
            let dateString = title.releaseDate ?? title.firstAirDate ?? ""
            if let releaseDate = DateFormatter.yearFormatter.date(from: dateString) {
                // Compare to threshold (e.g., last 7 days)
                return releaseDate >= oneWeekAgo
            }
            return false
        }
    
    // Returns the currently selected title if there is one, or the first title as a fallback
    func getCurrentTitle() -> Title? {
        if let indexPaths = collectionView.indexPathsForSelectedItems, let indexPath = indexPaths.first {
            return titles[indexPath.row]
        }
        return titles.first
    }
    
    func showSkeletonLoading() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            self.collectionView.isHidden = true
            self.errorView.isHidden = true
            
            // Show and animate skeleton views
            for view in self.skeletonCells {
                view.isHidden = false
                
                // Add shimmer effect
                self.addShimmerEffect(to: view)
            }
        }
    }
    
    func hideSkeletonLoading() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            self.collectionView.isHidden = false
            
            // Hide skeleton views and remove animations
            for view in self.skeletonCells {
                view.isHidden = true
                view.layer.removeAllAnimations()
            }
        }
    }
    
    func showError(message: String) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            self.collectionView.isHidden = true
            self.errorView.isHidden = false
            self.errorLabel.text = message
            
            // Hide skeleton views
            for view in self.skeletonCells {
                view.isHidden = true
                view.layer.removeAllAnimations()
            }
        }
    }
    
    // MARK: - Helper Methods
    
    private func addShimmerEffect(to view: UIView) {
        // Remove any existing shimmer effects
        view.layer.sublayers?.filter { $0.name == "shimmerLayer" }.forEach { $0.removeFromSuperlayer() }
        
        // Create shimmer animation
        let gradient = CAGradientLayer()
        gradient.name = "shimmerLayer"
        gradient.frame = view.bounds
        gradient.colors = [
            UIColor.systemGray5.cgColor,
            UIColor.systemGray3.cgColor,
            UIColor.systemGray5.cgColor
        ]
        gradient.startPoint = CGPoint(x: 0.0, y: 0.5)
        gradient.endPoint = CGPoint(x: 1.0, y: 0.5)
        gradient.locations = [0.0, 0.5, 1.0]
        view.layer.addSublayer(gradient)
        
        // Add animation
        let animation = CABasicAnimation(keyPath: "locations")
        animation.fromValue = [-1.0, -0.5, 0.0]
        animation.toValue = [1.0, 1.5, 2.0]
        animation.duration = 1.5
        animation.repeatCount = .infinity
        gradient.add(animation, forKey: "shimmerAnimation")
    }
    
    @objc private func retryButtonTapped() {
        // Notify parent view controller to retry loading
        showSkeletonLoading()
        // The HomeViewController will handle reloading this section
    }
}

// MARK: - UICollectionViewDelegate, UICollectionViewDataSource

extension CollectionTableViewCell: UICollectionViewDelegate, UICollectionViewDataSource {
    
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return titles.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TitleCollectionViewCell.identifier, for: indexPath) as? TitleCollectionViewCell else {
            return UICollectionViewCell()
        }
        
        // Use view model if available
        if indexPath.row < viewModels.count {
            cell.configure(with: viewModels[indexPath.row])
        } else if indexPath.row < titles.count {
            // Fallback to old method
            let title = titles[indexPath.row]
            if let posterPath = title.posterPath {
                cell.configure(with: posterPath)
            }
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
            collectionView.deselectItem(at: indexPath, animated: true)
            
            guard indexPath.row < titles.count else { return }
            
            let title = titles[indexPath.row]
            
            // Use the delegate to pass the title
            delegate?.collectionViewDidTapCellWithTitle(self, title: title)
        }
    
    func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        // Bounds check to prevent crashes
        guard indexPath.row < titles.count else {
            return nil
        }
        
        let config = UIContextMenuConfiguration(
            identifier: nil,
            previewProvider: { [weak self] in
                // Create a preview view controller
                let previewVC = TitlePreviewViewController()
                
                if let self = self, indexPath.row < self.titles.count,
                   let title = self.titles[safe: indexPath.row],
                   let titleName = title.originalTitle ?? title.originalName,
                   let overview = title.overview {
                    
                    // Create a simple preview without the YouTube video
                    let viewModel = TitlePreviewViewModel(
                        title: titleName,
                        youtubeView: nil,
                        titleOverview: overview,
                        releaseDate: title.releaseDate,
                        voteAverage: title.voteAverage
                    )
                    
                    previewVC.configure(with: viewModel)
                }
                
                return previewVC
            },
            actionProvider: { [weak self] _ in
                guard let self = self, indexPath.row < self.titles.count else {
                    return nil
                }
                
                let saveAction = UIAction(
                    title: "Add to My List",
                    image: UIImage(systemName: "plus"),
                    identifier: nil
                ) { _ in
                    // Implementation for adding to watchlist
                    if let title = self.titles[safe: indexPath.row] {
                        WatchlistManager.shared.addToWatchlist(title: title) { _ in
                            // Implementation could be enhanced with success/failure handling
                        }
                    }
                }
                
                let shareAction = UIAction(
                    title: "Share",
                    image: UIImage(systemName: "square.and.arrow.up"),
                    identifier: nil
                ) { _ in
                    // Share functionality
                    if let title = self.titles[safe: indexPath.row] {
                        let titleName = title.originalTitle ?? title.originalName ?? "Movie"
                        let activityVC = UIActivityViewController(
                            activityItems: ["Check out '\(titleName)' on Netflix Clone!"],
                            applicationActivities: nil
                        )
                        
                        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                           let rootViewController = windowScene.windows.first?.rootViewController {
                            rootViewController.present(activityVC, animated: true)
                        }
                    }
                }
                
                return UIMenu(title: "", children: [saveAction, shareAction])
            }
        )
        
        return config
    }
}
