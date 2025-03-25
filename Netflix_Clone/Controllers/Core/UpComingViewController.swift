//
//  UpComingViewController.swift
//  Netflix_Clone
//
//  Created by mohamed reda oumahdi on 27/02/2024.
//

import UIKit

class UpComingViewController: UIViewController {
    
    private var titiles : [Title] = [Title]()
    
    private let upComingTable : UITableView = {
        let table = UITableView()
        table.register(TitleTableViewCell.self, forCellReuseIdentifier: TitleTableViewCell.identifier)
        return table
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "UpComing Movies"
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationItem.largeTitleDisplayMode = .always
        
        view.addSubview(upComingTable)
        upComingTable.delegate = self
        upComingTable.dataSource = self
        fetchUpComingMovies()
        
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        upComingTable.frame = view.bounds
    }
    
    func fetchUpComingMovies(){
        APICller.shared.getUPComingMovies { [weak self] result in
            switch result {
            case .success(let titles) :
                self?.titiles = titles
                DispatchQueue.main.async {
                    self?.upComingTable.reloadData()

                }
            case .failure(let error) :
                print(error.localizedDescription)
            }
        }
    }

}

extension UpComingViewController : UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return titiles.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: TitleTableViewCell.identifier, for: indexPath) as? TitleTableViewCell else {
            return TitleTableViewCell()
        }
        let title = titiles[indexPath.row]
        cell.configure(with: TitleViewModel(titleName: (title.original_title ?? title.original_name ?? "Unknown"), posterURL: title.poster_path ?? ""))
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 150
    }
}
