//
//  SearchViewController.swift
//  Netflix_Clone
//
//  Created by mohamed reda oumahdi on 27/02/2024.
//

import UIKit

class SearchViewController: UIViewController {
    

    private var titles: [Title] = [Title]()
    
    private let searchTable : UITableView = {
        let table = UITableView()
        table.register(TitleTableViewCell.self, forCellReuseIdentifier: TitleTableViewCell.identifier)
        return table
    }()
    
    private let searchResultViewController : UISearchController = {
        let searchResultController = UISearchController(searchResultsController: SearchResultsViewController())
        searchResultController.searchBar.placeholder = "Search for a Movie or a TVShow"
        searchResultController.searchBar.searchBarStyle = .minimal
        return searchResultController
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "Search"
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationItem.largeTitleDisplayMode = .always
        view.addSubview(searchTable)
        searchTable.delegate = self
        searchTable.dataSource = self
        navigationItem.searchController = searchResultViewController
        navigationItem.searchController?.searchBar.tintColor = .label
        fetchSearchedMovie()
        searchResultViewController.searchResultsUpdater = self
    }
    
    func fetchSearchedMovie(){
        
        APICaller.shared.searchForMovieByName(completing: { [weak self] result in
                        switch result {
            case .success(let titles) :
                self?.titles = titles
                DispatchQueue.main.async {
                    self?.searchTable.reloadData()

                }
            case .failure(let error) :
                print(error.localizedDescription)
            }
        })
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        searchTable.frame = view.bounds
    }

}

extension SearchViewController : UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return titles.count;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: TitleTableViewCell.identifier, for: indexPath) as? TitleTableViewCell else {return UITableViewCell()}
        let title = titles[indexPath.row]
        cell.configure(with: TitleViewModel(titleName: (title.originalTitle ?? title.originalName ?? "Unknown"), posterURL: title.posterPath ?? ""))
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 150
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let title = titles[indexPath.row]
        
        guard let titleName = title.originalTitle ?? title.originalName else {
            return
        }
        
        
        APICaller.shared.getMovie(with: titleName) { [weak self] result in
            switch result {
            case .success(let videoElement):
                DispatchQueue.main.async {
                    let vc = TitlePreviewViewController()
                    vc.configure(with: TitlePreviewViewModel(title: titleName, youtubeView: videoElement, titleOverview: title.overview ?? ""))
                    self?.navigationController?.pushViewController(vc, animated: true)
                }
                
                
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
}


extension SearchViewController : UISearchResultsUpdating , SearchResultsViewControllerDelegate{
    
    func updateSearchResults(for searchController: UISearchController) {
        let searchBar = searchController.searchBar
        guard let query = searchBar.text,
            !query.trimmingCharacters(in: .whitespaces).isEmpty,
            query.trimmingCharacters(in: .whitespaces).count > 3,
              let resultsController = searchController.searchResultsController as? SearchResultsViewController else {
                return
        }
        resultsController.delegate = self
        APICaller.shared.searchForMovieByName(with: query) { results in
            DispatchQueue.main.async {
                switch results{
                case .success(let titles):
                    resultsController.titles = titles
                    resultsController.searchResultsCollectionView.reloadData()
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
        }
    }
    
    func searchResultsViewControllerDidTapItem(_ viewModel: TitlePreviewViewModel) {
        
        DispatchQueue.main.async { [weak self] in
            let vc = TitlePreviewViewController()
            vc.configure(with: viewModel)
            self?.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
}
