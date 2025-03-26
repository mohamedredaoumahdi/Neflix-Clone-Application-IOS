// LoadingView.swift
// Netflix_Clone
//
// Created by mohamed reda oumahdi on 27/03/2025.
//

import UIKit

class LoadingView {
    static let shared = LoadingView()
    
    private var activityIndicator: UIActivityIndicatorView?
    private var loadingContainer: UIView?
    private var backgroundView: UIView?
    
    private init() {}
    
    func showLoading(in view: UIView, withText text: String? = nil) {
        DispatchQueue.main.async { [weak self] in
            self?.hideLoading()
            
            // Create a background view that covers the entire screen
            let backgroundView = UIView(frame: view.bounds)
            backgroundView.backgroundColor = UIColor.black.withAlphaComponent(0.6)
            backgroundView.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(backgroundView)
            
            NSLayoutConstraint.activate([
                backgroundView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                backgroundView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                backgroundView.topAnchor.constraint(equalTo: view.topAnchor),
                backgroundView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
            ])
            
            // Create a container view for the loader
            let containerView = UIView()
            containerView.backgroundColor = UIColor.darkGray.withAlphaComponent(0.7)
            containerView.layer.cornerRadius = 10
            containerView.translatesAutoresizingMaskIntoConstraints = false
            backgroundView.addSubview(containerView)
            
            // Create the activity indicator
            let indicator = UIActivityIndicatorView(style: .large)
            indicator.color = .white
            indicator.translatesAutoresizingMaskIntoConstraints = false
            containerView.addSubview(indicator)
            
            // If text is provided, add a label
            if let text = text, !text.isEmpty {
                let label = UILabel()
                label.text = text
                label.textColor = .white
                label.font = UIFont.systemFont(ofSize: 16)
                label.textAlignment = .center
                label.translatesAutoresizingMaskIntoConstraints = false
                containerView.addSubview(label)
                
                NSLayoutConstraint.activate([
                    containerView.centerXAnchor.constraint(equalTo: backgroundView.centerXAnchor),
                    containerView.centerYAnchor.constraint(equalTo: backgroundView.centerYAnchor),
                    containerView.widthAnchor.constraint(greaterThanOrEqualToConstant: 120),
                    containerView.heightAnchor.constraint(greaterThanOrEqualToConstant: 120),
                    
                    indicator.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
                    indicator.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 30),
                    
                    label.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
                    label.topAnchor.constraint(equalTo: indicator.bottomAnchor, constant: 16),
                    label.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
                    label.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
                    label.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -16)
                ])
            } else {
                NSLayoutConstraint.activate([
                    containerView.centerXAnchor.constraint(equalTo: backgroundView.centerXAnchor),
                    containerView.centerYAnchor.constraint(equalTo: backgroundView.centerYAnchor),
                    containerView.widthAnchor.constraint(equalToConstant: 100),
                    containerView.heightAnchor.constraint(equalToConstant: 100),
                    
                    indicator.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
                    indicator.centerYAnchor.constraint(equalTo: containerView.centerYAnchor)
                ])
            }
            
            indicator.startAnimating()
            
            self?.activityIndicator = indicator
            self?.loadingContainer = containerView
            self?.backgroundView = backgroundView
        }
    }
    
    func hideLoading() {
        DispatchQueue.main.async { [weak self] in
            self?.activityIndicator?.stopAnimating()
            
            UIView.animate(withDuration: 0.2, animations: {
                self?.backgroundView?.alpha = 0
            }, completion: { _ in
                self?.activityIndicator?.removeFromSuperview()
                self?.loadingContainer?.removeFromSuperview()
                self?.backgroundView?.removeFromSuperview()
                
                self?.activityIndicator = nil
                self?.loadingContainer = nil
                self?.backgroundView = nil
            })
        }
    }
}
