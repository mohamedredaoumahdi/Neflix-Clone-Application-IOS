// UIHelpers.swift
// Netflix_Clone
//
// Created by mohamed reda oumahdi on 27/03/2025.
//

import UIKit

// MARK: - Image Loading Extensions

extension UIImageView {
    func loadImage(from urlString: String, placeholderImage: UIImage? = nil) {
        // Set placeholder if available
        if let placeholder = placeholderImage {
            self.image = placeholder
        }
        
        // Check for valid URL
        guard let url = URL(string: urlString) else {
            print("Invalid URL: \(urlString)")
            return
        }
        
        // Create URL request
        let request = URLRequest(url: url, cachePolicy: .returnCacheDataElseLoad)
        
        // Start the network task
        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            // Handle errors
            if let error = error {
                print("Error loading image: \(error.localizedDescription)")
                return
            }
            
            // Validate response
            guard let httpResponse = response as? HTTPURLResponse,
                  httpResponse.statusCode == 200 else {
                print("Invalid response")
                return
            }
            
            // Ensure we have image data
            guard let data = data, let image = UIImage(data: data) else {
                print("Invalid image data")
                return
            }
            
            // Update UI on main thread
            DispatchQueue.main.async {
                UIView.transition(with: self!, duration: 0.3, options: .transitionCrossDissolve, animations: {
                    self?.image = image
                }, completion: nil)
            }
        }.resume()
    }
    
    func loadTMDBImage(path: String?, size: TMDBImageSize = .w500) {
        guard let imagePath = path, !imagePath.isEmpty else {
            self.image = UIImage(systemName: "film") // Default placeholder
            return
        }
        
        let imageURL = "\(Configuration.URLs.TMDB_IMAGE_URL)/\(imagePath)"
        self.loadImage(from: imageURL)
    }
}

// MARK: - TMDB Image Size Options

enum TMDBImageSize: String {
    case w92 = "w92"
    case w154 = "w154"
    case w185 = "w185"
    case w342 = "w342"
    case w500 = "w500"
    case w780 = "w780"
    case original = "original"
}

// MARK: - UI Helper Methods

class UIHelpers {
    static func createGenrePill(for genre: String) -> UIView {
        let container = UIView()
        container.backgroundColor = .systemBlue.withAlphaComponent(0.2)
        container.layer.cornerRadius = 12
        container.translatesAutoresizingMaskIntoConstraints = false
        
        let label = UILabel()
        label.text = genre
        label.textColor = .systemBlue
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        
        container.addSubview(label)
        
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: container.topAnchor, constant: 4),
            label.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -4),
            label.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 12),
            label.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -12)
        ])
        
        return container
    }
    
    static func createHorizontalGenreStack(for genres: [String], maxWidth: CGFloat) -> UIStackView {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 8
        stackView.alignment = .center
        stackView.distribution = .fillProportionally
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        var currentWidth: CGFloat = 0
        
        for (index, genre) in genres.prefix(3).enumerated() {
            let pillView = createGenrePill(for: genre)
            
            // Estimate width (rough calculation)
            let estimatedWidth = genre.count * 10 + 24 // text width + padding
            
            if currentWidth + CGFloat(estimatedWidth) + (index > 0 ? 8 : 0) <= maxWidth {
                stackView.addArrangedSubview(pillView)
                currentWidth += CGFloat(estimatedWidth + (index > 0 ? 8 : 0))
            } else {
                break
            }
        }
        
        if genres.count > 3 {
            let morePill = createGenrePill(for: "+\(genres.count - 3) more")
            stackView.addArrangedSubview(morePill)
        }
        
        return stackView
    }
}

// MARK: - UIColor Extensions

extension UIColor {
    static let netflixRed = UIColor(red: 229/255, green: 9/255, blue: 20/255, alpha: 1.0)
    
    static let netflixBackground = UIColor(red: 20/255, green: 20/255, blue: 20/255, alpha: 1.0)
    
    static let netflixGray = UIColor(red: 128/255, green: 128/255, blue: 128/255, alpha: 1.0)
}

// MARK: - UILabel Extensions

extension UILabel {
    static func createTitleLabel() -> UILabel {
        let label = UILabel()
        label.font = .systemFont(ofSize: 20, weight: .bold)
        label.textColor = .label
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }
    
    static func createSubtitleLabel() -> UILabel {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textColor = .secondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }
}
