//
//  TitleTableViewCell.swift
//  Netflix_Clone
//
//  Created by mohamed reda oumahdi on 05/03/2024.
//

import UIKit
import SDWebImage

class TitleTableViewCell: UITableViewCell {

    static let identifier : String = "TitleTableViewCell"
    
    private let playButton : UIButton = {
        let button = UIButton()
        let image = UIImage(systemName: "play.circle", withConfiguration : UIImage.SymbolConfiguration(pointSize: 30))
        button.setImage(image, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.tintColor = .label
        return button
    }()
    
    private let titleLabel : UILabel = {
        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        return titleLabel
    }()
    
    private let titlePoserUIImageView : UIImageView = {
        let titlePoster = UIImageView()
        titlePoster.contentMode = .scaleAspectFill
        titlePoster.translatesAutoresizingMaskIntoConstraints = false
        titlePoster.clipsToBounds = true
        return titlePoster
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(titleLabel)
        contentView.addSubview(titlePoserUIImageView)
        contentView.addSubview(playButton)
        applyConstraints()
    }
    
    private func applyConstraints(){
        let titlePoserUIImageViewConstaint = [
            titlePoserUIImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            titlePoserUIImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            titlePoserUIImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10),
            titlePoserUIImageView.widthAnchor.constraint(equalToConstant: 100)
            
        ]
        
        let titleLabelConstaint = [
            titleLabel.leadingAnchor.constraint(equalTo: titlePoserUIImageView.trailingAnchor, constant: 20),
            titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ]
        
        let playButtonConstaint = [
            playButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            playButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ]
        NSLayoutConstraint.activate(titlePoserUIImageViewConstaint)
        NSLayoutConstraint.activate(titleLabelConstaint)
        NSLayoutConstraint.activate(playButtonConstaint)
    }
    
    public func configure(with model: TitleViewModel) {
        guard let url = URL(string: "\(Configuration.URLs.TMDB_IMAGE_URL)/\(model.posterURL)") else {
            return
        }
        titlePoserUIImageView.sd_setImage(with: url, completed: nil)
        titleLabel.text = model.titleName
        
        // Add release date if available
        if let releaseDate = model.releaseDate {
            // You could add a release date label here if desired
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }

}
