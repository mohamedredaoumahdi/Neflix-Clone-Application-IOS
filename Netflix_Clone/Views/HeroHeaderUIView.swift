//
//  HeroHeaderUIView.swift
//  Netflix_Clone
//
//  Created by mohamed reda oumahdi on 01/03/2024.
//

import UIKit

class HeroHeaderUIView: UIView {
    
    private let downloadbutton : UIButton = {
        let button = UIButton()
        button.setTitle("Download", for: .normal)
        button.layer.borderColor = UIColor.white.cgColor
        button.layer.borderWidth = 1
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.cornerRadius = 5
        return button
    }()
    
    private let playbutton : UIButton = {
        let button = UIButton()
        button.setTitle("Play", for: .normal)
        button.layer.borderColor = UIColor.white.cgColor
        button.layer.borderWidth = 1
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.cornerRadius = 5
        return button
    }()
    
    private let heroheaderImage : UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.image = UIImage(named: "oppenheimerCover")
        return imageView
    }()
    
    private func addGradient(){
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [
            UIColor.clear.cgColor,
            UIColor.systemBackground.cgColor
        ]
        gradientLayer.frame = bounds
        layer.addSublayer(gradientLayer)
    }
    
    private func applyConstraints(){
        let playButtonConstraints = [
            playbutton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 50),
            playbutton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -50),
            playbutton.widthAnchor.constraint(equalToConstant: 120),
            playbutton.heightAnchor.constraint(equalToConstant: 40)
        ]
        let downloadButtonConstraints = [
            downloadbutton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -50),
            downloadbutton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -50),
            downloadbutton.widthAnchor.constraint(equalToConstant: 120),
            downloadbutton.heightAnchor.constraint(equalToConstant: 40)
        ]
        NSLayoutConstraint.activate(playButtonConstraints)
        NSLayoutConstraint.activate(downloadButtonConstraints)
        
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(heroheaderImage)
        addGradient()
        addSubview(playbutton)
        addSubview(downloadbutton)
        applyConstraints()
    }
    
    public func configure(with model : TitleViewModel){
        guard let url = URL(string: "https://image.tmdb.org/t/p/w500/\(model.posterURL)") else {return}
        heroheaderImage.sd_setImage(with: url,completed: nil)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        heroheaderImage.frame = bounds
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }

}
